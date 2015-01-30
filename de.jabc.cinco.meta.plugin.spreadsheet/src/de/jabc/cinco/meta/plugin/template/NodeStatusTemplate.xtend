package de.jabc.cinco.meta.plugin.template

class NodeStatusTemplate {
	def create(String packageName)'''
package «packageName»;

public enum NodeStatus {
	NEW,UPDATED,REMOVED,OLD,RESULT
}
	'''
}