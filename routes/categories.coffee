express = require 'express'
users = require __base + 'collections/users'
router = express.Router()

clubsList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]
clubsList = clubsList.map (name) ->
	name: name
	link: name.replace(/\s/g, '-').toLowerCase()

router.get '/', (req, res, next) ->
	require('../collections/categories').getAllCategories (categoriesList) ->
		params =
			title: 'Kategorie'
			categoriesList: categoriesList
			csrfToken: req.csrfToken()
		if req.user
			params.user = username: req.user.username, avatar: req.user.avatar
		res.render 'categories', params

router.get '/:kat', (req, res, next) ->
	params =
		title: 'XXX'
		clubsList: clubsList
		csrfToken: req.csrfToken()
	if req.user
		params.user = username: req.user.username, avatar: req.user.avatar
	res.render 'category', params




module.exports = router
