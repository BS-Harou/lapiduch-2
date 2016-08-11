express = require 'express'
router = express.Router()

clubs = require __base + 'collections/clubs'
categories = require __base + 'collections/categories'


router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	categories.getAll (err, categoriesList) ->
		return next err if err
		params =
			title: 'Nový klub'
			categoriesList: categoriesList
		res.render 'new-club', params
		return
	return

router.post '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.create req.body, (err) ->
		return next err if err
		res.redirect '/'
		return
	return




module.exports = router
