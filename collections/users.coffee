security = require __base + 'services/security'
email = require __base + 'services/email'
cloudinary = require 'cloudinary'
stream = require 'stream'
normalize = require __base + 'services/normalize'
moment = require 'moment'
uuid = require 'node-uuid'

PERM =
	USER: 'user'
	ADMIN: 'admin'

users =

	###*
		@param {string|number} ident - id or normName of a club
		@return {!Promise}
	###
	find: (ident) ->
		queryData =
			searchBy: if typeof ident is 'number' then 'id' else 'norm_username'
			ident: ident
		db.oneOrNone("""
			SELECT id, username, norm_username, activate, motto, avatar
			FROM users
			WHERE users.${searchBy~}=${ident}
		""", queryData)
		.then (item) =>
			return null unless item
			@transformOut item

	###*
		@param {string} username
		@return {!Promise}
	###
	findByUsername: (username) ->
		queryData =
			username: username
		db.oneOrNone("""
			SELECT id, username, norm_username
			FROM users
			WHERE username=${username} LIMIT 1
		""", queryData)
		.then (item) =>
			return null unless item
			@transformOut item

	###*
		@param {number} minutes
		@return {!Promise}
	###
	findByActivity: (minutes) ->
		queryData =
			activity: minutes * 60 * 1000
			currentTime: Date.now()
		db.query("""
			SELECT id, username, norm_username, avatar, last_activity
			FROM users
			WHERE ${currentTime}-last_activity<${activity}
		""", queryData)
		.then (users) =>
			users.map @transformOut

	###*
		@param {number} minutes
		@return {!Promise}
	###
	findByClub: (clubId) ->
		queryData =
			clubId: clubId
		db.query("""
			SELECT users.id, users.username, users.norm_username, users.avatar, clubs_owners.level
			FROM users
			INNER JOIN clubs_owners ON users.id=clubs_owners.user_id
			WHERE clubs_owners.club_id=${clubId}
		""", queryData)
		.then (users) =>
			users.map @transformOut

	###*
		@param {number} clubId
		@param {number} level
		@return {!Promise}
	###
	updateClubPermissions: (clubId, userId, level) ->
		queryData =
			clubId: clubId
			userId: userId
			level: level
		db.none("""
			UPDATE clubs_owners SET level=${level} WHERE club_id=${clubId} AND user_id=${userId}
		""", queryData)

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformOut: (data) ->
		id: Number data.id
		username: data.username
		normUsername: data.norm_username
		activate: data.activate
		avatar: data.avatar
		motto: data.motto
		level: Number data.level
		lastActivity: Number data.last_activity
		lastActivityFormatted: moment(Number(data.last_activity)).format('DD.MM.YYYY h:mm:ss')

	login: (username, password) ->
		db.oneOrNone("SELECT * FROM users WHERE username=${username} OR email=${username} LIMIT 1", { username: username })
		.then (user) ->
			throw new Error 'Neexistujici uzivatel' unless user
			throw new Error 'Neaktivní uživatel' if user.activate
			security.hash password, user.salt
			.then (hash) ->
				throw new Error 'Incorrect password.' unless user.password is hash
				user

	###*
		@param {!Object} data
		@return {!Promise}
	###
	favorite: (data) ->
		queryData = Object.assign data
		queryData.type or= 1
		db.oneOrNone('SELECT * FROM favorites WHERE user_id=${userId} AND club_id=${clubId} LIMIT 1', queryData)
		.then (fav) ->
			if fav
				queryData.favId = fav.id
				db.none('UPDATE favorites SET type=${type} WHERE id=${favId}', queryData)
			else
				db.none('INSERT INTO favorites (club_id, user_id, type) VALUES(${clubId}, ${userId}, ${type})', queryData)

	###*
		@param {number} userId
		@return {!Promise}
	###
	updateActivity: (userId) ->
		storeData =
			'lastActivity': Date.now()
		db.none('UPDATE users SET last_activity=${lastActivity}', storeData)

	###*
		@param {!Object} formData
		@return {!Promise}
	###
	createFromForm: (formData) ->
		return Promise.reject('Špatná data') unless formData
		# TODO existing username/email check
		return Promise.reject('Neplatné uživatelské jméno') unless formData.username?.match /^\w{3,16}$/
		return Promise.reject('Hesla se nerovnají') unless formData.password is formData.confirmPassword
		return Promise.reject('Neplatné heslo') unless formData.password?.match /^.{5,100}$/
		return Promise.reject('Neplatný email') unless formData.email?.match /^\S{1,30}@\S{1,30}\.\S{1,30}$/
		return Promise.reject('Neplatné pohlaví') unless formData.sex in ['male', 'female']

		userData =
			username: formData.username
			email: formData.email
			password: formData.password
			sex: formData.sex

		@create userData

	###*
		@param {!Object} data
		@return {!Promise}
	###
	create: (data) ->

		storeData = 
			username: data.username
			normUsername: normalize data.username
			email: data.email
			sex: data.sex
			createdAt: Date.now()
			perm: data.perm or PERM.USER
			activate: if data.hasOwnProperty 'activate' then data.activate else uuid.v4()
			avatar: data.avatar or ''

		security.hash data.password
		.then (hashData) ->
			storeData.password = hashData.hash
			storeData.salt = hashData.salt

			db.none("""
				INSERT INTO users (username, norm_username, email, password, salt, sex, created_at, perm, activate, avatar)
				VALUES(${username}, ${normUsername}, ${email}, ${password}, ${salt}, ${sex}, ${createdAt}, ${perm}, ${activate}, ${avatar})
			""", storeData)
		.then ->
			return unless storeData.activate?.length
			email.sendAuthMail storeData.email, storeData.activate, storeData.normUsername

	###*
		@param {string} userIdent
		@param {string} activate
		@param {!Promise}
	###
	activate: (userIdent, activate) ->
		@find userIdent
		.then (user) ->
			throw new Error 'Invalid user' unless user
			throw new Error 'No activation string' unless activate?.length
			throw new Error "Invalid activation link" unless activate is user.activate
			db.none("UPDATE users SET activate='' WHERE id=$1", user.id)	
		
	###*
		@param {!Buffer} buffer
		@param {!Object} user
		@return {!Promise}
	###
	uploadAvatar: (buffer, user) ->
		# TODO handle errors (e.g.  interrupted stream upload)
		new Promise (resolve, reject) ->
			cloudinaryStream = cloudinary.uploader.upload_stream (result) -> 
				db.none("UPDATE users SET avatar=${avatar} WHERE id=${userId}", { userId: user.id, avatar: result.secure_url })
				.then ->
					resolve result
				.catch (err) ->
					reject err
				return
			, public_id: user.norm_username

			bufferStream = new stream.PassThrough()
			bufferStream.end(buffer);
			bufferStream.pipe(cloudinaryStream)
			return

users.PERM = PERM

module.exports = users