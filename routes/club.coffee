express = require 'express'
clubs = require __base + 'collections/clubs'
posts = require __base + 'collections/posts'
users = require __base + 'collections/users'
history = require __base + 'collections/history'
normalize = require __base + 'services/normalize'
Promise = require 'bluebird'
router = express.Router()

getFindOptions = (query, authorId, lastPostId) ->
	params =
		to: query.to
		from: query.from ? lastPostId
	params.userId = authorId if authorId
	params.text = query.text if query.text
	params

router.get '/:club', (req, res, next) ->
	params =
		author: req.query.author
		text: req.query.text

	lastPostId = null
	authorId = null

	promise = Promise.resolve()
	if req.query.author
		normAuthor = normalize req.query.author
		promise = users.find normAuthor
		.then (user) ->
			authorId = user?.id
			# To show 'Following'/'Preceding' link on each post
			params.isFiltered = !!(authorId or req.query.text)

	promise.then ->
		clubs.find req.params.club
	.then (club) ->
		params.clubId = club.id
		params.clubName = club.name
		params.categoryName = club.categoryName
		params.clubHeading = club.heading
		params.clubIdent = req.params.club
		
		if req.user
			history.find req.user.id, club.id
			.then (visit) ->
				lastPostId = visit?.postId
				posts.findByClub club.id, getFindOptions req.query, authorId, lastPostId
		else
			posts.findByClub club.id, getFindOptions req.query
	.then (postsList) ->
		postsList.forEach((post) -> post.isNew = post.id > lastPostId) if lastPostId
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
		res.redirect '/klub/' + req.params.club
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
		res.redirect '/klub/' + req.params.club
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
		res.redirect '/klub/' + req.params.club + '/nastaveni'
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
		res.redirect '/klub/' + req.params.club + '/prava'
	.catch next

module.exports = router
