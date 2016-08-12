yaml = require 'js-yaml'
fs   = require 'fs'

DEFAULT_SETTINGS = __base + 'default-settings.yaml'
CUSTOM_SETTINGS = __base + 'custom-settings.yaml'

fileMap = {}

settings =
	replaceVariable: (str) ->
		str.replace /<\%= ENV\[\'(\w+)\'\] \%>/, (all, envVar) -> process.env[envVar]

	replaceVariables: (obj) ->
		for id, item of obj
			obj[id] = @replaceVariable item if typeof item is 'string'
			@replaceVariables item if typeof item is 'object'
		return

	parseYaml: (file) ->
		return fileMap[file] if fileMap.hasOwnProperty file
		try
			doc = yaml.safeLoad fs.readFileSync(file, 'utf8')
		catch e
			console.log "Reading #{file} settings failed: ", e
			doc = null
		@replaceVariables doc
		fileMap[file] = doc
		return doc

	getSettings: ->
		defaultSettings = @parseYaml DEFAULT_SETTINGS
		customSettings = @parseYaml CUSTOM_SETTINGS
		return customSettings or defaultSettings or {}


module.exports = settings
