###################
# CONNECT MODULES #
###################
chalk  = require 'chalk'
update = require 'log-update'
wrap   = require 'word-wrap'
size   = require 'window-size'

schunk = (str, len) ->
	r.join('') for r in chunk(str, len)

util = require 'util'

jst = (text) ->
	{ width } = size.get()
	wrap text, { width: width - 15 - 1, indent: '' } 

reporter = 
	map:
		space: []
		start: []
		usingConfig: []
		topSeparator: [chalk.grey '┌──────────┐']
		sections: []
		bottomSeparator: [chalk.grey '└──────────┘']
		built: []
		error: []

	nmap: ->
		[
			reporter.map.space, 
			reporter.map.start, 
			reporter.map.usingConfig, 
			reporter.map.topSeparator, 
			reporter.map.sections, 
			reporter.map.bottomSeparator, 
			reporter.map.built, 
			reporter.map.error
		]

	start: ->
		reporter.map.start.push do => ""
		reporter.map.start.push do => " #{chalk.bold reporter.time()}   #{chalk.grey '»'} #{chalk.bold 'Starting build!'}"
		reporter.render()

	time: ->
		dt = new Date

		hours = dt.getHours()
		hoursString = hours + ""
		hoursString = "0" + hoursString if hoursString.length is 1 

		minutes = dt.getMinutes()
		minutesString = minutes + ""
		minutesString = "0" + minutesString if minutesString.length is 1

		seconds = dt.getSeconds()
		secondsString = seconds + ""
		secondsString = "0" + secondsString if secondsString.length is 1 

		"#{hoursString}:#{minutesString}:#{secondsString}"

	usingConfig: (path) ->
		reporter.map.usingConfig.push do =>
			" #{chalk.bold reporter.time()}   #{chalk.grey '»'} #{chalk.bold 'Using config at'} #{chalk.bold.blue path}!"
		reporter.render()


	message: ->
		time = reporter.time()
		reporter.write do =>
			text = jst util.format arguments...
			arr = text.split '\n'
			prefix = (chalk.grey('│') + " " + chalk.bold(time) + " " + chalk.grey('│') + " " + chalk.grey("»") + " ")

			sect   = chalk.grey('│') + '          ' + chalk.grey('│') + '   '

			for num, str of arr
				if num - 0 is 0
					arr[num] = prefix + chalk.bold str
				else
					arr[num] = sect + chalk.bold str
			arr.join '\n'


	warn: ->
		time = reporter.time()
		reporter.write do =>
			text = jst util.format arguments...
			arr = text.split '\n'
			prefix = (chalk.grey('│') + " " + chalk.bold.yellow(time) + " " + chalk.grey('│') + " " + chalk.yellow("»") + " ")

			sect   = chalk.grey('│') + '          ' + chalk.grey('│') + '   '

			for num, str of arr
				if num - 0 is 0
					arr[num] = prefix + chalk.bold str
				else
					arr[num] = sect + chalk.bold str
			arr.join '\n'

	error: (err) ->
		reporter.map.error.push do =>
			f = util.format err
			arr = f.split '\n'
			arr = arr.map (s) ->
				'     ' + s
			str = chalk.grey('└─ »') + ' ' + chalk.bold(arr.join('\n')[5..])
			str
		reporter.map.bottomSeparator = [chalk.grey '├──────────┘']
		reporter.end err
		reporter.render()

	end: (error = false) ->
		time = reporter.time()
		reporter.map.built.push do =>
			if error
				suffix    = chalk.grey('│') + ' '
				timer     = chalk.bold.red(time) + ' '
				separator = '  ' + chalk.bold.red('»') + ' '
				text      = chalk.bold.red 'Unsuccessfully built!'
			else
				suffix = ' '
				timer  = chalk.bold(time) + ' '
				separator = '  ' + chalk.bold.grey('»') + ' '
				text   = chalk.bold.green 'Successfully built!'
			suffix + timer + separator + text
		reporter.render()
		process.exit()

	# BASIC MESSAGES #

	startingTask: (name) ->
		reporter.message 'Starting task ' + chalk.blue('#' + name) + '!'

	finishedTask: (name) ->
		reporter.message 'Finished task ' + chalk.blue('#' + name) + '!'

	finishedAll: ->
		reporter.message 'Finished all tasks!'

	noType: (filename) ->	
		reporter.warn 'Cannot identify type of file ' + chalk.blue(filename) + '!'

	noMin: (filename) ->	
		reporter.warn 'Cannot minify file ' + chalk.blue(filename) + '!'

	noFiles: (glob) ->
		reporter.warn 'Not found any files at entry ' + chalk.blue(glob) + '!'

	noConverter: (from, to) ->
		reporter.warn 'Not found converter for convert file ' + chalk.blue(from) + ' to ' + chalk.blue(to) + ' format!' 

	pluginsConflict: (pluginName) ->
		pl = chalk.blue(pluginName)
		reporter.warn 'Plugin "' + pl + '" conflicts with existing plugin "' + pl + '"! Falling back to first plugin.'

	write: (text) ->
		reporter.map.sections.push text
		reporter.render()

	render: ->
		map = reporter.nmap()
		array = []
		for s in map
			for p in s
				array = array.concat p
		str = array.join '\n'
		update str

module.exports = (punk) -> { reporter }
