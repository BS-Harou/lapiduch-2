express = require 'express'
router = express.Router()
users = require __base + 'collections/users'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy;

# GET user signup page
router.get '/registrace', (req, res, next) ->
	res.render 'signup', { title: 'Registrace' }
	return

# POST registration details
router.post '/registrace', (req, res, next) ->
	users.createFromForm req.body, (err) ->
		return next err if err
		res.render 'signup', { title: 'Registrace', success: !err, errorMessage: err?.toString() }
	return

# POST activate user
router.post '/activate/:activate', (req, res, next) ->
	users.activate req.something, (err) ->
		return next err if err
		res.render 'signup', { title: 'Registrace', success: !err, errorMessage: err?.toString() }
	return

router.get '/odhlasit', (req, res) ->
  req.logout()
  res.redirect '/'
  return


authConfig = successRedirect: '/', failureRedirect: '/'
router.post '/prihlaseni', passport.authenticate('local', authConfig)

module.exports = router

