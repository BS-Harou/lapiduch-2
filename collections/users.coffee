security = require __base + 'services/security'
mail = require __base + 'services/mail'
cloudinary = require 'cloudinary'
stream = require 'stream'

PERM =
	USER: 'user'
	ADMIN: 'admin'

users =
	findUserById: (id) ->
		# magic
		return

	findUserByUsername: (username) ->
		# magic
		return

	loginUser: (username, password, done) ->
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
	createUserFromForm: (formData, cb) ->
		return cb('Špatná data') unless formData
		# TODO existing username/email check
		return cb('Neplatné uživatelské jméno') unless formData.username?.match /^\w{3,16}$/
		return cb('Hesla se nervonají') unless formData.password is formData.confirmPassword
		return cb('Neplatné heslo') unless formData.password?.match /^.{5,100}$/
		return cb('Neplatný email') unless formData.email?.match /^\S{1,30}@\S{1,30}\.\S{1,30}$/
		return cb('Neplatné pohlaví') unless formData.sex in ['male', 'female']

		userData =
			username: formData.username
			email: formData.email
			password: formData.password
			sex: formData.sex

		@createUser userData, cb
		return

	###*
		@param {!Object} userData
		@param {function} cb
	###
	createUser: (userData, cb) ->
		security.hash userData.password, (err, hash, salt) ->
			user = 
				username: userData.username
				email: userData.email
				password: hash
				salt: salt
				sex: userData.sex
				createdAt: Date.now()
				perm: userData.perm or PERM.USER
				activate: security.hashString userData.email

			db.none("""
				INSERT INTO users (username, email, password, salt, sex, created_at, perm, activate)
				VALUES(${username}, ${email}, ${password}, ${salt}, ${sex}, ${createdAt}, ${perm}, ${activate})
			""", user)
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
	activateUser: (activate, cb) ->
		db.none("UPDATE users SET activate='' WHERE activate=$1", activate)
		.then ->
			return cb() if cb
		.catch (err) ->
			return cb err if cb
		return

	###*
		@param {!Buffer} userData
		@param {!Object} user
		@param {function} cb
	###
	uploadAvatar: (buffer, user, cb) ->
		# TODO handle errors (e.g.  interrupted stream upload)
		cloudinaryStream = cloudinary.uploader.upload_stream (result) -> 
			db.none("UPDATE users SET avatar=${avatar} WHERE id=${userId}", { userId: user.id, avatar: result.url })
			.then ->
				cb null, result
			.catch (err) ->
				return cb err
			return
		, public_id: user.username

		bufferStream = new stream.PassThrough()
		bufferStream.end(buffer);
		bufferStream.pipe(cloudinaryStream)
		return

users.PERM = PERM

module.exports = users