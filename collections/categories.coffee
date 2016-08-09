assert = require 'assert'

categories =
	getAllCategories: (cb) ->
		db.query('SELECT * FROM categories')
		.then (cats) ->
			if typeof cb is 'function'
				cb null, cats.map (cat) ->
					name: cat.name 
					link: cat.name.replace(/\s/g, '-').toLowerCase()
			return
		.catch (err) ->
			return cb err if cb
		return

module.exports = categories