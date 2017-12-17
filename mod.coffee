Mode = require('stat-mode')
defaultMode = 0o777 & ~process.umask()

normalize = (mode) ->
	called = false
	newMode = 
		owner: {}
		group: {}
		others: {}
	[
		'read'
		'write'
		'execute'
	].forEach (key) ->
		if typeof mode[key] == 'boolean'
			newMode.owner[key] = mode[key]
			newMode.group[key] = mode[key]
			newMode.others[key] = mode[key]
			called = true
		return
	if called then newMode else mode

console.log new Mode 0o777
# console.log normalize { }

