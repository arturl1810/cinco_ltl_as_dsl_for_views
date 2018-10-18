package de.jabc.cinco.meta.core.pluginregistry.impl;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.emf.ecore.EPackage;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistryEntry;
//import de.jabc.cinco.meta.core.pluginregistry.service.helper.Service;
import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

public class PluginRegistryEntryImpl implements PluginRegistryEntry {
	public final static int GENERAL_ANNOTATION = 0;
	public final static int NODE_ANNOTATION = 1;
	public final static int EDGE_ANNOTATION = 2;
	public final static int GRAPH_MODEL_ANNOTATION = 3;
	public final static int NODE_CONTAINER_ANNOTATION = 4;
	public final static int TYPE_ANNOTATION = 5;
	public final static int PRIME_ANNOTATION = 6;
	public final static int ATTRIBUTE_ANNOTATION = 7;
	private EPackage usedEPackage = null;
	private Set<String> recognizedAnnotations = new HashSet<String>();
	private String genModelPath =null;
	private String nodeContainerSuperType=null;
	private String graphModelSuperType=null;
	private String edgeSuperType=null;
	private String nodeSuperType=null;
	private Set<String> nodeAnnotations = new HashSet<String>();
	private Set<String> edgeAnnotations = new HashSet<String>();
	private Set<String> graphModelAnnotations = new HashSet<String>();
	private Set<String> typeAnnotations = new HashSet<String>();
	private Set<String> nodeContainerAnnotations = new HashSet<String>();
	private Set<String> primeAnnotations = new HashSet<String>();
	private Set<String> attributeAnnotations = new HashSet<String>();
	private IMetaPlugin metaPluginService = null;
	private IMetaPluginAcceptor acceptor;
	private Set<String> mglDependentPlugins = new HashSet<String>();
	private Set<String> usedPlugins= new HashSet<String>();
	private Set<String> mglDependentFragments = new HashSet<String>();
	private Set<String> usedFragments= new HashSet<String>();
	private String name = null;
	
	public PluginRegistryEntryImpl(String name, IMetaPlugin metaPluginService2){
		this.metaPluginService  = metaPluginService2;
		this.name = name;
	}
	
	public PluginRegistryEntryImpl(String name,IMetaPlugin metaPluginService2, Set<String> recognizedAnnotations){
		this(name, metaPluginService2);
		this.recognizedAnnotations = recognizedAnnotations;
	}
	
	public PluginRegistryEntryImpl(String name, IMetaPlugin metaPluginService, String recognizedAnnotation){
		this(name,metaPluginService);
		this.recognizedAnnotations.add(recognizedAnnotation);
	}
	
	public PluginRegistryEntryImpl(String name,IMetaPlugin metaPluginService, Set<String> annotations,
			EPackage ep,String genModelPath) {
		this(name,metaPluginService,annotations);
		this.usedEPackage = ep;
		this.genModelPath = genModelPath;
	}
	
	public PluginRegistryEntryImpl(String name, IMetaPlugin metaPluginService, String annotation,
			EPackage ep,String genModelPath) {
		this(name,metaPluginService,annotation);
		this.usedEPackage = ep;
		this.genModelPath = genModelPath;
	}
	
	public PluginRegistryEntryImpl(String name,IMetaPlugin metaPluginService2,
			Set<String> annotations, EPackage ep, String genModelPath,
			Set<String> nodeAnnotations, Set<String> edgeAnnotations,
			Set<String> graphModelAnnotations,
			Set<String> nodeContainerAnnotations, Set<String> typeAnnotations,Set<String> primeAnnotations,Set<String> attributeAnnotations, Set<String> usedPlugins, Set<String> mglDependentPlugins,Set<String> usedFragments, Set<String> mglDependentFragments) {
		this(name,metaPluginService2,annotations);
		this.usedEPackage = ep;
		this.genModelPath = genModelPath;
		this.nodeAnnotations = nodeAnnotations;
		this.edgeAnnotations = edgeAnnotations;
		this.graphModelAnnotations = graphModelAnnotations;
		this.typeAnnotations = typeAnnotations;
		this.nodeContainerAnnotations = nodeContainerAnnotations;
		this.primeAnnotations = primeAnnotations;
		this.attributeAnnotations = attributeAnnotations;
		this.mglDependentPlugins = mglDependentPlugins;
		this.usedPlugins = usedPlugins;
		this.usedFragments = usedFragments;
		this.mglDependentFragments = mglDependentFragments;
	}

	@Override
	public EPackage getUsedEPackage() {
		return this.usedEPackage;
	}

	@Override
	public void setUsedEPackage(EPackage ePackage, String genModelPath) {
		this.usedEPackage = ePackage;
		this.genModelPath = genModelPath;

	}

	@Override
	public boolean doesRecognizeAnnotation(String annotation) {
		return doesRecognizeAnnotation(annotation,this.recognizedAnnotations);
		
	}

	@Override
	public boolean removeAnnotation(String annotation) {
		// TODO Auto-generated method stub
		return this.recognizedAnnotations.remove(annotation);
	}

	@Override
	public boolean addAnnotation(String annotation) {
		return this.recognizedAnnotations.add(annotation);
	}

	@Override
	public  IMetaPlugin getMetaPluginService() {
		return this.metaPluginService;
	}

