security = require __base + 'services/security'
mail = require __base + 'services/mail'
cloudinary = require 'cloudinary'
stream = require 'stream'
normalize = require __base + 'services/normalize'

PERM =
	USER: 'user'
	ADMIN: 'admin'

users =
	findById: (id) ->
		# magic
		return

	findByUsername: (username) ->
		# magic
		return

	###*
		@param {number} minutes
		@return {!Promise}
	###
	findByActivity: (minutes) ->
		queryData =
			activity: minutes * 60 * 1000
			currentTime: Date.now()
		db.query("""
			SELECT id, username, norm_username
			FROM users
			WHERE ${currentTime}-last_activity<${activity}
		""", queryData)
		.then (users) ->
			users.map (user) ->
				id: user.id
				username: user.username
				normUsername: user.norm_username

	login: (username, password) ->
		db.oneOrNone("SELECT * FROM users WHERE username=${username} OR email=${username}", { username: username })
		.then (user) ->
			throw new Error 'Neexistujici uzivatel' unless user
			security.hash password, user.salt
			.then (hash) ->
				throw new Error 'Incorrect password.' unless user.password is hash
				user

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
			activate: security.hashString data.email
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
			return null
			mail.sendAuthMail storeData.email, storeData.activate

	###*
		@param {string} activate
		@param {!Promise}
	###
	activate: (activate) ->
		db.none("UPDATE users SET activate='' WHERE activate=$1", activate)

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
			, public_id: user.username

			bufferStream = new stream.PassThrough()
			bufferStream.end(buffer);
			bufferStream.pipe(cloudinaryStream)
			return

users.PERM = PERM

module.exports = users