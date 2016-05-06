cloudinary = require 'cloudinary'
settings = require(__base + 'services/settings').getSettings()

# TODO does config actually return anything?
conf = cloudinary.config settings.cloudinary

module.exports = conf