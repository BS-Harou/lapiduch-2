global.__base = __dirname + '/'

assert = require 'assert'
async = require 'async'
pgp = require('pg-promise')()
global.db = db = require __base + 'configs/postgre-config'
users = require './collections/users'
settings = require(__base + 'services/settings').getSettings()


collections = ['users', 'categories', 'clubs', 'posts']

async.waterfall [
	(done) ->
		# Recreate DB
		console.log 'RECREATING SCHEMA AND TABLES'
		db.query(new pgp.QueryFile('restart-db.sql', { minify: true }))
		.then ->
			return done null
		.catch (err) ->
			return done err
		return
,
	(done) ->
		console.log 'CREATING ADMIN'
		# Create admin user
		users.createUser({
			username: settings.admin.username
			password: settings.admin.password
			sex: 'male'
			email: settings.admin.email
			perm: users.PERM.ADMIN
		}, done)
		return
,
	(done) ->

		# TODO move insert to collections/categories.coffee

		categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny',
			'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene',
			'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety',
			'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane',
			'Vzdelavani a skolstvi']

		console.log 'CREATING CATEGORIES'

		# TODO link
		db.tx (t) ->
	        queries = categoriesList.map (item) ->
	            t.none "INSERT INTO categories(name, description) VALUES(${item}, ${item})", { item: item }
	        return t.batch queries
	    .then (data) ->
	        done null
	    .catch (err) ->
	        done err
		return
], (err) ->
	return console.log err if err
	return console.log 'DONE'


