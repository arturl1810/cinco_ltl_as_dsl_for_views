package de.jabc.cinco.meta.core.utils.xapi

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.util.xapi.CollectionExtension
import de.jabc.cinco.meta.util.xapi.FileExtension
import de.jabc.cinco.meta.util.xapi.ResourceExtension
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension
import java.util.IdentityHashMap
import java.util.Set
import mgl.Annotatable
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.ContainingElement
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.Import
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.PrimitiveAttribute
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.ReferencedType
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.core.internal.runtime.InternalPlatform
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.pde.core.project.IBundleProjectService

import static org.apache.commons.io.FilenameUtils.removeExtension
import static org.eclipse.emf.common.util.URI.*

import static extension org.eclipse.emf.common.util.URI.createURI
import static extension org.eclipse.emf.ecore.util.EcoreUtil.getRootContainer
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage

class GraphModelExtension {
	
	extension CollectionExtension = new CollectionExtension
	extension WorkspaceExtension = new WorkspaceExtension
	extension FileExtension = new FileExtension
	extension ResourceExtension = new ResourceExtension
	
	public val GenerationContext generationContext = new GenerationContext
	
	
	//================================================================================
    // GraphModel Extensions
    //================================================================================
	
	def String getProjectName(GraphModel it) {
		IResource.project.name
	}
	
	def String getProjectSymbolicName(GraphModel model) {
		val bundleContext = InternalPlatform.getDefault.bundleContext
		val serviceRef = bundleContext.getServiceReference(IBundleProjectService.name)
		val service = bundleContext.getService(serviceRef) as IBundleProjectService
		try {
			return service.getDescription(model.IResource.project).symbolicName
		} catch (CoreException e) {
			e.printStackTrace
		} finally {
			bundleContext.ungetService(serviceRef)
		}
		return ""
	}
	
	def Iterable<GenModel> getImportedGenModels(GraphModel model) {
		model.imports
			.filter[importURI.endsWith(".ecore")]
			.map[genModel]
	}

	def Iterable<GraphModel> getImportedGraphModels(GraphModel model) {
		model.imports
			.filter[importURI.endsWith(".mgl")]
			.map[importedGraphModel]
	}
	
	def canContain(ContainingElement elm, ModelElement element) {
		elm.containables.exists[it == element]
	}
	
	def getContainables(ContainingElement elm) {
		_containables.get(elm)
	}
	
