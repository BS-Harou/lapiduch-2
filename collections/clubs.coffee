assert = require 'assert'

clubs =
	getAllClubs: (cb) ->
		###
		collection = mongodb.collection 'clubs'
		collection.find({}).toArray (err, items) ->
			assert.equal null, err
			if typeof cb is 'function'
				cb items.map (cat) ->
					name: cat.name 
					link: cat.name.replace(/\s/g, '-').toLowerCase()
			return
		###
		return

	getClubsByCategory: (catId) ->
		return

	getFavoriteClubsByUser: (userId) ->
		return

	createNewClubFromForm: (formData) ->
		return

	createNewClub: (itemData, cb) ->
		item = 
			name: itemData.clubName
			description: itemData.clubDesc
			createdAt: Date.now()

		db.none("""
			INSERT INTO clubs (name, description, created_at)
			VALUES(${name}, ${description}, ${createdAt})
		""", item)
		.then ->
			return cb null
		.catch (err) ->
			console.log 'CREATE CLUB ERROR: ', err
			return cb err
		return


module.exports = clubs