LocalStrategy = require('passport-local').Strategy
users = require __base + 'collections/users'

module.exports = (passport) ->

	passport.use new LocalStrategy (username, password, done) ->
		# Todo show errors like Invalid password to user
		users.login username, password
		.then (user) ->
			done null, user
		.catch done

	passport.serializeUser (user, done) ->
		done null, user.id

	passport.deserializeUser (id, done) ->
		# TODO User users collection to get use by id
		db.oneOrNone("SELECT * FROM users WHERE id=${userId}", { userId: id })
		.then (user) ->
			console.log 'User found'
			done null, user
		.catch (err) ->
			console.log 'User not found'
			done err
