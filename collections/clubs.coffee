assert = require 'assert'
normalize = require __base + 'services/normalize'

FAVORITES_TYPES =
	FAV:
		key: 'fav'
		type: 1
		text: 'Oblíbené'
	MORE_FAV:
		key: 'more_fav'
		type: 2
		text: 'Oblíbenější'
	MOST_FAV:
		key: 'most_fav'
		type: 3
		text: 'Nejoblíbenější'

FAVORITES_TYPES_LIST = [
	FAVORITES_TYPES.FAV
	FAVORITES_TYPES.MORE_FAV
	FAVORITES_TYPES.MOST_FAV
]

clubs =

	###*
		@return {!Promise}
	###
	getAll: ->
		db.query("""
			SELECT * FROM clubs
		""")
		.then (items) =>
			items.map @transformOut

	###*
		@return {!Promise}
	###
	getAllInCategories: ->
		db.query("""
			SELECT clubs.*, categories.name as category_name, categories.norm_name as category_norm_name
			FROM clubs INNER JOIN categories ON clubs.category_id=categories.id
			ORDER BY categories.norm_name ASC
		""")
		.then (clubs) =>
			clubs = clubs.map @transformOut
			categories = {}
			clubs.forEach (club) ->
				category = categories[club.categoryNormName]
				category or= name: club.categoryName, clubs: []
				category.clubs.push club
				categories[club.categoryNormName] = category
			categories

	###*
		@param {number} userId
		@return {!Promise}
	###
	findFavorites: (userId) ->
		queryData =
			userId: userId
		db.query("""
			SELECT clubs.*, favorites.type as favorites_type
			FROM clubs INNER JOIN favorites ON clubs.id=favorites.club_id
			WHERE favorites.user_id=${userId}
			ORDER BY favorites.type DESC, clubs.norm_name ASC
		""", queryData)
		.then (clubs) =>
			clubs = clubs.map @transformOut
			favoritesMap = {}
			clubs.forEach (club) ->
				favorites = favoritesMap[club.favoritesTypeData.key]
				favorites or= name: club.favoritesTypeData.text, clubs: []
				favorites.clubs.push club
				favoritesMap[club.favoritesTypeData.key] = favorites
			favoritesMap

	###*
		@param {string|number} ident - id or normName of a club
		@return {!Promise}
	###
	find: (ident) ->
		searchData =
			searchBy: if typeof ident is 'number' then 'id' else 'norm_name'
			ident: ident
		db.one("""
			SELECT clubs.*, categories.name as category_name, categories.norm_name as category_norm_name
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

	###*
		@param {number} catId
		@return {!Promise}
	###
	findByUser: (userId) ->
		db.query("""
			SELECT * FROM clubs
			INNER JOIN clubs_owners ON clubs.id=clubs_owners.club_id
			WHERE user_id=${userId}
		""", { userId })
		.then (items) =>
			items.map @transformOut

	###*
		@param {!Object} data {search, searchIn}
		@return {!Promise}
	###
	findByContent: (data) ->
		condition = switch data.searchIn
			when 'name' then "name LIKE '%${search#}%'"
			when 'description' then "description LIKE '%${search#}%'"
			else "name LIKE '%${search#}%' OR description LIKE '%${search#}%'"
		db.query("SELECT * FROM clubs WHERE #{condition}", data)
		.then (items) =>
			items.map @transformOut


	findFavoritesByUser: (userId) ->
		return

	###*
		@param {data} formData
		@return {!Promise}
	###
	createFromForm: (formData, user) ->
		@create
			name: formData.clubName
			categoryId: formData.clubCategory
			description: formData.clubDesc
			userId: user.id

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
		userId: data.userId

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
		categoryNormName: data.category_norm_name
		favoritesType: data.favorites_type
		favoritesTypeData: FAVORITES_TYPES_LIST[data.favorites_type - 1]

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
		# check if category exists
		# insert into club_owners
		storeData = @transformIn data

		db.tx (t) ->
			t.batch [
				t.none("""
					INSERT INTO clubs (name, norm_name, category_id, description, created_at)
					VALUES(${name}, ${normName}, ${categoryId}, ${description}, ${createdAt})
				""", storeData)
			,
				t.none("""
					INSERT INTO clubs_owners (user_id, club_id, level)
					VALUES(${userId}, currval('clubs_id_seq'), 6)
				""", storeData)
			]



module.exports = clubs