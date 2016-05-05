express = require 'express'
router = express.Router()

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy;

# GET users listing
router.get '/', (req, res, next) ->
	res.send 'respond with a resource'

module.exports = router
