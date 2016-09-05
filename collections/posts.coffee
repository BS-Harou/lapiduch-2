assert = require 'assert'
moment = require 'moment'

posts =

	###*
		@return {!Promise}
	###
	getAll: (clubId) ->
		db.query('SELECT * FROM posts')
		.then (items) =>
			items.map @transformOut
			
	###*
		@param {number} clubId
		@param {!Object=} options
		@return {!Promise}
	###
	findByClub: (clubId, options = {}) ->
		if Number(options.to) is 0
			delete options.to
			delete options.from

		filterVal = options.to ? options.from
		params = { clubId, limit: 15, filterId: Number(filterVal) }
		
		# Select posts based on passed operator
		postsQueryFactory = (filter = '', order = 'DESC') ->
			"SELECT * FROM posts WHERE #{filter} club_id=${clubId} ORDER BY created_at #{order}, id #{order} LIMIT ${limit}"

		# Select posts both larger and smaller than filterId
		# This is neccesery for cases when there isn't enough posts in one direction
		if options.to? or options.from?
			bothDirQuery = """(
					#{postsQueryFactory('id >= ${filterId} AND', 'ASC')}
				) UNION (
					#{postsQueryFactory('id <= ${filterId} AND', 'DESC')} 
				)"""
		else
			bothDirQuery = postsQueryFactory()

		# Posts joined with specific user values
		postsWithUsersQuery = """
			SELECT posts.*, users.username as username, users.avatar as avatar, users.motto as motto
			FROM ( #{bothDirQuery} ) as posts
			LEFT JOIN users ON posts.user_id=users.id
		"""

		orderedQuery = if options.to
			"""
				SELECT * FROM (
					#{postsWithUsersQuery}
					ORDER BY posts.created_at ASC, posts.id ASC LIMIT ${limit}
				) as ordered ORDER BY ordered.created_at DESC, ordered.id DESC 
			"""
		else
			"""
				#{postsWithUsersQuery}
				ORDER BY posts.created_at DESC, posts.id DESC LIMIT ${limit}
			"""
		
		db.query(orderedQuery, params)
		.then (items) =>
			items.map @transformOut

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformIn: (data) ->
		title: data.title
		message: data.message
		createdAt: Date.now()
		userId: data.userId
		clubId: data.clubId

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformOut: (data) ->
		id: data.id
		title: data.title
		message: data.message
		createdAt: data.created_at
		createdAtFormatted: moment(Number(data.created_at)).format('DD.MM.YYYY h:mm:ss')
		userId: data.user_id
		clubId: data.club_id
		username: data.username
		avatar: data.avatar
		motto: data.motto

	###*
		@param {!Object} data
		@param {!Promise}
	###
	create: (data) ->
		# prevent saving two same posts in a row
		storeData = @transformIn data

		db.none("""
			INSERT INTO posts (title, message, created_at, user_id, club_id)
			VALUES(${title}, ${message}, ${createdAt}, ${userId}, ${clubId})
		""", storeData)

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transformIn data

		t.none("""
			INSERT INTO posts (title, message, created_at, user_id, club_id)
			VALUES(${title}, ${message}, ${createdAt}, ${userId}, ${clubId})
		""", storeData)


module.exports = posts