express = require 'express'
categories = require __base + 'collections/categories'
clubs = require __base + 'collections/clubs'
router = express.Router()

clubsList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]
clubsList = clubsList.map (name) ->
	name: name
	link: name.replace(/\s/g, '-').toLowerCase()

router.get '/', (req, res, next) ->
	categories.getAll()
	.then (categoriesList) ->
		params =
			title: 'Kategorie'
			categoriesList: categoriesList
		res.render 'categories', params
	.catch next

router.get '/:cat', (req, res, next) ->
	params = {}
	categories.find req.params.cat
	.then (cat) ->
		params.title = cat.name
		clubs.findByCategory cat.id
	.then (clubs) ->
		params.clubsList = clubs
		res.render 'category', params
	.catch next




module.exports = router
