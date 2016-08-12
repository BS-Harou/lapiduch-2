global.__base = __dirname + '/'

express = require('express')
assert = require 'assert'
path = require('path')
favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
RedisStore = require('connect-redis')(session)
passport = require('passport')
helmet = require('helmet')
csurf = require('csurf')

routes =
	index: require('./routes/index')
	auth: require('./routes/auth')
	settings: require('./routes/settings')
	categories: require('./routes/categories')
	newClub: require('./routes/new-club')
	clubs: require('./routes/clubs')
app = express()

settings = require(__base + 'services/settings').getSettings()

#
# TEMPLATES
#
ECT = require 'ect'
ectRenderer = ECT(watch: true, root: __dirname + '/views', ext: '.ect')

#
# CLOUDINARY
#
require './configs/cloudinary-config'

#
# MongoDB
#

global.db = db = require __base + 'configs/postgre-config'


require(__base + 'configs/passport-config') passport

# view engine setup
app.set 'views', path.join(__base, 'views')
app.set 'view engine', 'ect'
app.engine 'ect', ectRenderer.render
# TODO get lapiduch favicon
app.use favicon(path.join(__base, 'public', 'favicon.ico'))
app.use helmet()
app.use helmet.contentSecurityPolicy
  directives: 
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'"],
    imgSrc: ["'self'", 'data:', '*'],
    sandbox: ['allow-forms', 'allow-scripts'],
    reportUri: '/report-violation', # TODO, how it works, add the route
    objectSrc: []
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()
app.use require('stylus').middleware(path.join(__base, 'public'))
app.use express.static(path.join(__base, 'public'))
app.use session({
	store: new RedisStore settings.redis
	secret: settings.sessions.secret
	resave: false
	saveUninitialized: false
	name: 'sesna' 
})
app.use passport.initialize()
app.use passport.session()
app.use csurf()
app.use (req, res, next) ->
	if user = req.user
		res.locals.user =
			username: user.username
			avatar: user.avatar
	res.locals.csrfToken = req.csrfToken()
	next()
	return
app.use '/bootstrap', express.static(__base + '/node_modules/bootstrap/dist/')
app.use '/', routes.index
app.use '/auth', routes.auth
app.use '/nastaveni', routes.settings
app.use '/kategorie', routes.categories
app.use '/novyklub', routes.newClub
app.use '/kluby', routes.clubs

# catch 404 and forward to error handler
app.use (req, res, next) ->
	err = new Error('Not Found')
	err.status = 404
	next err
	return

# error handlers
# development error handler
# will print stacktrace
if app.get('env') == 'development'
	app.use (err, req, res, next) ->
		res.status err.status or 500
		res.render 'error',
			message: err.message
			error: err
		return

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
	res.status err.status or 500
	res.render 'error',
		message: err.message
		error: {}
	return
module.exports = app
