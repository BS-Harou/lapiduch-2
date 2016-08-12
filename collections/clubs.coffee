assert = require 'assert'
normalize = require __base + 'services/normalize'

clubs =
	getAll: (cb) ->
		return unless typeof cb is 'function'
		db.query('SELECT * FROM clubs')
		.then (items) ->
			cb null, items.map (item) ->
				name: item.name 
				normName: item.norm_name
			return
		.catch (err) ->
			return cb err if cb
		return

	###*
		@param {string|object} ident - id or normName of a club
		@param {function} cb
	###
	find: (ident, cb) ->
		searchData =
			searchBy: if typeof ident is 'number' then 'id' else 'norm_name'
			ident: ident
		db.one("""
			SELECT clubs.*, categories.name as category_name
			FROM clubs INNER JOIN categories ON clubs.category_id=categories.id
			WHERE clubs.${searchBy~}=${ident}
		""", searchData)
		.then (item) ->
			return cb null, item
		.catch (err) ->
			return cb err
		return

	findByCategory: (catId, cb) ->
		db.query('SELECT * FROM clubs WHERE category_id=${catId}', { catId })
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
		# TODO:
		# check name duplicity (unique in postgre?)
		# check if category exists
		# insert into club_owners
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