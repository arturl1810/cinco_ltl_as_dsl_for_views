package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import de.jabc.cinco.meta.core.utils.MGLUtils
import java.util.ArrayList
import java.util.List
import mgl.Attribute
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.Type
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.ui.services.GraphitiUi

class APIUtils {

	static var String packageName
	static var String gmName
	static def setCurrentGraphModel(GraphModel gm) {
		packageName = gm.package
		gmName = gm.name
	}

	def getName(ContainingElement ce) {
		if (ce instanceof NodeContainer)
			return ce.name
		if (ce instanceof GraphModel)
			return ce.name
	}
	
	def getGraphModel(ModelElement me) {
		switch me {
			Node : me.rootElement
			Edge : me.rootElement
			GraphModel : me
		}
	}
	
	def GraphModel rootElement(Type t) {
		if (t instanceof GraphModel)
			return t
		else return rootElement(t.eContainer as Type)
	}
	
	
	
	def fqn(Type t) {
		'''«packageName».«gmName.toLowerCase».«t.name.toFirstUpper»'''
	}
	
//	def fqn(Type t) {
//		switch t {
//			GraphModel : fqn(t as GraphModel)
//			Node : fqn(t as Node)
//			Edge : fqn(t as Edge)	
//		}
//	}
	
	def fqn(Node n)'''
	«packageName».api.«n.name.toFirstUpper»'''

	def fqn(Edge e)'''
	«packageName».api.C«e.name.toFirstUpper»'''
	
	def fqn(GraphModel gm)'''
	«packageName».api.C«gm.name.toFirstUpper»'''
	
	def createFeatureName(ModelElement me) {
		var featureName = '''Create«me.name.toFirstUpper»Feature'''
		if (me instanceof Edge) 
			featureName.createEdgeFeaturePrefix
		else if (me instanceof NodeContainer)
			featureName.createNodeContainerFeaturePrefix
		else if (me instanceof Node)
			featureName.createNodeFeaturePrefix
	}
	
	def fqTypeName(Attribute a) {
		switch a.type {
			case "EString" : String.name
			default : getEnumOrUDT(a)
		}
	}
	
	def attributeSetter(ModelElement me)
	'''«FOR a :  me.attributes»
	public void set«a.name.toFirstUpper»(«a.fqTypeName» «a.name.toFirstLower»){
		((«me.fqn») getModelElement()).set«a.name.toFirstUpper»(«a.name.toFirstLower»);
	}
	
	«ENDFOR»«me.idSetter»
	'''
	
	def attributeGetter(ModelElement me)
	'''«FOR a :  me.attributes»
	public «a.fqTypeName» get«a.name.toFirstUpper»(){
		return ((«me.fqn») getModelElement()).get«a.name.toFirstUpper»();
	}
	
	«ENDFOR»«me.idGetter»
	'''
	
	def idSetter(ModelElement me)'''
	public void setID(«String.name» id) {
		getModelElement().setId(id);
	}
	'''
	
	def idGetter(ModelElement me)'''
	public «String.name» getID() {
		return getModelElement().getId();
	}
	'''
	
	def modelElementGetter(ModelElement me) '''
	protected «me.fqn» getModelElement() {
		return («me.fqn») viewable.getModelElement();
	}
	'''
	
	def featureProviderGetter(ModelElement me) '''
	public «IFeatureProvider.name» getFeatureProvider() {
		return «GraphitiUi.name».getExtensionManager().createFeatureProvider(getDiagram());
	}
	'''
	
	def diagramGetter(ModelElement me) '''
	public «Diagram.name» getDiagram() {
		«IF !(me instanceof GraphModel)»
		return viewable.getCRootElement().getDiagram();
		«ELSE»
		return viewable.getDiagram();
		«ENDIF»
	}
	'''
	
	def viewGetter(ModelElement me) '''
	public «me.fqn»View get«me.name»View() {
		«me.fqn»View view = new «me.fqn»View();
		view.setViewable(this);
		return view;
	}
	'''
	
	def getEnumOrUDT(Attribute a){
		var gm = a.modelElement.graphModel
		var List<Type> types = new ArrayList();
		types.addAll(gm.types)
		types.addAll(gm.nodes)
		types.addAll(gm.edges)
		types = types.filter[t | t.name.equals(a.type)].toList
		if (types.isNullOrEmpty)
			a.type
		else types.get(0).fqn
	}
	
	def outgoingConnectingEdges(Node n) {
		MGLUtils.getOutgoingConnectingEdges(n)
	}
	
	def incomingConnectingEdges(Node n) {
		MGLUtils.getIncomingConnectingEdges(n)
	}
	
	def getPossibleSources(Edge edge) {
		MGLUtils.getPossibleSources(edge)
	}
	def getPossibleTargets(Edge edge) {
		MGLUtils.getPossibleTargets(edge)
	}
	
	def getPossibleContainers(Node n) {
		MGLUtils.getPossibleContainers(n);
	}
	
	def getContainableNodes(GraphModel gm) {
		MGLUtils.getContainableNodes(gm as ContainingElement);
	}
	
	def getContainableNodes(ContainingElement nc) {
		MGLUtils.getContainableNodes(nc);
	}
	
	def createEdgeFeaturePrefix(String s) {
		packageName + ".graphiti.features.create.edges." + s
	}
	
	def createNodeContainerFeaturePrefix(String s) {
		packageName + ".graphiti.features.create.containers." + s
	}
	
	def createNodeFeaturePrefix(String s) {
		packageName + ".graphiti.features.create.nodes." + s
	}
}
