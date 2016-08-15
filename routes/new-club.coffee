express = require 'express'
router = express.Router()

clubs = require __base + 'collections/clubs'
categories = require __base + 'collections/categories'


router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	categories.getAll()
	.then (categoriesList) ->
		params =
			title: 'Nový klub'
			categoriesList: categoriesList
		res.render 'new-club', params
	.catch next

router.post '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.createFromForm req.body, req.user
	.then ->
		res.redirect '/'
	.catch next




module.exports = router
