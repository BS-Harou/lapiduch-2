express = require 'express'
clubs = require __base + 'collections/clubs'
posts = require __base + 'collections/posts'
router = express.Router()

router.get '/', (req, res, next) ->
	clubs.getAll (err, clubsList) ->
		return next err if err
		params =
			title: 'Kluby'
			clubsList: clubsList
		res.render 'clubs', params

router.get '/:club', (req, res, next) ->
	clubs.find req.params.club, (err, club) ->
		return next err if err
		posts.findByClub club.id, (err, postsList) ->
			next err if err
			params =
				clubName: club.name
				categoryName: club.category_name # TODO: transform data from find to camcelCase
				clubIdent: req.params.club
				postsList: postsList
			res.render 'club', params
			return
		return
	return

router.post '/:club/pridat', (req, res, next) ->
	clubs.find req.params.club, (err, club) ->
		return next err if err
		return next new Error 'Nejste prihlaseni' unless req.user
		postData =
			title: req.body.title
			message: req.body.message
			userId: req.user.id
			clubId: club.id
			
		posts.create postData, (err) ->
			return next err if err
			res.redirect '/kluby/' + req.params.club
			return
		return
	return




module.exports = router
