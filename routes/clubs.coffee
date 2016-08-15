express = require 'express'
clubs = require __base + 'collections/clubs'
posts = require __base + 'collections/posts'
users = require __base + 'collections/users'
router = express.Router()

router.get '/', (req, res, next) ->
	clubs.getAllInCategories()
	.then (categoriesMap) ->
		params =
			title: 'Kluby'
			categoriesMap: categoriesMap
		res.render 'clubs', params
	.catch next

router.get '/hledat', (req, res, next) ->
	searchData =
		search: String(req.query.search).trim()
		searchIn: String(req.query['search-in']).trim()
	unless searchData.search and searchData.searchIn
		return res.redirect '/kluby'
	clubs.findByContent searchData
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
		params.clubId = club.id
		params.clubName = club.name
		params.categoryName = club.categoryName
		params.clubIdent = req.params.club
		posts.findByClub club.id, req.query
	.then (postsList) ->
		params.postsList = postsList
		params.topPostId = postsList[0]?.id
		params.bottomPostId = postsList[postsList.length - 1]?.id
		users.findByClub params.clubId
	.then (moderatorsList) ->
		params.moderatorsList = moderatorsList
		res.render 'club', params
	.catch next

router.post '/:club/pridat', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.find req.params.club
	.then (club) ->
		postData =
			title: req.body.title
			message: req.body.message
			userId: req.user.id
			clubId: club.id
			
		posts.create postData
	.then ->
		res.redirect '/kluby/' + req.params.club
	.catch next

router.get '/:club/oblibit', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.find req.params.club
	.then (club) ->
		favData =
			userId: req.user.id
			clubId: club.id
		users.favorite favData
	.then ->
		res.redirect '/kluby/' + req.params.club
	.catch next



module.exports = router
