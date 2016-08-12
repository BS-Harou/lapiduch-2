assert = require 'assert'

posts =
	getAll: (clubId, cb) ->
		return unless typeof cb is 'function'
		db.query('SELECT * FROM posts')
		.then (items) ->
			cb null, items
			return
		.catch (err) ->
			return cb err if cb
		return

	findByClub: (clubId, cb) ->
		db.query("""
			SELECT posts.*, users.username as username, users.avatar as avatar
			FROM posts LEFT JOIN users ON posts.user_id=users.id
			WHERE club_id=${clubId}
			ORDER BY posts.created_at DESC
			LIMIT 15
		""", { clubId })
		.then (items) ->
			cb null, items
			return
		.catch (err) ->
			return cb err if cb
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