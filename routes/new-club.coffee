express = require 'express'
router = express.Router()

clubs = require __base + 'collections/clubs'


router.get '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	params =
		title: 'Nový klub'
		csrfToken: req.csrfToken()
	if req.user
		params.user = username: req.user.username, avatar: req.user.avatar
	res.render 'new-club', params
	return

router.post '/', (req, res, next) ->
	return next new Error 'Nejste prihlaseni' unless req.user
	clubs.createNewClub req.body, (err) ->
		return next err if err
		res.redirect '/'
		return
	return




module.exports = router
