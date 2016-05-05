express = require('express')
assert = require 'assert'
path = require('path')
favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
session = require('express-session')
passport = require('passport')
LocalStrategy = require('passport-local').Strategy
helmet = require('helmet')

routes = require('./routes/index')
auth = require('./routes/auth')
app = express()

#
# TEMPLATES
#
ECT = require 'ect'
ectRenderer = ECT(watch: true, root: __dirname + '/views', ext: '.ect');

#
# MongoDB
#

MongoClient = require('mongodb').MongoClient
ObjectID = require('mongodb').ObjectID
url = 'mongodb://localhost:27017/lapiduch'
global.mongodb = mongodb = null

MongoClient.connect url, (err, db) ->
	assert.equal null, err
	console.log 'Connected to mongo server'
	db.on 'close', ->
		mongodb = null
		console.log 'Disconnected from mongo server'
	global.mongodb = mongodb = db
	return


#
# PASSPORT
#
# userMap = {}
# userMap['1'] = { id: 1, username: 'Len_y' }
passport.use new LocalStrategy (username, password, done) ->
	collection = mongodb.collection 'users'
	collection.findOne { username: username }, (err, user) ->
		return done err  if err
		return done null, false, message: 'Incorrect username.' unless user
		return done null, false, message: 'Incorrect password.' unless user.password is password
		return done null, user
	return

passport.serializeUser (user, done) ->
	done null, user._id.toHexString()

passport.deserializeUser (id, done) ->
	binId = ObjectID.createFromHexString(id)

	collection = mongodb.collection 'users'
	collection.findOne { _id: binId }, (err, user) ->
		return done err  if err
		# TODO, user is null
		return done null, user
	return


# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'ect'
app.engine 'ect', ectRenderer.render
# TODO get lapiduch favicon
#app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
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
app.use require('stylus').middleware(path.join(__dirname, 'public'))
app.use express.static(path.join(__dirname, 'public'))
# TODO, move secret and name to env config
app.use session({ secret: 'keep scrolling', resave: false, saveUninitialized: false, name: 'sesna' })
app.use passport.initialize()
app.use passport.session()
app.use '/', routes
app.use '/auth', auth

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
