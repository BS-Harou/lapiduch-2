assert = require 'assert'

history =

	###*
		@return {!Promise}
	###
	getAll: ->
		db.query('SELECT * FROM categories')
		.then (storeData) =>
			storeData.map @transformOut

	###*
		@param {number} userId
		@param {number} clubId
		@return {!Promise}
	###
	find: (userId, clubId) ->
		searchData =
			userId: userId
			clubId: clubId
		db.oneOrNone("""
			SELECT * FROM history WHERE user_id=${userId} AND club_id=${clubId}
		""", searchData)
		.then (item) =>
			return null unless item
			@transformOut item 

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformIn: (data) ->
		userId: data.userId
		clubId: data.clubId
		postId: data.postId

	###*
		@param {!Object} data
		@return {!Object}
	###
	transformOut: (data) ->
		id: data.id
		userId: data.user_id
		clubId: data.club_id
		postId: data.post_id

	###*
		@param {!Object} data
		@return {!Promise}
	###
	visitClub: (data) ->
		storeData = @transformIn data
		@find storeData.userId, storeData.clubId
		.then (item) =>
			return @create data unless item
			return if data.postId <= item.postId
			@update data

	###*
		@param {!Object} data
		@return {!Promise}
	###
	remove: (data) ->
		storeData = @transformIn data
		db.none("""
			DELETE FROM history
			WHERE user_id=${userId} AND club_id=${clubId}
		""", storeData)

	###*
		@param {!Object} data
		@return {!Promise}
	###
	update: (data) ->
		storeData = @transformIn data
		db.none("""
			UPDATE INTO history
			SET post_id=${postId}
			WHERE user_id=${userId} AND club_id=${clubId}
		""", storeData)

	###*
		@param {!Object} data
		@param {!Promise}
	###
	create: (data) ->
		storeData = @transformIn data

		db.none("""
			INSERT INTO history (user_id, club_id, post_id)
			VALUES(${userId}, ${clubId}, ${postId})
		""", storeData)

	###*
		@param {!Object} t transaction
		@param {!Object} data
	###
	batch: (t, data) ->
		storeData = @transformIn data
		t.none("""
			INSERT INTO history (user_id, club_id, post_id)
			VALUES(${userId}, ${clubId}, ${postId})
		""", storeData)

module.exports = history