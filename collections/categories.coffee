assert = require 'assert'
normalize = require __base + 'services/normalize'

categories =

	###*
		@return {!Promise}
	###
	getAll: ->
		db.query('SELECT * FROM categories')
		.then (storeData) =>
			storeData.map @transformOut

	###*
		@param {string|object} ident - id or normName of a category
		@return {!Promise}
	###
	find: (ident) ->
		searchData =
			searchBy: if typeof ident is 'number' then 'id' else 'norm_name'
			ident: ident
		db.one("SELECT * FROM categories WHERE ${searchBy~}=${ident}", searchData)
		.then (item) =>
			@transformOut item 

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformIn: (data) ->
		name: data.name
		normName: normalize data.name
		description: data.description
		createdAt: Date.now()

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformOut: (data) ->
		id: data.id
		name: data.name
		normName: data.norm_name
		description: data.description
		createdAt: data.created_at

	###*
		@param {!Object} data
		@param {!Promise}
	###
	create: (data) ->
		storeData = @transformIn data

		db.none("""
			INSERT INTO categories (name, norm_name, description, created_at)
			VALUES(${name}, ${normName}, ${description}, ${createdAt})
		""", storeData)

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transformIn data
		t.none("""
			INSERT INTO categories (name, norm_name, description, created_at)
			VALUES(${name}, ${normName}, ${description}, ${createdAt})
		""", storeData)

module.exports = categories