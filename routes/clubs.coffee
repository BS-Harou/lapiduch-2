express = require 'express'
clubs = require __base + 'collections/clubs'
posts = require __base + 'collections/posts'
router = express.Router()

router.get '/', (req, res, next) ->
	clubs.getAll()
	.then (clubsList) ->
		params =
			title: 'Kluby'
			clubsList: clubsList
		res.render 'clubs', params
	.catch next

router.get '/:club', (req, res, next) ->
	params = {}
	clubs.find req.params.club
	.then (club) ->
		params.clubName = club.name
		params.categoryName = club.categoryName
		params.clubIdent = req.params.club
		posts.findByClub club.id, req.query
	.then (postsList) ->
		params.postsList = postsList
		params.topPostId = postsList[0]?.id
		params.bottomPostId = postsList[postsList.length - 1]?.id
		res.render 'club', params
	.catch next

router.post '/:club/pridat', (req, res, next) ->
	clubs.find req.params.club
	.then (club) ->
		throw new Error 'Nejste prihlaseni' unless req.user
		postData =
			title: req.body.title
			message: req.body.message
			userId: req.user.id
			clubId: club.id
			
		posts.create postData
	.then ->
		res.redirect '/kluby/' + req.params.club
	.catch next




module.exports = router
