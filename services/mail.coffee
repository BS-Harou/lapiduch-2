nodemailer = require 'nodemailer'
hashString = require(__base + 'services/security').hashString
settings = require(__base + 'services/settings').getSettings()

smtpLogin = ''
transporter = nodemailer.createTransport settings.mail.smtp

FROM = '"Lapiduch" <lapiduch@martinkadlec.eu>'

mail =

	###*
		@param {!Object} mailOptions
		@return {!Promise}
	###
	sendMail: (mailOptions) ->
		transporter.sendMail(mailOptions)
		.then (info) ->
			info.response

	###*
		TODO util to get absolute lapiduch url, use actual working url
		@param {string} to
		@param {string} activate
		@return {!Promise}
	####
	sendAuthMail: (to, activate) ->

		link = "#{settings.url}/auth/activate/#{activate}"

		mailOptions =
			from: settings.mail.from
			to: to
			subject: 'Lapiduch - Potvrzení registrace'
			text: """
				Děkujeme za registraci na diskuzním serveru lapiduch.cz. Potvrďte prosím svou registraci kliknutím na následující odkaz:\n\n
				#{hashString(link)}
			"""
		@sendMail mailOptions

module.exports = mail
			