express = require 'express'
clubs = require __base + 'collections/clubs'
users = require __base + 'collections/users'
router = express.Router()

router.get '/', (req, res, next) ->
	res.render 'search'

router.get '/hledat', (req, res, next) ->
	moderator = String(req.query.moderator).trim()
	return res.redirect '/hledani' unless moderator
	params = {}
	users.findByUsername moderator
	.then (user) ->
		return res.redirect '/hledani' unless user
		params.username = user.username
		clubs.findByUser user.id
	.then (clubsList) ->
		params.clubsList = clubsList
		res.render 'search', params
	.catch next
	

module.exports = router
