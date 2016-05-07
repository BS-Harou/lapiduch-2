pgp = require('pg-promise')()
settings = require(__base + 'services/settings').getSettings()

db = pgp settings.postgre

module.exports = db