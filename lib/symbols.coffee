module.exports = (recess) ->
	s =
		entry:      { }
		default:    Symbol 'some default value'
		isSequence: Symbol 'some sequence of tasks'
		isEvent:    Symbol 'event.' 

	s.entry.outFile = s.entry

	recess.s = recess.symbols = s