package de.jabc.cinco.meta.core.pluginregistry;

import java.util.List;
import java.util.Set;

import org.eclipse.emf.ecore.EPackage;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

//import de.jabc.cinco.meta.core.pluginregistry.service.helper.Service;


public interface PluginRegistryEntry {
	
	public String getName();
	
	/**
	 * 
	 * @return - Used EPackage for MetaPlugin if any. Returns null if no EPackage is used by PluginRegistryEntry
	 */
	public EPackage getUsedEPackage();
	public void setUsedEPackage(EPackage ePackage,String genModelPath);
	/**
	 * Tells if given annotation is recognized by this particular PluginRegistryEntry
	 * @param annotation
	 * @return - true if annotation is recognized by PluginRegistryEntry, false otherwise
	 */
	public boolean doesRecognizeAnnotation(String annotation);
	/**
	 * 
	 * @param annotation - Annotation that is to be removed
	 * @return true if annotation has been successfully removed, false otherwise.
	 */
	public boolean removeAnnotation(String annotation);
	/**
	 * 
	 * @param annotation - Annotation that is to be added to the recognized Annotations
	 * @return - true if annotation has been successfully added, false otherwise.
	 */
	public boolean addAnnotation(String annotation);
	
	public IMetaPlugin getMetaPluginService();
	
	public Set<String> getRecognizedAnnotations();
	public String getGenModelPath();
	
	public String getNodeSuperType();
	public void setNodeSuperType(String superType);
	
	public String getEdgeSuperType();
	public void setEdgeSuperType(String superType);
	
	public String getGraphModelSuperType();
	public void setGraphModelSuperType(String superType);
	
	public String getNodeContainerSuperType();
	public void setNodeContainerSuperType(String superType);
	
	public IMetaPluginAcceptor getAcceptor();
	public void setAcceptor(IMetaPluginAcceptor acceptor);
	
	/**
	 * 
	 * @return List of Eclipse Plugins that are created by use of this MetaPlugin. Only Plugins with absolute names.
	 * For Plugins whose names are dependent of the MGL package name of the editor use getMGLDependentPlugins
	 */
	public Set<String> getUsedPlugins();
	/**
	 * 
	 * @return List of Eclipse Plugins that are created by use of this MetaPlugin, whose names are dependent of the MGL package name. 
	 */
	public Set<String> getMGLDependentPlugins();
	
	
	/**
	 * 
	 * @return List of Eclipse Fragments that are created by use of this MetaPlugin. Only Plugins with absolute names.
	 * For Fragments whose names are dependent of the MGL package name of the editor use getMGLDependentPlugins
	 */
	public Set<String> getUsedFragments();
	/**
	 * 
	 * @return List of Eclipse Fragments that are created by use of this MetaPlugin, whose names are dependent of the MGL package name. 
	 */
	public Set<String> getMGLDependentFragments();
	
}
