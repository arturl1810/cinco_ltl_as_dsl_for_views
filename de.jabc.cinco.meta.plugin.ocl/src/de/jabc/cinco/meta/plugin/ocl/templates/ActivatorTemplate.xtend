package de.jabc.cinco.meta.plugin.ocl.templates

class ActivatorTemplate {
	def create(String packageName)'''
	package «packageName»;

	import org.eclipse.ui.plugin.AbstractUIPlugin;
	
	public class Activator extends AbstractUIPlugin {
	
		public Activator() {
			// TODO Auto-generated constructor stub
		}
	
	}
	'''
}