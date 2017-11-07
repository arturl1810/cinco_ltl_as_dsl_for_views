package de.jabc.cinco.meta.core.pluginregistry.validation

import org.eclipse.xtend.lib.annotations.Data

@Data abstract class ValidationResult<MESSAGE, FEATURE> {
	
	MESSAGE message
	FEATURE feature
	
	static class Error<MESSAGE, FEATURE> extends ValidationResult<MESSAGE, FEATURE> {
		new(MESSAGE message, FEATURE feature) {
			super(message, feature)
		}
	}
	
	static class Warning<MESSAGE, FEATURE> extends ValidationResult<MESSAGE, FEATURE> {
		new(MESSAGE message, FEATURE feature) {
			super(message, feature)
		}
	}
	
	static class Info<MESSAGE, FEATURE> extends ValidationResult<MESSAGE, FEATURE> {
		new(MESSAGE message, FEATURE feature) {
			super(message, feature)
		}
	}
	
	static def <MESSAGE, FEATURE> newError(MESSAGE message, FEATURE feature) {
		new Error(message, feature)
	}
	
	static def <MESSAGE, FEATURE> newWarning(MESSAGE message, FEATURE feature) {
		new Warning(message, feature)
	}
	
	static def <MESSAGE, FEATURE> newInfo(MESSAGE message, FEATURE feature) {
		new Info(message, feature)
	}
}
