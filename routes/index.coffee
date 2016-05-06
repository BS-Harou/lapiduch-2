express = require 'express'
router = express.Router()


# categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny', 'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene', 'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety', 'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane', 'Vzdelavani a skolstvi']
topList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]

# GET home page
router.get '/', (req, res, next) ->
	require('../collections/categories').getAllCategories (categoriesList) ->
		res.render 'index', {
			title: 'Express'
			topList: topList
			categoriesList: categoriesList
			csrfToken: req.csrfToken()
		}


module.exports = router
