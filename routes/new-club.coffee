express = require 'express'
router = express.Router()


router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	params =
		title: 'Nový klub'
		csrfToken: req.csrfToken()
	if req.user
		params.user = username: req.user.username, avatar: req.user.avatar
	res.render 'new-club', params



module.exports = router