	val _containables = new NonEmptyRegistry<ContainingElement,Iterable<? extends ModelElement>> [
		val types = containmentRestrictions
		if (types.isEmpty) switch it {
			GraphModel: nodes
			NodeContainer: graphModel.nodes
		}
		else types.map[#[it] + subTypes].flatten.toSet
	]
	
	dispatch def getContainmentRestrictions(GraphModel it) {
		containableElements.map[types].flatten.toSet
	}
	
	dispatch def Set<ModelElement> getContainmentRestrictions(NodeContainer it) {
		( #{extends}.filter(NodeContainer)
			.map[containmentRestrictions].flatten
		  + containableElements.map[types].flatten ).toSet
	}
	
	def <T extends ModelElement> getSubTypes(T elm) {
		_subTypes.get(elm) as Set<T>
	}
	
	val _subTypes = new NonEmptyRegistry<ModelElement,Set<ModelElement>> [elm|
		elm.graphModel.modelElements
			.filter[superTypes.exists[it === elm]].toSet
	]
	
	def getSuperType(Type it) {
		switch it {
			Node: extends
			Edge: extends
			UserDefinedType: extends
		}
	}
	
	def Iterable<? extends ModelElement> getSuperTypes(Type elm) {
		_superTypes.get(elm)
	}
	
	val _superTypes = new NonEmptyRegistry<ModelElement,Iterable<ModelElement>> [elm|
		val superType = elm.superType
		if (superType == null)
			#[]
		else #[superType] + superType.superTypes
	]
	
	def getModelElement(GraphModel it, String name) {
		modelElements.findFirst[it.name == name]
	}
	
	def getModelElements(GraphModel it) {
		nodes + edges + userDefinedTypes
	}
	
	def containsModelElement(GraphModel it, String name) {
		modelElements.exists[it.name == name]
	}
	
	def getGraphicalModelElement(GraphModel it, String name) {
		graphicalModelElements.findFirst[it.name == name]
	}
	
	def getGraphicalModelElements(GraphModel it) {
		nodes + edges
	}
	
	def containsGraphicalModelElement(GraphModel it, String name) {
		graphicalModelElements.exists[it.name == name]
	}
	
	def getContainers(GraphModel it) {
		nodes.filter(NodeContainer)
	}
	
	def containsContainer(GraphModel it, String name) {
		containers.exists[it.name == name]
	}
	
	def getNonContainerNodes(GraphModel it) {
		nodes.drop(NodeContainer)
	}
	
	def containsNonContainerNode(GraphModel it, String name) {
		nonContainerNodes.exists[it.name == name]
	}
	
	def getEnumerations(GraphModel it) {
		types.filter(Enumeration)
	}
	
	def containsEnumeration(GraphModel it, String name) {
		enumerations.exists[it.name == name]
	}
	
	def getUserDefinedTypes(GraphModel it) {
		types.filter(UserDefinedType)
	}
	
	def containsUserDefinedType(GraphModel it, String name) {
		userDefinedTypes.exists[it.name == name]
	}
	
	def getPrimeReferences(GraphModel it) {
		nodes.map[primeReference].filterNull
	}
	
	//================================================================================
    // ModelElement Extensions
    //================================================================================

	dispatch def getGraphModel(ModelElement it) {
		switch it {
			Node: graphModel
			Edge: graphModel
			default: rootContainer as GraphModel
		}
	}
	
	def Iterable<Attribute> getAllAttributes(ModelElement it) {
		_allAttributes.get(it)
	}
	
	val _allAttributes = new NonEmptyRegistry<ModelElement,Iterable<Attribute>> [
		attributes + (superType?.allAttributes ?: #[])
	]
	
	def hasAnnotation(Annotatable it, String annotationName) {
		annotations?.exists[name == annotationName]
	}
	
	//================================================================================
    // Node Extensions
    //================================================================================
	
	def getIncomingEdges(Node node) {
		_incomingEdges.get(node)
	}
	
	val _incomingEdges = new NonEmptyRegistry<Node,Set<Edge>> [node|
		(#[node] + node.superTypes as Iterable<Node>)
			.map[incomingEdgeConnections].flatten
			.map[connectingEdges]
			.map[if (empty) node.graphModel.edges else it].flatten // no constraint means all edges are allowed
			.map[#[it] + subTypes].flatten.toSet
	]
	
	def getOutgoingEdges(Node node) {
		_outgoingEdges.get(node)
	}
	
	val _outgoingEdges = new NonEmptyRegistry<Node,Set<Edge>> [node|
		(#[node] + node.superTypes as Iterable<Node>)
			.map[outgoingEdgeConnections].flatten
			.map[connectingEdges]
			.map[if (empty) node.graphModel.edges else it].flatten // no constraint means all edges are allowed
			.map[#[it] + subTypes].flatten.toSet
	]
	
	def isEdgeSource(Node it) {
		!outgoingEdges.isEmpty
	}
	
	def ReferencedType getAnyPrimeReference(Node node) {
		node.primeReference ?: node.extends?.anyPrimeReference
	}
	
	def hasPrimeReference(Node it) {
		anyPrimeReference != null
	}
	
	//================================================================================
    // Edge Extensions
    //================================================================================
	
	def getSourceNodes(Edge edge) {
		_sourceNodes.get(edge)
	}
	
	val _sourceNodes = new NonEmptyRegistry<Edge,Iterable<Node>> [edge|
		edge.graphModel.nodes.filter[outgoingEdges.exists[it == edge]]
	]
	
	def getTargetNodes(Edge edge) {
		_targetNodes.get(edge)
	}
	
	val _targetNodes = new NonEmptyRegistry<Edge,Iterable<Node>> [edge|
		edge.graphModel.nodes.filter[incomingEdges.exists[it == edge]]
	]
	
	//================================================================================
    // Attribute Extensions
    //================================================================================
	
	def getType(Attribute attribute) {
		switch it:attribute {
			PrimitiveAttribute: type
			ComplexAttribute: type
		}
	}
	
	//================================================================================
    // Import Extensions
    //================================================================================
	
	def getImportedModel(Import imprt) {
		imprt.importURI.createURI.getFile.resource.contents.head
	}
	
	def GenModel getGenModel(Import imprt) {
		val uri = createURI(removeExtension(imprt.importURI).concat(".genmodel"))
		uri.resource.getContent(GenModel, 0)
	}
	
	def GraphModel getImportedGraphModel(Import imprt) {
		var file = createURI(imprt.importURI, true).getFile
		if (file == null) {
			// might be a relative path
			val uri = imprt.eResource.URI
			if (uri.isFile) {
				val fromOSString = Path.fromOSString(uri.toFileString())
				val member = workspaceRoot.getFileForLocation(fromOSString)
				file = member?.project?.getFile(imprt.importURI)
			} else {
				val project = workspaceRoot.getFile(new Path(uri.toPlatformString(true)))?.project
				file = project?.getFile(imprt.importURI)
			}
		}
		file?.getContent(GraphModel, 0)
	}
	
	//================================================================================
    // Type Extensions
    //================================================================================

	dispatch def GraphModel getGraphModel(Type it) {
		(eContainer ?: {
			eResource.getContent(GraphModel, 0)
		}) as GraphModel
	}
	
	def getBeanName(Type it)
		'''«name.toFirstUpper»'''
	
	def String getBeanPackage(Type type) {
		_beanPackage.get(type)
	}
	
	val _beanPackage = new NonEmptyRegistry<Type,String> [switch it {
		GraphModel: '''«package».«name.toLowerCase»'''
		default: graphModel.beanPackage
	}]
	
	def getFqBeanName(Type it) 
		'''«beanPackage».«beanName»'''
	
	def getInternalBeanName(Type it)
		'''Internal«name.toFirstUpper»'''
	
	def String getInternalBeanPackage(Type type) {
		_internalBeanPackage.get(type)
	}
	
	val _internalBeanPackage = new NonEmptyRegistry<Type,String> [switch it {
		GraphModel: '''«package».«name.toLowerCase».internal'''
		default: graphModel.internalBeanPackage
	}]
	
	def getFqInternalBeanName(Type it)
		'''«internalBeanPackage».«internalBeanName»'''
	
	//================================================================================
	// ReferencedType Extensions
	//================================================================================
	
	def getType(ReferencedType it) {
		switch it {
			ReferencedModelElement: type
			ReferencedEClass: type
		}
	}
	
	def getTypeName(ReferencedType primeRef) {
		switch it:primeRef {
			ReferencedEClass : type.name
			ReferencedModelElement : type.name
		}
	}
	
	def getFqBeanName(ReferencedType primeRef) {
		switch primeRef {
			ReferencedModelElement: primeRef.type.fqBeanName
			ReferencedEClass: {
				val primeEPackage = primeRef.type.EPackage
				val genPkg = primeRef.genModel.genPackages.findFirst[name == primeEPackage.name]
				primeRef.getFqBeanName(genPkg)
			}
		}
	}
	
	def getFqBeanName(ReferencedType primeRef, GenPackage genPkg) {
		var pkg = ""
		if (genPkg.basePackage != null)
			pkg += genPkg.basePackage + "."
		val genPkgName = genPkg.name
		if (genPkgName != null)
			pkg += genPkgName + "."
		return pkg + primeRef.typeName
	}
	
	def getImportedModel(ReferencedEClass primeRef) {
		primeRef.imprt.importedModel
	}
	
	def getGenModel(ReferencedEClass primeRef) {
		primeRef.imprt.genModel
	}
	
	def getName(GenPackage genPkg) {
		genPkg.getEcorePackage?.name
		?: genPkg.prefix?.toLowerCase
	}
	
	//================================================================================
    // Static Utility Classes
    //================================================================================
	
	static class GenerationContext {
		
		private val IdentityHashMap<Object,Object> map = new IdentityHashMap
		
		def <T> T get(T key) {
			val value = map.get(key)
			if (value != null) value as T else null
		}
		
		def <T> T put(T key, T value) {
			val oldVal = map.put(key, value)
			if (oldVal != null) oldVal as T else null 
		}
	}
}
