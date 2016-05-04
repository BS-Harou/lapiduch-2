express = require 'express'
router = express.Router()

topList = ["Volím Lapiduch", "SPANKING", "Hifi inzerce", "Hezké slečny", "E-spanking", "Zbrane", "Sjezd Lhot a Lehot", "Hrátky s češtinou", "Politika a dění ve světě", "Klubiki"]

# GET home page
router.get '/', (req, res, next) ->
	res.render 'index', { title: 'Express', topList: topList }

module.exports = router
