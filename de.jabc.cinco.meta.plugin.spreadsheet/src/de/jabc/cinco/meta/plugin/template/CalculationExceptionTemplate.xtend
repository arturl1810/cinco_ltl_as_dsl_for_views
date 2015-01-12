package de.jabc.cinco.meta.plugin.template

class CalculationExceptionTemplate {
	def create(String packageName)
	'''
		package «packageName»;
		@SuppressWarnings("serial")
		public class CalculationException extends Exception {}'''
}