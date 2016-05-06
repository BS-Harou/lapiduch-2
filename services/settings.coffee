yaml = require 'js-yaml'
fs   = require 'fs'

DEFAULT_SETTINGS = __base + 'default-settings.yaml'
CUSTOM_SETTINGS = __base + 'custom-settings.yaml'

fileMap = {}

settings =
	parseYaml: (file) ->
		return fileMap[file] if fileMap.hasOwnProperty file
		try
			doc = yaml.safeLoad fs.readFileSync(file, 'utf8')
		catch e
			console.log "Reading #{file} settings failed: ", e
			doc = null
		fileMap[file] = doc
		return doc

	getSettings: ->
		defaultSettings = @parseYaml DEFAULT_SETTINGS
		customSettings = @parseYaml CUSTOM_SETTINGS
		return customSettings or defaultSettings or {}


module.exports = settings
			