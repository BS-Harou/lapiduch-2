Promise = require 'bluebird'
Recaptcha = require('node-recaptcha2').Recaptcha
settings = require(__base + 'services/settings').getSettings()

module.exports = (data) ->
	new Promise (resolve, reject) ->
		recaptcha = new Recaptcha settings.recaptcha.public, settings.recaptcha.private, data
		recaptcha.verify (success, errorCode) ->
			return resolve() if success
			return reject new Error "reCAPTCHA Error: #{errorCode}"
