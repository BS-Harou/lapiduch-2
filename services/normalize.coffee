removeDiacritics = require('diacritics').remove

###*
	@param {string} str
	@return {string}
###
normalize = (str) ->
	str = removeDiacritics str
	str = str.replace /\s+/g, '-'
	str = str.toLowerCase()
	str = str.replace /[^a-z0-9\-_\.,+]/g, ''
	str

module.exports = normalize