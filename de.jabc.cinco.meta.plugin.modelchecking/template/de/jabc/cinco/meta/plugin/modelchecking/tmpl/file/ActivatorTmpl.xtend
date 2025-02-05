package de.jabc.cinco.meta.plugin.modelchecking.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class ActivatorTmpl extends FileTemplate{
	
	override getTargetFileName() '''Activator.java'''
	
	override template() '''
		package «package»;
				
			import org.eclipse.jface.resource.ImageDescriptor;	
			import org.eclipse.ui.plugin.AbstractUIPlugin;
			import org.osgi.framework.BundleContext;
				
			
			public class Activator extends AbstractUIPlugin {
			
				// The plug-in ID
				public static final String PLUGIN_ID = "«package»"; //\$NON-NLS-1\$
			
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
				
				/**
				 * Returns an image descriptor for the image file at the given
				 * plug-in relative path
				 *
				 * @param path the path
				 * @return the image descriptor
				 */
				public static ImageDescriptor getImageDescriptor(String path) {
					return imageDescriptorFromPlugin(PLUGIN_ID, path);
				}
			
			}
	'''
	
}
