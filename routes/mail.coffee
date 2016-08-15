express = require 'express'
mails = require __base + 'collections/mails'
posts = require __base + 'collections/posts'
users = require __base + 'collections/users'
router = express.Router()

router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	params =
		username: req.user.username
		normUsername: req.user.normUsername
	
	mails.findByUser req.user.id
	.then (mailsList) ->
		params.mailsList = mailsList
		params.topMailId = mailsList[0]?.id
		params.bottomMailId = mailsList[mailsList.length - 1]?.id
		res.render 'mail', params
	.catch next

router.post '/pridat', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	mailData =
		title: req.body.title
		message: req.body.message
		userId: req.user.id
		clubId: club.id
	mails.create mailData
	.then ->
		res.redirect '/posta'
	.catch next




module.exports = router
