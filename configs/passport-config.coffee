LocalStrategy = require('passport-local').Strategy
users = require __base + 'collections/users'

module.exports = (passport) ->

	passport.use new LocalStrategy (username, password, done) ->
		# Todo show errors liek Invalid password to user
		users.login username, password, done
		return

	passport.serializeUser (user, done) ->
		done null, user.id

	passport.deserializeUser (id, done) ->
		# TODO User users collection to get use by id
		db.one("SELECT * FROM users WHERE id=${userId}", { userId: id })
		.then (user) ->
			console.log 'User found'
			return done null, user
		.catch (err) ->
			console.log 'User not found'
			return done err if err
		return
