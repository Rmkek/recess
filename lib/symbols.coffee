module.exports = (punk) ->
	s =
		entry:      { }
		default:    Symbol 'some default value'
		isSequence: Symbol 'some sequence of tasks'
		isEvent:    Symbol 'event.' 

	s.entry.outFile = s.entry

	punk.s = punk.symbols = s