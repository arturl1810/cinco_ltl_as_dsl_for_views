package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import de.jabc.cinco.meta.core.utils.MGLUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.math.BigDecimal
import java.math.BigInteger
import java.util.ArrayList
import java.util.List
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.PrimitiveAttribute
import mgl.Type
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.graphiti.dt.IDiagramTypeProvider

class APIUtils extends GeneratorUtils {

	static var String packageName
	static var String gmName
	static def setCurrentGraphModel(GraphModel gm) {
		packageName = gm.package
		gmName = gm.name
	}
	
	def GraphModel rootElement(Type t) {
		if (t instanceof GraphModel)
			return t
		else return rootElement(t.eContainer as Type)
	}
	
	def cInstanceofCheck(ModelElement me, String varName) 
	'''«varName» instanceof «me.fqCName»'''
	
	def fqn(Type t) {
		'''«packageName».«gmName.toLowerCase».«t.name.toFirstUpper»'''
	}
	
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
		switch a {
			case PrimitiveAttribute: fqTypeName(a as PrimitiveAttribute)
			default : getEnumOrUDT(a as ComplexAttribute)
		}
	}
	
	def dispatch fqCName(GraphModel t) {
		switch (t) {
			GraphModel : (t as ModelElement).fqCName
			NodeContainer : (t as ModelElement).fqCName
		}
	}
	
	def fqCName(Type me) 
	'''«me.packageNameAPI».«me.fuCName»'''
	
	def fqTypeName(PrimitiveAttribute a){
		switch a.type{
			case EBIG_DECIMAL: BigDecimal.name
			case EBIG_INTEGER: BigInteger.name
			case EBOOLEAN: boolean.name
			case EBYTE : byte.name
			case ECHAR: char.name
			case EDOUBLE: double.name
			case EINT: int.name
			case ELONG: long.name
			case ESHORT: short.name
			default: String.name
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
		«Diagram.name» diagram = null;
		try {
			diagram = getDiagram();
		} catch(NullPointerException ignore) {}
		if (diagram != null)
			return «GraphitiUi.name».getExtensionManager().createFeatureProvider(diagram);
		«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider("«me.dtpId»");
		return dtp.getFeatureProvider();
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
	
	def getEnumOrUDT(ComplexAttribute a){
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
		MGLUtil.getOutgoingConnectingEdges(n)
	}
	
	def incomingConnectingEdges(Node n) {
		MGLUtil.getIncomingConnectingEdges(n)
	}
	
	def getPossibleSources(Edge edge) {
		MGLUtil.getPossibleSources(edge)
	}
	def getPossibleTargets(Edge edge) {
		MGLUtil.getPossibleTargets(edge)
	}
	
	def getPossibleContainers(Node n) {
		MGLUtil.getPossibleContainers(n);
	}
	
	def getContainableNodes(GraphModel gm) {
		MGLUtil.getContainableNodes(gm as ContainingElement);
	}
	
	def getContainableNodes(ContainingElement nc) {
		MGLUtil.getContainableNodes(nc);
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
	
	def pictogramElementReturnType(ModelElement me) {
		switch (me) {
			Node : '''«ContainerShape.name»'''
			Edge : '''«Connection.name»'''
			GraphModel : '''«Diagram.name»'''
		}
	}
	
	def constructor(ModelElement me) {
		if (me.isIsAbstract) ""
		else '''public «me.fuCName»(){}'''
	}
	
	def dtp_id(GraphModel it) {
		'''«package».«fuName»DiagramTypeProvider'''
	}
	
}
