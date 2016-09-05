assert = require 'assert'
moment = require 'moment'
posts =
			
	###*
		@param {number} clubId
		@param {!Object=} options
		@return {!Promise}
	###
	findByUser: (userId, options = {}) ->
		filters = ''
		if options.to
			filters += 'AND mails.id <= ${filterTo}'
		else if options.from
			filters += 'AND mails.id >= ${filterFrom}'

		params =  { userId, filterFrom: Number(options.from), filterTo: Number(options.to) }
		db.query("""
			SELECT mails.*, users.username as username, users.avatar as avatar, users.motto as motto
			FROM mails LEFT JOIN users ON mails.from_user_id=users.id OR mails.to_user_id=users.id
			WHERE mails.user_id=${userId}
			AND users.id<>mails.user_id
			#{filters}
			ORDER BY mails.created_at DESC, mails.id DESC
			LIMIT 15
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
		fromUserId: data.fromUserId
		toUserId: data.toUserId

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
		fromUserId: data.from_user_id
		toUserId: data.to_user_id
		dir: if data.user_id is data.from_user_id then 'pro' else 'od'
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

		db.tx (t) ->
			t.batch [
				t.none("""
					INSERT INTO mails (title, message, created_at, user_id, from_user_id, to_user_id)
					VALUES(${title}, ${message}, ${createdAt}, ${fromUserId}, ${fromUserId}, ${toUserId})
				""", storeData)
			,
				t.none("""
					INSERT INTO mails (title, message, created_at, user_id, from_user_id, to_user_id)
					VALUES(${title}, ${message}, ${createdAt}, ${toUserId}, ${fromUserId}, ${toUserId})
				""", storeData)
			]

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transformIn data

		t.none("""
			INSERT INTO mails (title, message, created_at, user_id, from_user_id, to_user_id)
			VALUES(${title}, ${message}, ${createdAt}, ${fromUserId}, ${fromUserId}, ${toUserId})
		""", storeData)


module.exports = posts