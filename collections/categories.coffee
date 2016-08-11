assert = require 'assert'
normalize = require __base + 'services/normalize'

categories =
	getAll: (cb) ->
		return unless typeof cb is 'function'
		db.query('SELECT * FROM categories')
		.then (storeData) ->
			cb null, storeData.map (item) ->
				id: item.id
				name: item.name
				normName: item.norm_name
			return
		.catch (err) ->
			return cb err if cb
		return

	###*
		@param {string|object} ident - id or normName of category
		@param {function} cb
	###
	find: (ident, cb) ->
		searchData =
			searchBy: if typeof ident is 'number' then 'id' else 'normName'
			ident: ident
		db.one("SELECT * FROM categories WHERE ${searchBy}=${ident}", searchData)
		.then (category) ->
			return cb null, category
		.catch (err) ->
			return cb err
		return

	transform: (data) ->
		name: data.name
		normName: normalize data.name
		description: data.description
		createdAt: Date.now()

	###*
		@param {!Object} data
		@param {function} cb
	###
	create: (data, cb) ->
		storeData = @transform data

		db.none("""
			INSERT INTO categories (name, norm_name, description, created_at)
			VALUES(${name}, ${normName}, ${description}, ${createdAt})
		""", storeData)
		.then ->
			return unless typeof cb is 'function'
			return cb null
		.catch (err) ->
			return unless typeof cb is 'function'
			return cb err if cb
		return

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transform data
		return t.none("""
			INSERT INTO categories (name, norm_name, description, created_at)
			VALUES(${name}, ${normName}, ${description}, ${createdAt})
		""", storeData)

module.exports = categories