	@Override
	public Set<String> getRecognizedAnnotations() {
		return this.recognizedAnnotations;
	}
	
	/**
	 * 
	 * @param annotationType : type of annotation based on a final integer
	 * @return set of recognized annotations for given type
	 */
	public Set<String> getRecognizedAnnotations(int annotationType){
		switch(annotationType){
		case PluginRegistryEntryImpl.GENERAL_ANNOTATION: return this.recognizedAnnotations;
		case PluginRegistryEntryImpl.NODE_ANNOTATION: return this.nodeAnnotations;
		case PluginRegistryEntryImpl.EDGE_ANNOTATION: return this.edgeAnnotations;
		case PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION: return this.graphModelAnnotations;
		case PluginRegistryEntryImpl.NODE_CONTAINER_ANNOTATION: return this.nodeContainerAnnotations;
		case PluginRegistryEntryImpl.TYPE_ANNOTATION: return this.typeAnnotations;
		case PluginRegistryEntryImpl.PRIME_ANNOTATION: return this.primeAnnotations;
		case PluginRegistryEntryImpl.ATTRIBUTE_ANNOTATION: return this.attributeAnnotations;
		default: throw new IllegalArgumentException("Unknown Annotation type: "+annotationType+".");
		}
	}
	@Override
	public String getGenModelPath() {
		return this.genModelPath ;
	}
	
	@Override
	public String toString() {
//		return "Service: "+this.metaPluginService.getClass().getName()+"\n"+
//				"Recognized Annotations: "+this.recognizedAnnotations+"\n"+
//				"EPackage: "+this.usedEPackage.getNsURI()+"\n"+
//				"GenModelPath: "+this.genModelPath;
		return this.name;
	}

	@Override
	public String getNodeSuperType() {
		return this.nodeSuperType;
	}

	@Override
	public void setNodeSuperType(String superType) {
		this.nodeSuperType = superType;
		
	}

	@Override
	public String getEdgeSuperType() {

		return this.edgeSuperType;
	}

	@Override
	public void setEdgeSuperType(String superType) {
		this.edgeSuperType = superType;
		
	}

	@Override
	public String getGraphModelSuperType() {
		return this.graphModelSuperType;
	}

	@Override
	public void setGraphModelSuperType(String superType) {
		this.graphModelSuperType = superType;
		
	}

	@Override
	public String getNodeContainerSuperType() {
		return this.nodeContainerSuperType;
	}

	@Override
	public void setNodeContainerSuperType(String superType) {
		this.nodeContainerSuperType = superType;
		
	}
	

	public boolean doesRecognizeAnnotation(String annotation, int annotationType) {
		switch(annotationType){
		case PluginRegistryEntryImpl.GENERAL_ANNOTATION: return doesRecognizeAnnotation(annotation);
		case PluginRegistryEntryImpl.NODE_ANNOTATION: return doesRecognizeAnnotation(annotation,this.nodeAnnotations);
		case PluginRegistryEntryImpl.EDGE_ANNOTATION:return doesRecognizeAnnotation(annotation,this.edgeAnnotations);
		case PluginRegistryEntryImpl.GRAPH_MODEL_ANNOTATION:return doesRecognizeAnnotation(annotation,this.graphModelAnnotations);
		case PluginRegistryEntryImpl.NODE_CONTAINER_ANNOTATION:return doesRecognizeAnnotation(annotation,this.nodeContainerAnnotations);
		case PluginRegistryEntryImpl.TYPE_ANNOTATION:return doesRecognizeAnnotation(annotation,this.typeAnnotations);
		case PluginRegistryEntryImpl.PRIME_ANNOTATION:return doesRecognizeAnnotation(annotation,primeAnnotations);
		case PluginRegistryEntryImpl.ATTRIBUTE_ANNOTATION:return doesRecognizeAnnotation(annotation,attributeAnnotations);
		default: throw new IllegalArgumentException("Unknown Annotation type: "+annotationType+".");
		}
	}

	private boolean doesRecognizeAnnotation(String annotation, Set<String> annotations) {
		// TODO Auto-generated method stub
		return annotations.contains(annotation);
	}

	public Set<String> getAllRecognizedAnnotations() {
		Set<String> allRecognizedAnnotations = new HashSet<String>();
		for(int i=0;i<=PluginRegistryEntryImpl.ATTRIBUTE_ANNOTATION;i++){
			allRecognizedAnnotations.addAll(getRecognizedAnnotations(i));
		}
		return allRecognizedAnnotations;
	}
	
	@Override
	public IMetaPluginAcceptor getAcceptor() {
		return this.acceptor;
	}

	@Override
	public void setAcceptor(IMetaPluginAcceptor acceptor) {
		this.acceptor = acceptor;
		
	}

	@Override
	public Set<String> getUsedPlugins() {
		return this.usedPlugins;
	}

	@Override
	public Set<String> getMGLDependentPlugins() {
		// TODO Auto-generated method stub
		return this.mglDependentPlugins;
	}

	@Override
	public Set<String> getUsedFragments() {
		// TODO Auto-generated method stub
		return this.usedFragments;
	}

	@Override
	public Set<String> getMGLDependentFragments() {
		// TODO Auto-generated method stub
		return this.mglDependentFragments;
	}

	@Override
	public String getName() {
		// TODO Auto-generated method stub
		return this.name ;
	}
	

}
