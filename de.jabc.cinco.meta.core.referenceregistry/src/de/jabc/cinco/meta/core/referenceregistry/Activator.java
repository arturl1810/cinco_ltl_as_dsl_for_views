package de.jabc.cinco.meta.core.referenceregistry;

import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryPartListener;
import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryResourceChangeListener;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "de.jabc.cinco.meta.core.referenceregistry"; //$NON-NLS-1$

	// The shared instance
	private static Activator plugin;
	
	private RegistryPartListener partListener;
	private RegistryResourceChangeListener resourceListener;
	
	/**
	 * The constructor
	 */
	public Activator() {
		System.out.println("Init listener");
		partListener = new RegistryPartListener();
		resourceListener = new RegistryResourceChangeListener();
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext context) throws Exception {
		super.start(context);
		plugin = this;
		System.out.println("register listener");
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().addPartListener(partListener);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener);
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext context) throws Exception {
		System.out.println("Stopping bundle");
//		System.out.println("Save: " + ReferenceRegistry.getInstance().save());
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
