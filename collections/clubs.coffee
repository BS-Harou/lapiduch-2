assert = require 'assert'
normalize = require __base + 'services/normalize'

clubs =

	###*
		@return {!Promise}
	###
	getAll: ->
		db.query('SELECT * FROM clubs')
		.then (items) =>
			items.map @transformOut

	###*
		@param {string|number} ident - id or normName of a club
		@return {!Promise}
	###
	find: (ident) ->
		searchData =
			searchBy: if typeof ident is 'number' then 'id' else 'norm_name'
			ident: ident
		db.one("""
			SELECT clubs.*, categories.name as category_name
			FROM clubs INNER JOIN categories ON clubs.category_id=categories.id
			WHERE clubs.${searchBy~}=${ident}
		""", searchData)
		.then (item) =>
			@transformOut item

	###*
		@param {number} catId
		@return {!Promise}
	###
	findByCategory: (catId) ->
		db.query('SELECT * FROM clubs WHERE category_id=${catId}', { catId })
		.then (items) =>
			items.map @transformOut

	findFavoritesByUser: (userId) ->
		return

	###*
		@param {data} formData
		@return {!Promise}
	###
	createFromForm: (formData) ->
		@create
			name: formData.clubName
			categoryId: formData.clubCategory
			description: formData.clubDesc

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformIn: (data) ->
		name: data.name
		categoryId: data.categoryId
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
		createdAt: data.created_at
		description: data.description
		categoryId: data.category_id
		categoryName: data.category_name

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transformIn data

		t.none("""
			INSERT INTO clubs (name, norm_name, category_id, description, created_at)
			VALUES(${name}, ${normName}, ${categoryId}, ${description}, ${createdAt})
		""", storeData)

	###*
		@param {!Object} data
		@param {!Promise}
	###
	create: (data) ->
		# TODO:
		# check name duplicity (unique in postgre?)
		# check if category exists
		# insert into club_owners
		storeData = @transformIn data

		db.none("""
			INSERT INTO clubs (name, norm_name, category_id, description, created_at)
			VALUES(${name}, ${normName}, ${categoryId}, ${description}, ${createdAt})
		""", storeData)

module.exports = clubs