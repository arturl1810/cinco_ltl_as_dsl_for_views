package de.jabc.cinco.meta.plugin.gratext.runtime;

import de.jabc.cinco.meta.core.ui.editor.PageAwareEditor;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.MultiPageEditorContributor;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.MultiPageEditorContributorRegistry;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "de.jabc.cinco.meta.plugin.gratext.runtime"; //$NON-NLS-1$

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
//		collectExtensions();
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
	
//	public static final String EXTENSION_POINT = "de.jabc.cinco.meta.plugin.gratext.MultiPageEditorContributor";
//	public static final String EXTENSION_NAME = "MultiPageEditorContributor";
//	public static final String ATTRIBUTE_CLASS = "class";
//
//	private void collectExtensions() {
//		IExtensionRegistry registry = Platform.getExtensionRegistry();
//		IExtensionPoint extpoint = registry.getExtensionPoint(EXTENSION_POINT);
//		for (IExtension extension : extpoint.getExtensions()) {
//			readExtension(extension);
//		}
//	}
//	
//	private void readExtension(IExtension extension) {
//		for (IConfigurationElement elem : extension.getConfigurationElements()) {
//			if (elem.getName().equals(EXTENSION_NAME)) {
//				String serviceName = elem.getAttribute(ATTRIBUTE_CLASS);
//				MultiPageEditorContributor service = (MultiPageEditorContributor) loadService(serviceName);
//				MultiPageEditorContributorRegistry.INSTANCE.add(service);
//			}
//		}
//	}
//	
//	private Object loadService(String name) {
//		try {
//			return Class.forName(name).getConstructor().newInstance();
//		} catch (Exception e) {
//			e.printStackTrace();
//			return null;
//		}
//	}
}
