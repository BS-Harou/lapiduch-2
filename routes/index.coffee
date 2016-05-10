express = require 'express'
router = express.Router()


# categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny', 'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene', 'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety', 'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane', 'Vzdelavani a skolstvi']
topList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]

# GET home page
router.get '/', (req, res, next) ->
	require('../collections/categories').getAllCategories (err, categoriesList) ->
		# next err if err
		categoriesList = []
		params =
			title: 'Index'
			topList: topList
			categoriesList: categoriesList
			csrfToken: req.csrfToken()
		if req.user
			params.user = username: req.user.username, avatar: req.user.avatar
		res.render 'index', params


module.exports = router
