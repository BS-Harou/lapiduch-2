# http://blog.robertonodi.me/node-authentication-series-email-and-password/
settings = require(__base + 'services/settings').getSettings()
Promise = require 'bluebird'

LEN = 256
SALT_LEN = 64
ITERATIONS = settings.crypto.iterations
DIGEST = settings.crypto.digest
crypto = require 'crypto'

###*
	@param {string} password
	@param {string} salt
	@return {!Promise}
###
hashPassword = (password, salt) ->
	new Promise (resolve, reject) ->
		len = LEN / 2
		if salt
			crypto.pbkdf2 password, salt, ITERATIONS, len, DIGEST, (err, derivedKey) ->
				return reject(err) if err
				return resolve derivedKey.toString('hex')
		else
			crypto.randomBytes SALT_LEN / 2, (err, salt) ->
				return reject(err) if err
				salt = salt.toString('hex')
				crypto.pbkdf2 password, salt, ITERATIONS, len, DIGEST, (err, derivedKey) ->
					return reject(err) if err
					resolve
						hash: derivedKey.toString('hex')
						salt: salt
				return
		return

###*
	@param {string} str
	@return {string}
###
hashString = (str) ->
	str += Date.now().toString()
	return crypto.createHash('md5').update(str).digest("hex")

module.exports =
	hash: hashPassword
	hashString: hashString