# http://blog.robertonodi.me/node-authentication-series-email-and-password/
settings = require(__base + 'services/settings').getSettings()

LEN = 256
SALT_LEN = 64
ITERATIONS = settings.crypto.iterations
DIGEST = settings.crypto.digest
crypto = require 'crypto'

hashPassword = (password, salt, callback) ->
	len = LEN / 2
	if arguments.length is 3
		crypto.pbkdf2 password, salt, ITERATIONS, len, DIGEST, (err, derivedKey) ->
			return callback(err) if err
			callback null, derivedKey.toString('hex')
	else
		callback = salt
		crypto.randomBytes SALT_LEN / 2, (err, salt) ->
			return callback(err) if err
			salt = salt.toString('hex')
			crypto.pbkdf2 password, salt, ITERATIONS, len, DIGEST, (err, derivedKey) ->
				return callback(err) if err
				callback null, derivedKey.toString('hex'), salt
			return
		return
	return

hashString = (str) ->
	str += Date.now().toString()
	return crypto.createHash('md5').update(str).digest("hex")

module.exports =
	hash: hashPassword
	hashString: hashString