express = require 'express'
users = require __base + 'collections/users'
router = express.Router()

MINUTES = 60

router.get '/', (req, res, next) ->
	users.findByActivity(MINUTES)
	.then (usersList) ->
		params =
			title: 'Přítomní'
			usersList: usersList
		res.render 'activity', params
	.catch next


module.exports = router
