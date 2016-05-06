assert = require 'assert'

collection = mongodb.collection 'categories'

categories =
	getAllCategories: (cb) ->
		collection.find({}).toArray (err, cats) ->
			assert.equal null, err
			if typeof cb is 'function'
				cb cats.map (cat) -> cat.name 
			return
		return

	
	

module.exports = categories