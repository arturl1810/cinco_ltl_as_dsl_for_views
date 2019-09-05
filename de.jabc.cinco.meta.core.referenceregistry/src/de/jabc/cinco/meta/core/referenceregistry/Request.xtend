package de.jabc.cinco.meta.core.referenceregistry

abstract package class Request<KEY,RESULT> {
		
	protected val KEY key
	protected var RESULT result
	protected var isProvided = false
	
	new(KEY key) {
		this.key = key
	}
	
	def void provide(RESULT result) {
		this.result = result
		this.isProvided = true
	}
	
	def decline() {
		provide(null)
	}
}