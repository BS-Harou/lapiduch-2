assert = require 'assert'

posts =
	getAll: (clubId, fromId, cb) ->
		# SELECT * FROM posts WHERE club_id = ${clubId} AND id >= ${fromId} LIMIT ${userSettingsPostPerPage}
		return

	create: (data, cb) ->
		storeData = 
			title: data.title
			message: data.message
			createdAt: Date.now()
			userId: data.userId
			clubId: data.clubId

		db.none("""
			INSERT INTO posts (title, message, created_at, user_id, club_id)
			VALUES(${title}, ${message}, ${createdAt}, ${userId}, ${clubId})
		""", storeData)
		.then ->
			return cb null
		.catch (err) ->
			console.log 'CREATE POST ERROR: ', err
			return cb err
		return


module.exports = posts