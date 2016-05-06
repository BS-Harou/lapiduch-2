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
		collection = mongodb.collection 'users'
		collection.findOne { $or: [{username: username}, {email: username }]}, (err, user) ->
			return done err  if err
			return done null, false, message: 'Asi neexistujici user' unless user # TODO, user neexistuje nebo se pokazilo neco jineho?
			pass = security.hash password, user.salt, (err, hash) ->
				return done null, false, message: 'Incorrect password.' unless user.password is hash
				return done null, user
			return
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
		pass = security.hash userData.password, (err, hash, salt) ->
			user = 
				username: userData.username
				email: userData.email
				password: hash
				salt: salt
				sex: userData.sex
				createdAt: Date.now()
				perm: userData.perm or PERM.USER

			collection = mongodb.collection 'users'
			collection.insert [user], (err) ->
				return cb err if err and cb
				mail.sendAuthMail user.email, (err) ->
					return unless typeof cb is 'function'
					return cb err if err
					cb null
			return
		return

	###*
		@param {!Buffer} userData
		@param {!Object} user
		@param {function} cb
	###
	uploadAvatar: (buffer, user, cb) ->
		cloudinaryStream = cloudinary.uploader.upload_stream (result) -> 
			# TODO handle errors (e.g.  interrupted stream upload)
			collection = mongodb.collection 'users'
			collection.updateOne { "_id" : user._id }, { $set: { "avatar": result.url } }, (err, results) ->
				cb err if err
				cb null, result
			return
		, public_id: user.username

		bufferStream = new stream.PassThrough()
		bufferStream.end(buffer);
		bufferStream.pipe(cloudinaryStream)
		return

users.PERM = PERM

module.exports = users