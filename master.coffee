cluster = require 'cluster'
stopSignals = [
	'SIGHUP', 'SIGINT', 'SIGQUIT', 'SIGILL', 'SIGTRAP', 'SIGABRT',
	'SIGBUS', 'SIGFPE', 'SIGUSR1', 'SIGSEGV', 'SIGUSR2', 'SIGTERM'
]
production = process.env.NODE_ENV is 'production'

stopping = false

cluster.on 'disconnect', (worker) ->
	if production
		cluster.fork() unless stopping
	else
		process.exit(1)

if cluster.isMaster
	workerCount = process.env.NODE_CLUSTER_WORKERS or 4
	console.log "Starting #{workerCount} workers..."
	cluster.fork() for i in [0...workerCount]
	
	if production
		stopSignals.forEach (signal) ->
			process.on signal, ->
				console.log "Got #{signal}, stopping workers..."
				stopping = true
				cluster.disconnect ->
					console.log "All workers stopped, exiting."
					process.exit(0)

else
	require './bin/www'
