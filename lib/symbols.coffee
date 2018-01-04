module.exports = (punk) ->
	s =
		entry:      { }
		default:    Symbol 'Some default value.'
		isSequence: Symbol 'Some sequence of tasks.'
		isEvent:    Symbol 'Event.' 
		
	s.entry.outFile = s.entry

	punk.s = punk.symbols = s