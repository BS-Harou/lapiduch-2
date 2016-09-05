global.__base = __dirname + '/'

assert = require 'assert'
async = require 'async'
pgp = require('pg-promise')()
global.db = db = require __base + 'configs/postgre-config'
users = require './collections/users'
categories = require './collections/categories'
clubs = require './collections/clubs'
posts = require './collections/posts'
settings = require(__base + 'services/settings').getSettings()


collections = ['users', 'categories', 'clubs', 'posts']

async.waterfall [
	(done) ->
		# Recreate DB
		console.log 'RECREATING SCHEMA AND TABLES'
		db.query(new pgp.QueryFile('restart-db.sql', { minify: true }))
		.then ->
			done null
		.catch (err) ->
			done err
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
			activate: ''
		})
		.then -> done null
		.catch done
		return
,
	(done) ->
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
,
	(done) ->
		console.log 'CREATING CLUBS'

		clubsList = [
			name: 'Chyby',
			description: 'Narazili jste na lapiduchu na chybu?'
		,
			name: 'Potize s hesly',
			description: 'Nedari se vam prihlasit na lapiduch?'
		,
			name: 'FAQ',
			description: 'Casto kladene otazky'
		,
			name: 'Ikonky'
			description: 'Proc jsme meli lub na ikonky? Nevi nekdo?'
		,
			name: 'Navrhy a stiznosti'
			description: 'Mate napad? Ajaj.'
		]

		# TODO link
		db.tx (t) ->
			queries = clubsList.map (item) ->
				item.categoryId = 11 # TODO: make sure the id is 'Lapiduch' category
				# TODO: item.clubOwner = 1
				clubs.batch t, item
			return t.batch queries
		.then (data) ->
			done null
		.catch (err) ->
			done err
		return
,
	(done) ->
		console.log 'CREATING POSTS'

		# TODO link
		db.tx (t) ->
			queries = for i in [1..30]
				posts.batch t, { title: i, message: "Zprava #{i}", clubId: 1, userId: 1 }
			return t.batch queries
		.then (data) ->
			done null
		.catch (err) ->
			done err
		return
,

], (err) ->
	return console.log err if err
	return console.log 'DONE'


