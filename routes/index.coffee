express = require 'express'
router = express.Router()
categories = require __base + 'collections/categories'


# categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny', 'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene', 'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety', 'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane', 'Vzdelavani a skolstvi']
topList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]

# GET home page
router.get '/', (req, res, next) ->
	categories.getAll (err, categoriesList) ->
		return next err if err
		params =
			title: 'Index'
			topList: topList
			categoriesList: categoriesList
		res.render 'index', params


module.exports = router
