package de.jabc.cinco.meta.core.pluginregistry;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.emf.ecore.EPackage;
import org.eclipse.xtend.typesystem.emf.EcoreUtil2;

import de.jabc.cinco.meta.core.pluginregistry.impl.PluginRegistryEntryImpl;
//import de.jabc.cinco.meta.core.pluginregistry.service.helper.AbstractService;
//import de.jabc.cinco.meta.core.pluginregistry.service.helper.Service;
public class PluginRegistry {
	private static PluginRegistry instance;
	HashMap<EPackage,String> genModelMap;
	private HashMap<String, EPackage> ecoreMap;
	private HashMap<String,IMetaPlugin> pluginGenerators;
	private HashSet<PluginRegistryEntryImpl> metaPlugins;
	private HashMap<String, Set<String>> mglDependentPlugins;
	private HashMap<String, Set<String>> usedPlugins;
	private HashMap<String, Set<String>> mglDependentFragments;
	private HashMap<String, Set<String>> usedFragments;
	public HashMap<String, IMetaPlugin> getPluginGenerators() {
		return pluginGenerators;
	}
	public void setPluginGenerators(
			HashMap<String, IMetaPlugin> pluginGenerators) {
		this.pluginGenerators = pluginGenerators;
	}
	private PluginRegistry(){
		
		this.genModelMap = new HashMap<EPackage,String>();
		this.ecoreMap = new HashMap<String,EPackage>();
		this.metaPlugins = new HashSet<PluginRegistryEntryImpl>();
		
		this.pluginGenerators = new HashMap<String,IMetaPlugin>();
		
		EPackage abstractGraphModel = EcoreUtil2.getEPackage("platform:/plugin/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.ecore");
		ecoreMap.put("abstractGraphModel", abstractGraphModel);
		genModelMap.put(abstractGraphModel,"platform:/plugin/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.genmodel");
		
		//EPackage mcGraphModel = EcoreUtil2.getEPackage("platform:/plugin/de.jabc.cinco.gdl.model/model/MCGraphModel.ecore");
		//registerMetaPlugin(new PluginRegistryEntryImpl(null,"mc",mcGraphModel,"platform:/plugin/de.jabc.cinco.gdl.model/model/MCGraphModel.genmodel"));
		this.mglDependentPlugins = new HashMap<>();
		this.usedPlugins = new HashMap<>();
		this.mglDependentFragments = new HashMap<>();
		this.usedFragments = new HashMap<>();
		
		
	}
	public static PluginRegistry getInstance() {
		if(instance==null){
			instance = new PluginRegistry();
		}
		return instance;
	}
	public HashMap<String, EPackage> getRegisteredEcoreModels() {
	  return this.ecoreMap;
	}
	public HashMap<EPackage, String> getGenModelMap() {
	  return this.genModelMap;
	}
	
	public void registerMetaPlugin(PluginRegistryEntryImpl pEntry){
		metaPlugins.add(pEntry);
		for(String st: pEntry.getRecognizedAnnotations(PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION)){
			ecoreMap.put(st,pEntry.getUsedEPackage());
			genModelMap.put(pEntry.getUsedEPackage(),pEntry.getGenModelPath());
			this.pluginGenerators.put(st, pEntry.getMetaPluginService());
			this.mglDependentPlugins.put((String) (pEntry.getRecognizedAnnotations(PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION).toArray())[0],pEntry.getMGLDependentPlugins());
			this.usedPlugins.put((String) (pEntry.getRecognizedAnnotations(PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION).toArray())[0],pEntry.getUsedPlugins());
			this.mglDependentFragments.put((String) (pEntry.getRecognizedAnnotations(PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION).toArray())[0],pEntry.getMGLDependentFragments());
			this.usedFragments.put((String) (pEntry.getRecognizedAnnotations(PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION).toArray())[0],pEntry.getUsedFragments());
		}
	}
	
	public Set<PluginRegistryEntry> getSuitableMetaPlugins(String annotation){
		HashSet<PluginRegistryEntry> set = new HashSet<PluginRegistryEntry>();
		for(PluginRegistryEntry p: metaPlugins){
			if(p.doesRecognizeAnnotation(annotation))
				set.add(p);
		}
		return set;
	}
	
	public Set<String> getAnnotations(int annotationType){
		HashSet<String> annotations = new HashSet<String>();
		for(PluginRegistryEntryImpl entry: metaPlugins){
			annotations.addAll(entry.getRecognizedAnnotations(annotationType));
		}
		return annotations;
	}
	
	public Set<PluginRegistryEntry> getSuitableMetaPlugins(String annotation,int annotationType){
		HashSet<PluginRegistryEntry> set = new HashSet<PluginRegistryEntry>();
		for(PluginRegistryEntryImpl p: metaPlugins){
			if(p.doesRecognizeAnnotation(annotation,annotationType))
				set.add(p);
		}
		return set;
	}
	public HashMap<String,Set<String>> getMGLDependentPlugins() {
		return this.mglDependentPlugins;
	}
	
	public HashMap<String,Set<String>> getUsedPlugins() {
		return this.usedPlugins;
	}
	
	public HashMap<String,Set<String>> getMGLDependentFragments() {
		return this.mglDependentFragments;
	}
	
	public HashMap<String,Set<String>> getUsedFragments() {
		return this.usedFragments;
	}

}
