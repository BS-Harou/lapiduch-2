ObjectID = require('mongodb').ObjectID

LocalStrategy = require('passport-local').Strategy
users = require __base + 'collections/users'

module.exports = (passport) ->

	passport.use new LocalStrategy (username, password, done) ->
		users.loginUser username, password, done
		return

	passport.serializeUser (user, done) ->
		done null, user._id.toHexString()

	passport.deserializeUser (id, done) ->
		binId = ObjectID.createFromHexString(id)

		collection = mongodb.collection 'users'
		collection.findOne { _id: binId }, (err, user) ->
			return done err  if err
			# TODO, user is null
			return done null, user
		return
