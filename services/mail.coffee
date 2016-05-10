nodemailer = require 'nodemailer'
hashString = require(__base + 'services/security').hashString
settings = require(__base + 'services/settings').getSettings()

smtpLogin = ''
transporter = nodemailer.createTransport settings.mail.smtp

FROM = '"Lapiduch" <lapiduch@martinkadlec.eu>'

mail =
	sendMail: (mailOptions, cb) ->
		transporter.sendMail mailOptions, (error, info) ->
			return cb error if error
			return cb null, info.response
		return

	# TODO util to get absolute lapiduch url, use actual working url
	sendAuthMail: (to, activate, cb) ->

		link = "#{settings.url}/auth/activate/#{activate}"

		mailOptions =
			from: settings.mail.from
			to: to
			subject: 'Lapiduch - Potvrzení registrace'
			text: """
				Děkujeme za registraci na diskuzním serveru lapiduch.cz. Potvrďte prosím svou registraci kliknutím na následující odkaz:\n\n
				#{hashString(link)}
			"""
		@sendMail mailOptions, cb
		return

module.exports = mail
			