nodemailer = require 'nodemailer'
hashString = require(__base + 'services/security').hashString
settings = require(__base + 'services/settings').getSettings()
ECT = require 'ect'

mailRenderer = ECT(watch: true, root: __base + '/views/mail', ext: '.ect')


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
		@param {string} normUsername
		@return {!Promise}
	####
	sendAuthMail: (to, activate, normUsername) ->

		# link = "#{settings.url}/auth/activate/#{activate}"
		activationLink = "http://lapiduch.martinkadlec.eu/auth/aktivace/#{normUsername}/#{activate}"

		mailOptions =
			from: settings.mail.from
			to: to
			subject: 'Lapiduch - Aktivace'
			text: mailRenderer.render('activation-plain', { site: 'http://lapiduch.martinkadlec.eu/', activationLink })
			html: mailRenderer.render('activation', { site: 'http://lapiduch.martinkadlec.eu/', activationLink })
		@sendMail mailOptions

module.exports = mail
			