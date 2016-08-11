express = require 'express'
categories = require __base + 'collections/categories'
clubs = require __base + 'collections/clubs'
router = express.Router()

clubsList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]
clubsList = clubsList.map (name) ->
	name: name
	link: name.replace(/\s/g, '-').toLowerCase()

router.get '/', (req, res, next) ->
	categories.getAll (err, categoriesList) ->
		params =
			title: 'Kategorie'
			categoriesList: categoriesList
		res.render 'categories', params

router.get '/:cat', (req, res, next) ->
	categories.find req.param.cat, (err, cat) ->
		next err if err
		clubs.findByCategory cat.id, (err, clubs) ->
			next err if err
			params =
				title: cat.name
				clubsList: clubs
			res.render 'category', params
		return
	return




module.exports = router
