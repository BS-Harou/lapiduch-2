express = require 'express'
router = express.Router()

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy;

# GET users listing
router.get '/registrace', (req, res, next) ->
	res.render 'signup', { title: 'Registrace', csrfToken: req.csrfToken() }

# GET users listing
router.post '/registrace', (req, res, next) ->
	collection = mongodb.collection 'users'
	collection.insert [req.body], (err) ->
		return next err if err
		res.render 'signup', { title: 'Registrace', success: yes }


authConfig = successRedirect: '/', failureRedirect: '/'
router.post '/prihlaseni', passport.authenticate('local', authConfig)

module.exports = router

