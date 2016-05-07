global.__base = __dirname + '/'

assert = require 'assert'
async = require 'async'
db = require __base + 'configs/postgre-config'
users = require './collections/users'
settings = require(__base + 'services/settings').getSettings()


collections = ['users', 'categories', 'clubs', 'posts']

async.waterfall [
	(done) ->
		# Clear old DB
		db.listCollections().toArray done
		return
,
	(mongoCollections, done) ->
		async.each mongoCollections, (collection, cb) ->
			return cb() unless collection.name in collections
			console.log 'DROPING COL', collection.name
			db.dropCollection collection.name, cb
		, done
		return
,
	(done) ->
		# Create collections
		async.each collections, (name, cb) ->
			console.log 'CREATING COL', name
			db.createCollection name, cb
			return
		, done
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
		catCollection = db.collection 'categories'

		categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny',
			'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene',
			'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety',
			'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane',
			'Vzdelavani a skolstvi']

		console.log 'CREATING CATEGORIES'
		categoriesMap = categoriesList.map (name) -> name: name
		catCollection.insert categoriesMap, done
		return
], (err) ->
	console.log err if err
	db.close()
	console.log 'DONE'
	return
return

