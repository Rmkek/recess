###################
# CONNECT MODULES #
###################
chalk  = require 'chalk'
update = require 'log-update'
wrap   = require 'word-wrap'
size   = require 'window-size'

reporter = {}

# HELPERS

schunk = (str, len) ->
	r.join('') for r in chunk(str, len)

util = require 'util'

jst = (text) ->
	{ width } = size.get()
	w = wrap text, { width: width - 15 - 1, indent: '' } 
	w
	
funcs = {}

ex = (s, f) ->
	reporter.map[s] = [] unless reporter.map[s]		
	funcs[s] = [] unless funcs[s]		
	r = f()
	reporter.map[s].push r
	funcs[s].push f

updateMap = ->
	reporter.map = {}
	for name, value of funcs
		reporter.map[name] = (f() for f in value)
	reporter.render()

process.stdout.on 'resize', updateMap


module.exports = (punk) ->
	reporter = 
		map:
			space:           []
			start:           []
			usingConfig:     []
			topSeparator:    []
			sections:        []
			bottomSeparator: []
			built:           []
			exited:          []
			error:           []

		nmap: ->
			[
				reporter.map.space 
				reporter.map.start
				reporter.map.usingConfig
				reporter.map.topSeparator
				reporter.map.sections
				reporter.map.bottomSeparator
				reporter.map.built
				reporter.map.exited
				reporter.map.error
			]
			# throw util.format r

		production: ->
			if punk.production
				' production'
			else
				''

		start: ->
			ex 'start', => ""
			ex 'start', => 
				" #{chalk.bold reporter.time()}   #{chalk.grey '»'} #{chalk.bold jst 'Starting' + @production() + ' build!'}"
			reporter.render()

		startWatch: ->
			ex 'start', => ""
			ex 'start', => " #{chalk.bold reporter.time()}   #{chalk.grey '»'} #{chalk.bold jst 'Starting watch!'}"
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
			ex 'usingConfig', =>
				u = jst "#{chalk.bold 'Using config at'} #{chalk.bold.blue path}!"
				" #{chalk.bold reporter.time()}   #{chalk.grey '»'} #{u}"
			reporter.render()


		message: ->
			time = reporter.time()
			reporter.write =>
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
			reporter.write =>
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
			ex 'error', =>
				f = util.format err
				arr = f.split '\n'
				arr = arr.map (s) ->
					jst '     ' + s
				str = chalk.grey('└─ »') + ' ' + chalk.bold(arr.join('\n')[5..])
				str
			reporter.map.bottomSeparator = [chalk.grey '├──────────┘']
			reporter.end err
			reporter.render()

		end: (error = false) ->
			time = reporter.time()
			ex 'built', =>
				if error
					suffix    = chalk.grey('│') + ' '
					timer     = chalk.bold.red(time) + ' '
					separator = '  ' + chalk.bold.red('»') + ' '
					text      = jst chalk.bold.red 'Unsuccessfully built!'
				else
					suffix = ' '
					timer  = chalk.bold(time) + ' '
					separator = '  ' + chalk.bold.grey('»') + ' '
					text   = jst chalk.bold.green 'Successfully built!'
				suffix + timer + separator + text
			reporter.render()
			process.exit()

		# BASIC MESSAGES #

		task: (task) -> chalk.blue '#' + task
		file: (file) -> chalk.blue file

		startingTask: (name) ->
			reporter.message 'Starting task ' + reporter.task(name) + '!'

		finishedTask: (name) ->
			reporter.message 'Finished task ' + reporter.task(name) + '!'

		changed: (name) ->
			reporter.message 'Updated file ' + reporter.file(name) + '!'

		finishedAll: ->
			reporter.message 'Finished all tasks!'

		noType: (filename) ->	
			reporter.warn 'Cannot identify type of file ' + reporter.file(filename) + '!'

		noMin: (filename) ->	
			reporter.warn 'Cannot minify file ' + reporter.file(filename) + '!'

		noFiles: (glob) ->
			reporter.warn 'Not found any files at entry ' + reporter.file(glob) + '!'

		noConverter: (from, to) ->
			reporter.warn 'Not found converter for convert file ' + chalk.blue(from) + ' to ' + chalk.blue(to) + ' format!' 

		pluginsConflict: (pluginName) ->
			pl = chalk.blue(pluginName)
			reporter.warn 'Plugin "' + pl + '" conflicts with existing plugin "' + pl + '"! Falling back to first plugin.'

		pluginNotFound: (plugin) ->
			if plugin
				reporter.error new Error 'Not found plugin ' + plugin + '!'
			else
				reporter.error new Error 'Not found plugin!'

		tasksNotFound: (tasks) ->
			reporter.warn "Task(s) #{reporter.task tasks} not found!"


		write: (text) ->
			ex 'sections', text
			reporter.render()

		render: ->
			map = reporter.nmap()
			map = for m in map
				if m then m else []	

			array = []
			for devnull, s of map
				for p in s
					array = array.concat p
			str = array.join '\n'
			update str

	ex 'topSeparator',    => chalk.grey '┌──────────┐'
	ex 'bottomSeparator', => chalk.grey '└──────────┘'

	punk.reporter = reporter
	punk.r        = reporter

