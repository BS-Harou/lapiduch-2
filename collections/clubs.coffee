assert = require 'assert'
normalize = require __base + 'services/normalize'

clubs =
	getAll: (cb) ->
		return unless typeof cb is 'function'
		db.query('SELECT * FROM clubs')
		.then (items) ->
			cb null, items.map (item) ->
				name: item.name 
				nornName: item.norm_name
			return
		.catch (err) ->
			return cb err if cb
		return

	findByCategory: (catIdent, cb) ->
		db.query('SELECT * FROM clubs WHERE category_id=${ident}', { ident })
		.then (items) ->
			cb null, items.map (item) ->
				name: item.name 
				link: item.norm_name
			return
		.catch (err) ->
			return cb err if cb
		return

	findFavoritesByUser: (userId) ->
		return

	createFromForm: (formData) ->
		return

	create: (data, cb) ->
		# check name duplicity (unique in postgre?)
		# check if category exists
		storeData = 
			name: data.clubName
			categoryId: data.clubCategory
			normName: normalize data.clubName
			description: data.clubDesc
			createdAt: Date.now()

		db.none("""
			INSERT INTO clubs (name, norm_name, category_id, description, created_at)
			VALUES(${name}, ${normName}, ${categoryId}, ${description}, ${createdAt})
		""", storeData)
		.then ->
			return cb null
		.catch (err) ->
			console.log 'CREATE CLUB ERROR: ', err
			return cb err
		return


module.exports = clubs