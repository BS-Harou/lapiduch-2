global.__base = __dirname + '/'

assert = require 'assert'
async = require 'async'
pgp = require('pg-promise')()
global.db = db = require __base + 'configs/postgre-config'
users = require './collections/users'
categories = require './collections/categories'
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
		users.create({
			username: settings.admin.username
			password: settings.admin.password
			sex: 'male'
			avatar: 'https://res.cloudinary.com/lapiduch/image/upload/v1470778713/Len_y.png'
			email: settings.admin.email
			perm: users.PERM.ADMIN
		}, done)
		return
,
	(done) ->

		# TODO move insert to collections/categories.coffee

		categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecárny',
			'Koníčky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicína', 'Města a obce', 'Nezatříděné',
			'Partneství a sex', 'Počítače', 'Politika', 'Programování', 'Sci-fi a fantasy', 'Sci-fi světy',
			'Sport', 'Svět kolem nás', 'Systémové', 'Televize', 'Věda a Technika', 'Vojenství a zbraně',
			'Vzdělávání a školství']

		console.log 'CREATING CATEGORIES'

		# TODO link
		db.tx (t) ->
	        queries = categoriesList.map (item) ->
	            categories.batch t, name: item, description: item
	        return t.batch queries
	    .then (data) ->
	        done null
	    .catch (err) ->
	        done err
		return
], (err) ->
	return console.log err if err
	return console.log 'DONE'


