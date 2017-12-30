process = require 'process'
vm      = require 'vm'
path    = require 'path'
Module  = require 'module'

module.exports = (code = '', dsl = {}, filename = 'eval') ->
	createContext = vm.Script.createContext ? vm.createContext

	# new context
	if vm.isContext dsl
		sandbox = dsl
	else
		sandbox = createContext()
		sandbox[k] = v for own k, v of dsl

	sandbox.global = sandbox.root = sandbox.GLOBAL = sandbox

	# paths
	sandbox.__filename  = filename
	sandbox.__dirname   = path.dirname sandbox.__filename


	if sandbox isnt global or sandbox.module or sandbox.require

		# WTF
		sandbox.module   = _module  = new Module sandbox.__filename
		sandbox.require  = _require = (path) ->	Module._load path, _module, true
		_module.filename = sandbox.__filename

		for own index, value of require
			if index not in ['paths', 'arguments', 'caller']
				_require[index] = value

		_require.paths = _module.paths = Module._nodeModulePaths process.cwd()


		_require.resolve = (request) -> Module._resolveFilename request, _module

		# some globals
		sandbox.process = process;
		sandbox.exports = sandbox.module.exports
		sandbox.Buffer = Buffer;
		sandbox.console = console;
		sandbox.setTimeout = setTimeout;
		sandbox.setInterval = setInterval;
		sandbox.setImmediate = setImmediate;
		sandbox.clearImmediate = clearImmediate;
		sandbox.clearInterval = clearInterval;
		sandbox.clearTimeout = clearTimeout;


	# run
	if sandbox is global
		vm.runInThisContext code
	else
		vm.runInContext code, sandbox
