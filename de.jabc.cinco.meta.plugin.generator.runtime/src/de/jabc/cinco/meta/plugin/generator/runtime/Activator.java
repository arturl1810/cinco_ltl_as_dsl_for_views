package de.jabc.cinco.meta.plugin.generator.runtime;

import graphmodel.GraphModel;

import java.lang.reflect.InvocationTargetException;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.InvalidRegistryObjectException;
import org.eclipse.core.runtime.Platform;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.jabc.cinco.meta.plugin.generator.runtime.registry.GraphModelGeneratorRegistry;


public class Activator extends AbstractUIPlugin {

	private static final String GENERATOR = "generator";
	private static final String CLASS = "class";
	private static final String GRAPHMODEL = "graphmodel";
	private static final String EXTENSION_POINT_ID = "de.jabc.cinco.meta.plugin.generator.runtime.registry";
	private static BundleContext context;

	static BundleContext getContext() {
		return context;
	}


	private static Activator plugin = null;

	/*
	 * (non-Javadoc)
	 * @see org.osgi.framework.BundleActivator#start(org.osgi.framework.BundleContext)
	 */
	public void start(BundleContext bundleContext) throws Exception {
		Activator.context = bundleContext;
		

		super.start(context);
		plugin = this;
		
		IExtensionRegistry registry = Platform.getExtensionRegistry();
		IExtensionPoint point = registry
				.getExtensionPoint(EXTENSION_POINT_ID);
		if (point == null)
			return;
		IExtension[] extensions = point.getExtensions();
		for (IExtension extension : extensions)
			createGenerator(extension);

		
	}

	@SuppressWarnings("unchecked")
	private void createGenerator(IExtension extension) {
		IGenerator<GraphModel> generator = null;
		String graphModelClassName = null;
		String outlet = null;
		for (IConfigurationElement element : extension.getConfigurationElements()) {
			if(element.getName().equals(GRAPHMODEL)){
				graphModelClassName = element.getAttribute(CLASS);
			}else if(element.getName().equals(GENERATOR)){
				String generatorClassName = element.getAttribute(CLASS);
				
				try {
				  Class<?> cl = Platform.getBundle(element.getAttribute("bundle_id")).loadClass(generatorClassName);
				  generator = (IGenerator<GraphModel>) cl.getConstructor().newInstance();
				  outlet = element.getAttribute("outlet");
				}catch(IllegalAccessException | InstantiationException | IllegalArgumentException | NoSuchMethodException | SecurityException| InvocationTargetException | ClassNotFoundException | InvalidRegistryObjectException e){
					
				} 
				GraphModelGeneratorRegistry.INSTANCE.addGenerator(graphModelClassName, generator,outlet);
			}
		}
		
		
		
	}

	/*
	 * (non-Javadoc)
	 * @see org.osgi.framework.BundleActivator#stop(org.osgi.framework.BundleContext)
	 */
	public void stop(BundleContext bundleContext) throws Exception {
		plugin=null;
		Activator.context = null;
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
