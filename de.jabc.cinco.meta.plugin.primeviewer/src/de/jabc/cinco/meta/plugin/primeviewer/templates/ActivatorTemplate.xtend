package de.jabc.cinco.meta.plugin.primeviewer.templates

import de.jabc.cinco.meta.core.utils.projects.ContentWriter
import mgl.GraphModel
import org.eclipse.core.resources.IProject

class ActivatorTemplate {
	
	def static doGenerateActivatorContent(GraphModel gm, IProject p) {
		val packageName = gm.package+".primeviewer"
		ContentWriter::writeJavaFile(p, "src", packageName, "Activator.java", gm.content.toString)
	}
	
	def static getContent(GraphModel gm) '''
	package «gm.package».primeviewer;
	
	import org.eclipse.ui.plugin.AbstractUIPlugin;
	import org.osgi.framework.BundleContext;
	
	/**
	 * The activator class controls the plug-in life cycle
	 */
	public class Activator extends AbstractUIPlugin {
	
		// The plug-in ID
		public static final String PLUGIN_ID = "«gm.package».primeviewer"; //\$NON-NLS-1\$
	
		// The shared instance
		private static Activator plugin;
		
		/**
		 * The constructor
		 */
		public Activator() {
		}
	
		/*
		 * (non-Javadoc)
		 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
		 */
		public void start(BundleContext context) throws Exception {
			super.start(context);
			plugin = this;
		}
	
		/*
		 * (non-Javadoc)
		 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
		 */
		public void stop(BundleContext context) throws Exception {
			plugin = null;
			super.stop(context);
		}
	
		/**
		 * Returns the shared instance
		 *
		 * @return the shared instance
		 */
		public static Activator getDefault() {
			return plugin;
		}
	
	}
	'''
	
}