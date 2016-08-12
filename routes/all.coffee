express = require 'express'
users = require __base + 'collections/users'
router = express.Router()


router.get '/', (req, res, next) ->
	if user = req.user
		users.updateActivity user.id
	next() # TODO is it okay to not wait for the update?

module.exports = router
