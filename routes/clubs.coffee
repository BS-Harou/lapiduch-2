express = require 'express'
clubs = require __base + 'collections/clubs'
posts = require __base + 'collections/posts'
users = require __base + 'collections/users'
history = require __base + 'collections/history'
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

#
# ALL TOP CLUBS
#
router.get '/nejprispivanejsi', (req, res, next) ->
	clubs.findMostPosted(yes)
	.then (clubsList) ->
		params =
			title: 'Nejpřispívaněší'
			clubsList: clubsList
		res.render 'clubs', params
	.catch next

router.get '/nejnavstevovanejsi', (req, res, next) ->
	clubs.findMostVisited(yes)
	.then (clubsList) ->
		params =
			title: 'Nejnavštěvovanější'
			clubsList: clubsList
		res.render 'clubs', params
	.catch next

router.get '/nejnovejsi', (req, res, next) ->
	clubs.findMostNew(yes)
	.then (clubsList) ->
		params =
			title: 'Nejnovější'
			clubsList: clubsList
		res.render 'clubs', params
	.catch next


# TODO move to /klub route

router.get '/:club', (req, res, next) ->
	params = {}
	clubs.find req.params.club
	.then (club) ->
		params.clubId = club.id
		params.clubName = club.name
		params.categoryName = club.categoryName
		params.clubHeading = club.heading
		params.clubIdent = req.params.club
		posts.findByClub club.id, req.query
	.then (postsList) ->
		params.postsList = postsList
		params.topPostId = postsList[0]?.id
		params.bottomPostId = postsList[postsList.length - 1]?.id
		return Promise.resolve() unless req.user
		history.visitClub
			userId: req.user.id
			clubId: params.clubId
			postId: params.topPostId
	.then ->
		users.findByClub params.clubId
	.then (moderatorsList) ->
		params.moderatorsList = moderatorsList
		res.render 'club', params
	.catch next

#
# CLUB ACTIONS
#

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

#
# CLUB MODERATION
#

router.get '/:club/nastaveni', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user # TODO: only moderator
	clubs.find req.params.club
	.then (club) ->
		params =
			clubId: club.id
			clubName: club.name
			clubDescription: club.description
			clubHeading: club.heading
			categoryName: club.categoryName
			clubIdent: req.params.club
		res.render 'club-settings', params
	.catch next

router.post '/:club/nastaveni', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user # TODO: only moderator

	clubs.update req.params.club, req.body
	.then ->
		res.redirect '/kluby/' + req.params.club + '/nastaveni'
	.catch next

router.get '/:club/prava', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user # TODO: only moderator
	params = {}
	clubs.find req.params.club
	.then (club) ->
		params.clubId = club.id
		params.clubName = club.name
		params.clubDescription = club.description
		params.clubHeading = club.heading
		params.categoryName = club.categoryName
		params.clubIdent = req.params.club
		users.findByClub params.clubId
	.then (moderatorsList) ->
		params.moderatorsList = moderatorsList
		res.render 'club-moderators', params
	.catch next

router.post '/:club/prava', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user # TODO: only moderator

	clubs.find req.params.club
	.then (club) ->
		users.updateClubPermissions club.id, req.user.id, req.body.level
	.then ->
		res.redirect '/kluby/' + req.params.club + '/prava'
	.catch next




module.exports = router
