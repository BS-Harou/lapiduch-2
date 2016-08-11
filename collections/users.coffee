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

	login: (username, password, done) ->
		db.one("SELECT * FROM users WHERE username=${username} OR email=${username}", { username: username })
		.then (user) ->
			return done null, false, message: 'Neexistujici uzivatel' unless user
			pass = security.hash password, user.salt, (err, hash) ->
				return done null, false, message: 'Incorrect password.' unless user.password is hash
				return done null, user
			return
		.catch (err) ->
			return done err
		return

	###*
		@param {!Object} formData
		@param {function} cb
	###
	createFromForm: (formData, cb) ->
		return cb('Špatná data') unless formData
		# TODO existing username/email check
		return cb('Neplatné uživatelské jméno') unless formData.username?.match /^\w{3,16}$/
		return cb('Hesla se nerovnají') unless formData.password is formData.confirmPassword
		return cb('Neplatné heslo') unless formData.password?.match /^.{5,100}$/
		return cb('Neplatný email') unless formData.email?.match /^\S{1,30}@\S{1,30}\.\S{1,30}$/
		return cb('Neplatné pohlaví') unless formData.sex in ['male', 'female']

		userData =
			username: formData.username
			email: formData.email
			password: formData.password
			sex: formData.sex

		@create userData, cb
		return

	###*
		@param {!Object} data
		@param {function} cb
	###
	create: (data, cb) ->
		security.hash data.password, (err, hash, salt) ->
			storeData = 
				username: data.username
				normUsername: normalize data.username
				email: data.email
				password: hash
				salt: salt
				sex: data.sex
				createdAt: Date.now()
				perm: data.perm or PERM.USER
				activate: security.hashString data.email
				avatar: data.avatar or ''

			db.none("""
				INSERT INTO users (username, norm_username, email, password, salt, sex, created_at, perm, activate, avatar)
				VALUES(${username}, ${normUsername}, ${email}, ${password}, ${salt}, ${sex}, ${createdAt}, ${perm}, ${activate}, ${avatar})
			""", storeData)
			.then ->
				return cb null
				mail.sendAuthMail user.email, user.activate, (err) ->
					return unless typeof cb is 'function'
					return cb err if err
					cb null
				return
			.catch (err) ->
				return cb err if cb
			return
		return

	###*
		@param {string} activate
		@param {function} cb
	###
	activate: (activate, cb) ->
		db.none("UPDATE users SET activate='' WHERE activate=$1", activate)
		.then ->
			return cb() if cb
		.catch (err) ->
			return cb err if cb
		return

	###*
		@param {!Buffer} buffer
		@param {!Object} user
		@param {function} cb
	###
	uploadAvatar: (buffer, user, cb) ->
		# TODO handle errors (e.g.  interrupted stream upload)
		cloudinaryStream = cloudinary.uploader.upload_stream (result) -> 
			console.log '>> RESULT >>', result
			console.log '>> USER >>', user
			db.none("UPDATE users SET avatar=${avatar} WHERE id=${userId}", { userId: user.id, avatar: result.secure_url })
			.then ->
				cb null, result
			.catch (err) ->
				console.log '>> ERR >> ', err
				return cb err
			return
		, public_id: user.username

		bufferStream = new stream.PassThrough()
		bufferStream.end(buffer);
		bufferStream.pipe(cloudinaryStream)
		return

users.PERM = PERM

module.exports = users