assert = require 'assert'
MongoClient = require('mongodb').MongoClient
ObjectID = require('mongodb').ObjectID
url = 'mongodb://localhost:27017/lapiduch'


MongoClient.connect url, (err, db) ->
	assert.equal null, err

	# TODO some actions are async so they should all wait for the action before

	collections = ['users', 'categories', 'clubs', 'posts']

	# Clear old DB
	db.listCollections().forEach (collection) ->
		return unless collection.name in collections
		db.dropCollection collection.name, (err) ->
			console.log err

	
	# Create collections
	collections.forEach (name) -> db.createCollection name
	

	# Default users
	usersCollection = db.collection 'users'
	usersCollection.insert [
		username: 'admin', password: 'admin', sex: 'male', email: 'lapiduch@martinkadlec.eu', perm: 'admin'
	]

	# Default categories
	usersCollection = db.collection 'categories'
	categoriesList = ['Doprava', 'Fankluby', 'Film', 'Hry', 'Hudba', 'Humor', 'Internet', 'Kecarny', 'Konicky', 'Kultura', 'Lapiduch', 'Literatura', 'Medicina', 'Mesta a obce', 'Nezatridene', 'Partnestvi a sex', 'Pocitace', 'Politika', 'Programovani', 'Sci-fi a fantasy', 'Sci-fi svety', 'Sport', 'Svet kolem nas', 'Systemove', 'Televize', 'Veda a Technika', 'Vojenstvi a zbrane', 'Vzdelavani a skolstvi']
	categoriesMap = categoriesList.map (name) -> name: name
	usersCollection.insert categoriesMap, ->
		db.close()
	return

