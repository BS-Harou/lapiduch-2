express = require 'express'
router = express.Router()
users = require __base + 'collections/users'
recaptcha = require __base + 'services/recaptcha'

passport = require 'passport'
LocalStrategy = require('passport-local').Strategy;

# GET user signup page
router.get '/registrace', (req, res, next) ->
	res.render 'signup', { title: 'Registrace' }

# POST registration details
router.post '/registrace', (req, res, next) ->
	captchaData =
		remoteip: req.connection.remoteAddress,
		response: req.body['g-recaptcha-response']
	recaptcha(captchaData).then ->
		users.createFromForm req.body
	.then (err) ->
		res.render 'signup', { title: 'Registrace', success: yes }
	.catch (err) ->
		return next err if err # TODO
		res.render 'signup', { title: 'Registrace', success: no, errorMessage: err?.toString() }

# GET activate user
router.get '/aktivace/:user/:activate', (req, res, next) ->
	users.activate(req.params.user, req.params.activate)
	.then ->
		return res.redirect '/' # TODO: Sign in user
	.catch next

router.get '/odhlasit', (req, res) ->
  req.logout()
  res.redirect '/'
  return


authConfig = successRedirect: '/', failureRedirect: '/'
router.post '/prihlaseni', passport.authenticate('local', authConfig)

module.exports = router

