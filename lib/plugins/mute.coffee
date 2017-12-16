module.exports = ->
	plugin = {}
	plugin.pipes =
		mute: (files)-> 
			if files
				{}
			else
				-> {}
	plugin
