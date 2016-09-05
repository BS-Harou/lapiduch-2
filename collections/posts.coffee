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
		filters = ''
		if options.to
			filters += 'AND posts.id <= ${filterTo}'
		else if options.from
			filters += 'AND posts.id >= ${filterFrom}'

		params =  { clubId, filterFrom: Number(options.from), filterTo: Number(options.to) }
		db.query("""
			SELECT posts.*, users.username as username, users.avatar as avatar, users.motto as motto
			FROM posts LEFT JOIN users ON posts.user_id=users.id
			WHERE club_id=${clubId}
			#{filters}
			ORDER BY posts.created_at DESC, posts.id DESC
			LIMIT 5
		""", params)
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