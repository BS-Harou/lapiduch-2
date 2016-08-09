express = require 'express'
router = express.Router()
users = require __base + 'collections/users'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy;

# GET user signup page
router.get '/registrace', (req, res, next) ->
	res.render 'signup', { title: 'Registrace', csrfToken: req.csrfToken() }
	return

# POST registration details
router.post '/registrace', (req, res, next) ->
	users.createUserFromForm req.body, (err) ->
		console.log 'ERR: ', err
		res.render 'signup', { title: 'Registrace', success: !err, errorMessage: err?.toString(), csrfToken: req.csrfToken() }
	return

# POST activate user
router.post '/activate/:activate', (req, res, next) ->
	users.activateUser req.something, (err) ->
		console.log 'ERR: ', err
		res.render 'signup', { title: 'Registrace', success: !err, errorMessage: err?.toString(), csrfToken: req.csrfToken() }
	return

router.get '/odhlasit', (req, res) ->
  req.logout()
  res.redirect '/'
  return


authConfig = successRedirect: '/', failureRedirect: '/'
router.post '/prihlaseni', passport.authenticate('local', authConfig)

module.exports = router

