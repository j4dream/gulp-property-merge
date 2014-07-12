fs = require 'fs'
path = require 'path'
gutil = require 'gulp-util'
through = require 'through2'

getProperty = (propName, properties) ->
	tmp = propName.split '.'
	res = properties
	while tmp.length and res
		res = res[tmp.shift()]
	res

replaceProperties = (content, opt) ->
	properties = opt.properties
	lt = opt.lt || '%{{'
	gt = opt.gt || '}}%'
	if not properties
		return content
	content.replace new RegExp(lt + '([\\w\\-\\.]+)' + gt, 'g'), (full, propName) ->
		res = getProperty propName, properties
		if typeof res is 'string' then res else full

module.exports = (opt = {}) ->
	through.obj (file, enc, next) ->
		return @emit 'error', new gutil.PluginError('gulp-property-merge', 'File can\'t be null') if file.isNull()
		return @emit 'error', new gutil.PluginError('gulp-property-merge', 'Streams not supported') if file.isStream()
		content = replaceProperties file.contents.toString('utf-8'), opt
		file.contents = new Buffer content
		@push file
		next()
