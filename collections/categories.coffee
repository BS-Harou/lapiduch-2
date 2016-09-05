assert = require 'assert'
normalize = require __base + 'services/normalize'

categories =

	###*
		@return {!Promise}
	###
	getAll: ->
		db.query """
			SELECT categories.*, COUNT(clubs.*) as clubs_count FROM categories
			LEFT JOIN clubs ON categories.id=clubs.category_id
			GROUP BY categories.id
			ORDER BY categories.norm_name ASC
		"""
		.then (items) =>
			items.map @transformOut

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
			return null unless item
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
		clubsCount: data.clubs_count

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