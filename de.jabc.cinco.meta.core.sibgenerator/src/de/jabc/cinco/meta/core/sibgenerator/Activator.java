package de.jabc.cinco.meta.core.sibgenerator;


import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener;
import de.jabc.plugin.jabc4.util.IOSIBUtil;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "de.jabc.cinco.meta.core.sibgenerator"; //$NON-NLS-1$

	// The shared instance
	private static Activator plugin;
	
	protected MGLSelectionListener selectionListener = null;
	
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
		
		this.selectionListener = MGLSelectionListener.INSTANCE;
		
		
		
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
	
	

	public MGLSelectionListener getSelectionListener() {
		return selectionListener;
	}

}
