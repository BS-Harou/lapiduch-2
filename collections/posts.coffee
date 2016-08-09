assert = require 'assert'

posts =
	getPosts: (clubId, fromId, cb) ->
		# SELECT * FROM posts WHERE club_id = ${clubId} AND id >= ${fromId} LIMIT ${userSettingsPostPerPage}
		return


module.exports = posts