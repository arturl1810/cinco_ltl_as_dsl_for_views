package de.jabc.cinco.meta.core.referenceregistry

import de.jabc.cinco.meta.core.utils.job.ReiteratingThread

abstract package class Request<KEY,RESULT> extends ReiteratingThread {
		
	protected val KEY key
	protected var RESULT result
	
	new(KEY key) {
		this.key = key
	}
	
	def void provide(RESULT result) {
		this.result = result
		unpause
	}
	
	def decline() {
		provide(null)
	}
	
	override work() {
		quit // quit right away as this thread is only used for waiting
	}
}