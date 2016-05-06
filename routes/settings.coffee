express = require 'express'
multer = require 'multer'
users = require __base + 'collections/users'
settings = require(__base + 'services/settings').getSettings()
router = express.Router()

multerStorage = multer.memoryStorage()
uploader = multer({
	storage: multerStorage
	limits: fileSize: settings.max_avatar_size, files: 1
	onFileUploadStart: (file) ->
		mimeCheck = file.mimetype in ['image/jpg', 'image/jpeg', 'image/png', 'image/gif', 'image/webp']
		extCheck = file.extension in ['jpg', 'jpeg', 'png', 'gif', 'webp']
		mimeCheck and extCheck
})

router.get '/', (req, res, next) ->
	return next() unless req.user
	params =
		title: 'Nastavení'
		csrfToken: req.csrfToken()
	if req.user
		params.user = username: req.user.username, avatar: req.user.avatar
	res.render 'settings', params

router.post '/avatar', uploader.single('avatar'), (req, res, next) ->
	return next() unless req.user
	users.uploadAvatar req.file.buffer, req.user, (err) ->
		res.redirect '/nastaveni'


module.exports = router
