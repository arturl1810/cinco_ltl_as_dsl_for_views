package de.jabc.cinco.meta.core.pluginregistry;

import java.lang.reflect.Constructor;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.EValidator;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.osgi.framework.BundleContext;

import de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl;
import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
//import de.jabc.cinco.meta.core.pluginregistry.service.helper.Service;
import de.jabc.cinco.meta.core.pluginregistry.validation.MetaPluginValidator;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends AbstractUIPlugin {

	// The plug-in ID
	public static final String PLUGIN_ID = "de.jabc.cinco.meta.core.pluginregistry"; //$NON-NLS-1$

	// The shared instance
	private static Activator plugin;

	/**
	 * The constructor
	 */
	public Activator() {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.eclipse.ui.plugin.AbstractUIPlugin#start(org.osgi.framework.BundleContext
	 * )
	 */
	public void start(BundleContext context) throws Exception {
		MetaPluginValidator m = MetaPluginValidator.getInstance();
		
		EValidator.Registry.INSTANCE.put(EPackage.Registry.INSTANCE.getEPackage("http://www.jabc.de/cinco/meta/core/mgl"), m);
		
		
		
		super.start(context);
		plugin = this;
		
		IExtensionRegistry registry = Platform.getExtensionRegistry();
		IExtensionPoint point = registry
				.getExtensionPoint("de.jabc.cinco.meta.core.pluginregistry.metaplugin");
		if (point == null)
			return;
		IExtension[] extensions = point.getExtensions();
		for (IExtension extension : extensions)
			readExtension(extension);

		for(String a: PluginRegistry.getInstance().getAnnotations(0)){
			System.out.println(a);
			for(PluginRegistryEntry b: PluginRegistry.getInstance().getSuitableMetaPlugins(a)){
				System.out.println(b.getMetaPluginService().getClass().getCanonicalName());
			}
		}

	
		
		
		
		// File directory =
		// Path.fromPortableString("platform:/base/transformations"+System.getProperty("file.separator")).
		// //new File(transformationPath+System.getProperty("file.separator"));
		// File directory = new File(new
		// URI(Platform.getInstallLocation().getURL().toURI().toString()+System.getProperty("file.separator")+"transformations"+System.getProperty("file.separator")));

	}

	@SuppressWarnings({ "rawtypes", "unchecked" })
	private void readExtension(IExtension extension) {
		try {
			String ecorePath = "";
			String genModelPath = "";
			String nodeSuperType = "";
			String edgeSuperType = "";
			String graphModelSuperType = "";
			String nodeContainerSuperType = "";
			Set<String> annotations = new HashSet<String>();
			Set<String> nodeAnnotations = new HashSet<String>();
			Set<String> edgeAnnotations = new HashSet<String>();
			Set<String> graphModelAnnotations = new HashSet<String>();
			Set<String> nodeContainerAnnotations = new HashSet<String>();
			Set<String> typeAnnotations = new HashSet<String>();
			Set<String> primeAnnotations = new HashSet<String>();
			Set<String> attributeAnnotations = new HashSet<String>();
			Set<String> mglDependentPlugins =  new HashSet<String>();
			Set<String> usedPlugins =  new HashSet<String>();
			Set<String> usedFragments =  new HashSet<String>();
			Set<String> mglDependentFragments =  new HashSet<String>();
			IMetaPlugin metaPluginService = null;
			EPackage ecore=null;
			IMetaPluginAcceptor metaPluginAcceptor = null;
			
			
			for (IConfigurationElement elem : extension
					.getConfigurationElements()) {
			
				if (elem.getName().equals("metaplugin_description")) {
					String serviceName = elem.getAttribute("metapluginService");

					Class serviceClass;

					serviceClass = this.getClass().getClassLoader()
							.loadClass(serviceName);
					
					Class params[] = new Class[0];

					Constructor s = serviceClass.getConstructor(params);

					metaPluginService = (IMetaPlugin) s.newInstance();

				}else if(elem.getName().equals("annotation")){
					String anno = elem.getAttribute("recognized-annotation");
					
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.GENERAL_ANNOTATION))
						annotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for general annotations");
				}else if(elem.getName().equals("node-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.NODE_ANNOTATION))
						nodeAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for node annotations");
				}else if(elem.getName().equals("edge-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.EDGE_ANNOTATION))
						edgeAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for edge annotations");
				}else if(elem.getName().equals("graphmodel-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION))
						graphModelAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for graphmodel annotations");
				}else if(elem.getName().equals("nodecontainer-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.NODE_CONTAINER_ANNOTATION))
						nodeContainerAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for node container annotations");
				}else if(elem.getName().equals("type-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.TYPE_ANNOTATION))
						typeAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for type annotations");
				}else if(elem.getName().equals("prime-annotation")){
					
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.PRIME_ANNOTATION))
						primeAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for type annotations");
				}else if(elem.getName().equals("attribute-annotation")){
					String anno =  elem.getAttribute("recognized-annotation");
					if(!existsAnnotation(anno,PluginRegistryEntryImpl.ATTRIBUTE_ANNOTATION))
						attributeAnnotations.add(anno);
					else
						throw new Exception("Annotation: "+anno+" already exists for type annotations");
				}else if(elem.getName().equals("used_ecore_model")){
					nodeSuperType = elem.getAttribute("Node-Supertype");
					edgeSuperType = elem.getAttribute("Edge-Supertype");
					graphModelSuperType = elem.getAttribute("GraphModel-Supertype");
					nodeContainerSuperType = elem.getAttribute("NodeContainer-Supertype");
					
					ecorePath= elem.getAttribute("Used_Ecore-Model");
					genModelPath = elem.getAttribute("Used_GenModel");
					
					ecorePath = Platform.getBundle(extension.getNamespaceIdentifier()).getSymbolicName()+"/"+ecorePath;
					genModelPath = Platform.getBundle(extension.getNamespaceIdentifier()).getSymbolicName()+"/"+genModelPath;
					
					
				}else if(elem.getName().equals("validator")){
					String validatorName = elem.getAttribute("ValidatorClass");

					Class validatorClass;

					validatorClass = this.getClass().getClassLoader()
							.loadClass(validatorName);
					
					Class params[] = new Class[0];

					Constructor s = validatorClass.getConstructor(params);
					
					IMetaPluginValidator metaPluginValidator = (IMetaPluginValidator) s.newInstance(params);
					MetaPluginValidator.getInstance().putValidator(metaPluginValidator);
					
				}else if(elem.getName().equals("proposalprovider")){
					String proposalProviderClassName = elem.getAttribute("MetaPluginAcceptor");
					Class proposalProviderClass = this.getClass().getClassLoader().loadClass(proposalProviderClassName);
					Class params[] = new Class[0];
					Constructor c = proposalProviderClass.getConstructor(params);
					metaPluginAcceptor = (IMetaPluginAcceptor)c.newInstance(params);
					
					
					
				}else if(elem.getName().equals("used_plugin")){
					String pluginName = elem.getAttribute("plugin_name");
					
					if(Boolean.parseBoolean(elem.getAttribute("mgl_dependent")))
						if(Boolean.parseBoolean(elem.getAttribute("is_fragment")))
						mglDependentFragments.add(pluginName);
						else
						mglDependentPlugins.add(pluginName);
					else
						if(Boolean.parseBoolean(elem.getAttribute("is_fragment")))
						usedFragments.add(pluginName);
						else
						usedPlugins.add(pluginName);
				}
				
				
			}
			
		
			
			
			
			PluginRegistryEntryImpl pEntry = new PluginRegistryEntryImpl(metaPluginService.getClass().getName(),
																		 metaPluginService, 
																		 annotations, 
																		 ecore, 
																		 genModelPath,
																		 nodeAnnotations,
																		 edgeAnnotations,
																		 graphModelAnnotations,
																		 nodeContainerAnnotations,
																		 typeAnnotations,
																		 primeAnnotations,
																		 attributeAnnotations,
																		 usedPlugins,
																		 mglDependentPlugins,
																		 usedFragments,
																		 mglDependentFragments);
			pEntry.setEdgeSuperType(edgeSuperType);
			pEntry.setNodeContainerSuperType(nodeContainerSuperType);
			pEntry.setNodeSuperType(nodeSuperType);
			pEntry.setGraphModelSuperType(graphModelSuperType);
			pEntry.setAcceptor(metaPluginAcceptor);
			PluginRegistry.getInstance().registerMetaPlugin(pEntry);

		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	private boolean existsAnnotation(String attribute, int annotationType) {
		
		return !PluginRegistry.getInstance().getSuitableMetaPlugins(attribute,annotationType).isEmpty();
		
		
		
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * org.eclipse.ui.plugin.AbstractUIPlugin#stop(org.osgi.framework.BundleContext
	 * )
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
