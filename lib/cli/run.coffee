[run, func] = do ->
	class BrowserError extends Error
		constructor: ->
			super()

			@name    = 'BrowserError'
			@message = 'This module works only in Node.JS. Try to use "vm-browserify".'

			if Error.captureStackTrace
				Error.captureStackTrace @, BrowserError
			else
				@stack = new Error().stack

	be = -> throw new BrowserError()

	try 
		process = require 'process'
	catch
		be()

	unless process?.versions?.node?
		be()



	vm      = require 'vm'
	path    = require 'path'
	Module  = require 'module'
	fs      = require 'fs'

	toSetting = (settings) ->
		code     = settings.code or settings.source or settings.function or settings.func or settings.f or settings.do
		dsl      = settings.dsl or settings.context or settings.object or settings
		filename = settings.filename or settings.file
		[code, dsl, filename]

	isNative = do ->
		toString = Object.prototype.toString
		fnToString = Function.prototype.toString
		reHostCtor = /^\[object .+?Constructor\]$/

		reNative = RegExp '^' +
			(String(toString)
			.replace(/[.*+?^${}()|[\]\/\\]/g, '\\$&')
			.replace(/toString|(function).*?(?=\\\()| for .+?(?=\\\])/g, '$1.*?') + '$')

		return (value) ->
			type = typeof value
			if type is 'function'
				return reNative.test(fnToString.call(value))
			else
				return (value and type is 'object' and reHostCtor.test(toString.call(value))) or false
  
	# skeleton stealed from CoffeeScript x)
	core = (code = '', dsl = {}, filename = 'eval') ->

		if typeof code is 'function'
			return wrap(code, dsl)()

		if typeof code not in ['string', 'number']
			throw new TypeError 'Not a string or number!'

		code = code + ""

		# new context
		if vm.isContext dsl
			sandbox = dsl
		else
			sandbox = vm.createContext()
			sandbox[k] = v for own k, v of dsl

		sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox

		# paths
		sandbox.__filename  = filename
		sandbox.__dirname   = path.dirname sandbox.__filename

		if sandbox isnt global or sandbox.module or sandbox.require

			# commonjs module
			sandbox.module   = new Module sandbox.__filename
			sandbox.require  = (path) -> 
				Module._load path, sandbox.module, true

			sandbox.module.filename = sandbox.__filename

			# merge require methods
			for own index, value of require
				if index not in ['paths', 'arguments', 'caller']
					sandbox.require[index] = value

			sandbox.require.paths = sandbox.module.paths = 
				Module._nodeModulePaths (
					process?.cwd?() or './'
				)

			sandbox.require.resolve = (request) -> 
				Module._resolveFilename request, _module

			# some globals
			sandbox.process        ?= process
			sandbox.exports        ?= sandbox.module.exports
			sandbox.Buffer         ?= Buffer
			sandbox.console        ?= console
			sandbox.setTimeout     ?= setTimeout
			sandbox.setInterval    ?= setInterval
			sandbox.setImmediate   ?= setImmediate
			sandbox.clearImmediate ?= clearImmediate
			sandbox.clearInterval  ?= clearInterval
			sandbox.clearTimeout   ?= clearTimeout

		# run
		return vm.runInContext code, sandbox

	run = (settings) ->
		if (arguments.length > 1) or (typeof settings in ['function', 'string'])
			return core arguments...
		else
			[code, dsl, filename] = toSetting settings

			# try to read file
			if not code and filename
				code = fs.readFileSync filename
				unless code
					throw new Error 'Not found file "' + filename + '"!'

			return core code, dsl, filename



	wrap = (settings) ->
		_args = arguments
		args = (arg for arg in _args)
		if (args.length > 1) or (typeof settings in ['function', 'string'])

			f = args[0] or ->

			if typeof f isnt 'function'
				throw new TypeError 'Not a function!'

			if isNative f
				throw new TypeError 'Function must be not native!'

			code = "(" + f.toString() + ")"
			run code, args[1..]...

		else

			[f, dsl, filename] = toSetting settings

			code = "(" + f.toString() + ")"
			run code, dsl, filename

	[run, wrap]

module.exports = run
