express = require 'express'
clubs = require __base + 'collections/clubs'
router = express.Router()

router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.findFavorites req.user.id
	.then (favoritesMap) ->
		params =
			title: 'Kluby'
			favoritesMap: favoritesMap
		res.render 'favorites', params
	.catch next



module.exports = router
