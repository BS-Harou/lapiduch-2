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

	createNewClub: (clubData) ->
		return

module.exports = clubs