/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.validation

import de.jabc.cinco.meta.core.utils.InheritanceUtil
import de.jabc.cinco.meta.core.utils.PathValidator
import java.net.URI
import java.net.URISyntaxException
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import mgl.Annotation
import mgl.Attribute
import mgl.BoundedConstraint
import mgl.ComplexAttribute
import mgl.ContainingElement
import mgl.Edge
import mgl.EdgeElementConnection
import mgl.Enumeration
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.GraphicalModelElement
import mgl.Import
import mgl.IncomingEdgeElementConnection
import mgl.MglPackage
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.OutgoingEdgeElementConnection
import mgl.PrimitiveAttribute
import mgl.ReferencedEClass
import mgl.ReferencedType
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.core.resources.IFile
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check
import java.io.File

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class MGLValidator extends AbstractMGLValidator {
	extension InheritanceUtil = new InheritanceUtil
	
	File file
	
	@Check
	def checkNsURIWellFormed(GraphModel model){
		try{
			
			var uri = new URI(model.nsURI)
		}catch(URISyntaxException e){
			error('NsUri not well formed.',MglPackage.Literals::GRAPH_MODEL__NS_URI);
		}
	}

	@Check
	def checkPackageNameExists(GraphModel model){
		if(model.package.nullOrEmpty || model.package.equals("\"\"")){
			error('Package name must be present.',MglPackage.Literals::TYPE__NAME)
		}
	}
	@Check
	def checkNamedElementNameStartsWithCapital(ModelElement namedElement){
		if (!Character::isUpperCase(namedElement.name.charAt(0))) {
			error('Name must start with a capital', MglPackage.Literals::TYPE__NAME)
					
		}
	}
	
	@Check
	def checkNamedElementNameNotUnique(ModelElement namedElement){
		for(e: namedElement.eContainer.eAllContents.toIterable.filter(typeof(ModelElement))){
			if(e.name.equals(namedElement.name)&&e!=namedElement)
				error('Name must be unique',MglPackage.Literals::TYPE__NAME) 
		}
			
	}
	
	@Check
	def checkNodeIncomingConnections(GraphicalModelElement elem){
		if(elem.incomingEdgeConnections.length<2){
			return;
			
		}
		for(connection: elem.incomingEdgeConnections){
			if(connection.connectingEdges==null)
				error("Incoming Edges cannot have a don't care and other edges.",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__INCOMING_EDGE_CONNECTIONS)
			
		}
			
		
	}
	
	@Check
	def checkNodeOutgoingConnections(GraphicalModelElement elem){
		
		if(elem.outgoingEdgeConnections.length<2){
			return;
			
		}
		for(connection: elem.outgoingEdgeConnections){
			if(connection.connectingEdges==null)
				error("Incoming Edges cannot have a don't care and other edges.",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__OUTGOING_EDGE_CONNECTIONS)
			
		}
			
		
	}
	
	@Check
	def checkIncomingEdgeConnectionsUnique(GraphicalModelElement elem){
		var set = new HashSet<List<Edge>>()
		for(connection: elem.incomingEdgeConnections){
			if(connection.connectingEdges!=null&&!set.add(connection.connectingEdges)){
				error("Given Edges should be unique",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__INCOMING_EDGE_CONNECTIONS);
			
			}
			
		}
		
	}
	
	@Check
	def checkOutgoingEdgeConnectionsUnique(GraphicalModelElement elem){
		var set = new HashSet<List<Edge>>()
		for(connection: elem.outgoingEdgeConnections){
			if(connection.connectingEdges!=null&&!set.add(connection.connectingEdges)){
				error("Given Edges should be unique",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__OUTGOING_EDGE_CONNECTIONS);
			
			}
			
		}
		
	}
	
	
	def GraphicalModelElement connectedElement(EdgeElementConnection connection){
		if(connection instanceof IncomingEdgeElementConnection){
			return (connection as IncomingEdgeElementConnection).connectedElement;
		
		}
		else{ 
			if(connection instanceof OutgoingEdgeElementConnection)
				return(connection as OutgoingEdgeElementConnection).connectedElement;
		}
		return null;
	}
	
//	@Check
//	def checkNodeCanConnectToEdge(Edge edge){
//		
//		for(node : edge.sourceElements){
//			if(node.connectedElement==null||node..size==0||!node.outgoingEdges.contains(edge))
//				error('Node: '+node.connectedElement.name+' cannot have '+edge.name+' as outgoing edge.',MglPackage.Literals::EDGE__SOURCE_ELEMENTS)
//		}
//		for(node : edge.targetElements){
//			if(node.==null||node.incomingEdges.size==0||!node.incomingEdges.contains(edge))
//				error('Node: '+node.name+' cannot have an incoming edge.',MglPackage.Literals::EDGE__TARGET_ELEMENTS)
//		}
//		
//	}
	
//	@Check
//	def checkEdgeCanConnectToNode(Node node){
//		for(edge : node.outgoingEdges){
//			if(edge.sourceElements==null||edge.sourceElements.size==0||!edge.sourceElements.contains(node))
//				error('Node: '+node.name+ 'cannot have Edge: '+edge.name+'as outgoing edge' ,MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__OUTGOING_EDGES)
//		}
//		for(edge : node.incomingEdges){
//			if(edge.targetElements==null||edge.targetElements.size==0||!edge.targetElements.contains(node))
//				error('Node: '+node.name+' cannot have Edge: '+edge.name +'as incoming edge.',MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__INCOMING_EDGES)
//		}
//	}
	
	@Check
	def checkUpperBound(Attribute attribute){
		if(attribute.upperBound==0||attribute.upperBound<-1)
			error("Upper Bound of attribute "+attribute.name+" must be -1 or bigger than 0",MglPackage.Literals::ATTRIBUTE__UPPER_BOUND)
		if(attribute.upperBound<attribute.lowerBound&&attribute.upperBound!=-1)
			error("Upper Bound of attribute "+attribute.name+" can not be lower than Lower Bound",MglPackage.Literals::ATTRIBUTE__UPPER_BOUND)
	}
	
	@Check
	def checkLowerBound(Attribute attribute){
		if(attribute.lowerBound<0)
			error("Lower Bound of attribute "+attribute.name+" cannot be lower than 0.",MglPackage.Literals::ATTRIBUTE__LOWER_BOUND)
		if(attribute.lowerBound>attribute.upperBound&&attribute.upperBound!=-1)
			error("Lower Bound of attribute "+attribute.name+" cannot be larger than Upper Bound.",MglPackage.Literals::ATTRIBUTE__LOWER_BOUND)
	}
	@Check
	def checkReservedWordsInModelElements(ModelElement modelElement){
		
	}
	@Check
	def checkReservedWordsInAttributes(Attribute attr){
		if(attr.name.toUpperCase=="ID")
			error("Attribute Name cannot be "+attr.name+".",MglPackage.Literals::ATTRIBUTE__NAME)	
		
	}
	
//	@Check
//	def checkIsKnownEcoreType(ComplexAttribute attr){
//		
//		if(!attr.instanceAttribute){
//		var GraphModel graphModel
//				try{
//					
//				var element = attr.modelElement as Node
//					graphModel = element.graphModel
//				}catch(ClassCastException c){
//					
//					try{
//						var element = attr.modelElement as Edge
//						graphModel = element.graphModel
//					}catch(ClassCastException ca){
//						
//						try{
//							var element = attr.modelElement as NodeContainer
//							graphModel = element.graphModel
//						}catch(ClassCastException cb){
//							
//							try{
//								graphModel = attr.modelElement as GraphModel
//							}catch(ClassCastException cc){
//								try{
//								var element = attr.modelElement as UserDefinedType
//								graphModel = element.eContainer as GraphModel
//							}catch(ClassCastException cf){}								
//							}
//							
//							
//						}
//					}
//				}
//		
//		
//		
//		
//			if(attr.type!=null&&attr.type.startsWith("EMap<")){
//				var map = attr.type.replaceAll("\\s", "")
//				var left = map.substring(5,attr.type.indexOf(","))
//				var right = attr.type.substring(attr.type.indexOf(",")+1).replace(">","")
//				
//				
//				if(!typeKnown(left,graphModel)){
//					error("Left Attribute Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)
//				}
//				if(!typeKnown(right,graphModel)){
//					error("Right Attribute Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)
//				
//				}
//							
//			}else {
//				if(!typeKnown(attr.type,graphModel)){
//					error("Attribute Type Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)	
//				}
//		}
//			}else{
//				if(!(attr.modelElement instanceof Node)){
//					error("Instance Attribute Only allowed on Nodes",MglPackage.Literals::ATTRIBUTE__INSTANCE_ATTRIBUTE)
//				}
			//}
//		}
		
		def boolean typeKnown(String type,GraphModel graphModel){
					var ecorePackageInstance = EcorePackage::eINSTANCE
				return (ecorePackageInstance.getEClassifier(type)!=null)||((ecorePackageInstance.getEClassifier(type)instanceof EClass))||typeDefined(type,graphModel)
						
				
				
		}
	
	def boolean typeDefined(String type, GraphModel model) {
		if(model!=null){
				
					if(type.equals(model.name)){
						return true
						
						}
					
					
					for(element: model.eAllContents.toIterable.filter(typeof(Type))){
						if(element.name.equals(type)){
							return true
						
						}
					}
		}
		return false
	}
		
		
		
		
//		}else if(attr.type.size==2){
//			if(EcorePackage::eINSTANCE.getEClassifier(attr.type.get(0))==null||EcorePackage::eINSTANCE.getEClassifier(attr.type.get(1))==null)
//				error("Attribute Type must be Ecore Type",MglPackage$Literals::ATTRIBUTE__TYPE)
//			if(EcorePackage::eINSTANCE.getEClassifier(attr.type.get(0))instanceof EClass||EcorePackage::eINSTANCE.getEClassifier(attr.type.get(1))instanceof EClass)
//				error("Attribute Type must be EDataType",MglPackage$Literals::ATTRIBUTE__TYPE)
//		}
		
		
		
//	@Check
//	def checkDirectionSet(Edge edge){
//		if(edge.direction==null){
//			var superType = edge.extends
//			while(superType!=null){
//				if(!superType.direction.literal.equals(EdgeDirection::NODIRECTION.literal))
//					return
//				else
//					superType = superType.extends
//			}
//			error("An Edge or its supertypes must have an direction",MglPackage$Literals::GRAPH_MODEL__EDGES)
//			
//		}
//	}
	
//	@Check
//	def checkNodeAlreadyInsourceElements(Edge edge){
//		if(!edge.extends.equals(null)){
//			val nodes = edge.sourceElements
//			val superTypeNodes = edge.extends.sourceElements
//			if(nodes.exists(u | superTypeNodes.contains(u))){
//				error("Node already contained in supertype.",MglPackage.Literals::EDGE__SOURCE_ELEMENTS)	
//			}
//		}
//		
//	}
	@Check
	def checkFeatureNameUnique(Attribute attr){
		
		for(a: attr.modelElement.attributes)
			if(a!=attr&&a.name.equalsIgnoreCase(attr.name))
					error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
				
		var element = attr.modelElement		
		
			
			
			var superType = element.extends
			while(superType!=null && element.checkMGLInheritance.nullOrEmpty){
				
					for(a: superType.attributes){
						if(a.name.equalsIgnoreCase(attr.name))
						if(!(attr instanceof ComplexAttribute) || !(attr as ComplexAttribute).override)
							error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
						
					}
				
				
				
				superType=superType.extends
			}
			
		
	}
	
	@Check
	def checkIsOverridenTypeSuperType(ComplexAttribute attr){
		var e=attr.parent.extends
		while(e!=null){
			e.attributes.filter(ComplexAttribute).forEach[at| if(at.name==attr.name && !attr.type.isSubType(at.type))error("Overriding attribute types must be subtype of overridden attribute types.",MglPackage.Literals::COMPLEX_ATTRIBUTE__TYPE) ]
			e.attributes.filter(PrimitiveAttribute).forEach[at| if(at.name==attr.name)error("Only Complex Attributes can be overridden.",MglPackage.Literals.COMPLEX_ATTRIBUTE__TYPE)]
			e=e.extends
		}
		
	}
	
	def boolean isSubType(Type subtype, Type superType){
		if(subtype instanceof ModelElement && superType instanceof ModelElement){
			var e= (subtype as ModelElement).extends
			while(e!=null){
				if(e==superType)
					return true
				else
					e = e.extends
			}
		}
		false
	}
	
	def ModelElement parent(ComplexAttribute attribute){
		attribute.eContainer as ModelElement
	}
	
	def <T extends ModelElement> getExtends(ModelElement element){
		switch(element){
			Node: element.extends
			Edge: element.extends
			UserDefinedType: element.extends
			GraphModel: element.extends
		}
	}
	
	@Check
	def checkCanResolveEClass(ReferencedEClass ref){
		var eclass = ref.type
		
		
		if(eclass.eIsProxy){
			
			try{
				var EObject obj
				ref.type = EcoreUtil2::resolve(eclass,obj) as EClass
			}catch(Exception e){
				error("Cannot resolve EClass: "+eclass,MglPackage.Literals::REFERENCED_ECLASS__TYPE)
			}
			
		}
		
	}
	
	
	
//	@Check
//	def checkIncomingCardinality(GraphicalModelElement gme){
//		if(gme.minIncoming<0)
//			error("Minimal incoming cardinality cannot be lower than 0",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MIN_INCOMING);
//		if(gme.minIncoming>gme.maxIncoming&&gme.maxIncoming!=-1)
//			error("Minimal incoming cardinality must be equal to or lower than maximal incoming cardinality",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MIN_INCOMING)
//		if(gme.maxIncoming<0&&gme.maxIncoming!=-1)
//			error("Maximal incoming cardinality must equal to or higher than 0",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MAX_INCOMING)
//	}
	
//	@Check
//	def checkOutgoingCardinality(GraphicalModelElement gme){
//		if(gme.minOutgoing<0)
//			error("Minimal outgoing cardinality cannot be lower than 0",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MIN_OUTGOING);
//		if(gme.minOutgoing>gme.maxOutgoing&&gme.maxOutgoing!=-1)
//			error("Minimal outgoing cardinality must be equal to or lower than maximal outgoing cardinality",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MIN_OUTGOING)
//		if(gme.maxOutgoing<0&&gme.maxOutgoing!=-1)
//			error("Maximal outgoing cardinality must equal to or higher than -1",MglPackage.Literals::GRAPHICAL_MODEL_ELEMENT__MAX_OUTGOING)
//	}
	
//	@Check
//	def checkPrimeReferenceIsPrime(ReferencedType refType){
//		var containingNode = refType.eContainer as Node
//		for(node: containingNode.graphModel.nodes){
//			if(node!=containingNode&&node.retrievePrimeReference!=null&&node.retrievePrimeReference.type==refType.type)
//				error("The Same type cannot be referenced by two different Nodes in the same graph model.",MglPackage.Literals::REFERENCED_TYPE__TYPE)
//		} 
//	}
	
//	@Check
//	def checkCanAttributeBeInstantiatedWithDefaultValue(PrimitiveAttribute attr){
//		if(attr.defaultValue!=null){
//			var ecorePackageInstance = EcorePackage::eINSTANCE
//			try{
//			var eDataType = attr.type.type
//			if(eDataType!=null){
//				
//					var obj = eDataType.EPackage.EFactoryInstance.createFromString(eDataType,attr.defaultValue)
//					if(obj==null)
//						 error(String::format("DataType %s cannot be instantiated with default value: %s.",attr.type,attr.defaultValue),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
//				
//			}else{
//				val e = getEnum(attr)
//				if(e!=null){
//					if(!e.literals.contains(attr.defaultValue)){
//						error(String::format("Default value: '%s' is not valid for Enum: '%s'.",attr.defaultValue,attr.type),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
//					
//					}
//				}else{
//					error(String::format("DataType %s cannot be instantiated with default value: %s.",attr.type,attr.defaultValue),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
//				}
//			
//			}
//			}catch(Exception s){
//					error(String::format("DataType %s cannot be instantiated with default value: %s.",attr.type,attr.defaultValue),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
//				
//		
//			}
//		}
//		
//	}
	
	@Check
	def checkNodeInheritsFromNonAbstractPrimeReferenceNode(Node node){
		var currentNode = node
		var noCircles =node.checkMGLInheritance.nullOrEmpty
		while(currentNode.extends!=null && noCircles){
			currentNode = currentNode.extends
			if(!currentNode.isIsAbstract && (currentNode instanceof ReferencedType))
				error(String::format("Node %s inherits from non abstract prime node %s",node.name,currentNode.name),MglPackage.Literals::NODE__EXTENDS)
		}
	}
	
	def getEnum(ComplexAttribute attr) {
		var mgl = attr.modelElement.eContainer as GraphModel
		for(enum :mgl.types.filter(Enumeration))
			if(enum.name.equals(attr.type)){
				return enum;
			}
				
				
		return null;
	}
	
	@Check
	def checkGraphModelHasStyleDocument(GraphModel graphModel){
		if(!graphModel.annotations.exists[x|x.name.equals("style")])
			warning("GraphModel has no Style document. The graphical editor will not be generated.",MglPackage.Literals::TYPE__NAME);
	}
	
	@Check
	def checkGraphicalModelElementHasStyleAnnotation(GraphicalModelElement graphicalModelElement){
		if(!graphicalModelElement.annotations.exists[x|x.name.equals("style")] && !graphicalModelElement.isIsAbstract)
			warning("Graphical Model Element has no Style annotation.",MglPackage.Literals::TYPE__NAME)
	}
	
	@Check
	def checkAbstractGraphicalModelElementHasUselessAnnotations(GraphicalModelElement graphicalModelElement) {
		if (graphicalModelElement.isIsAbstract && graphicalModelElement.annotations.exists[x | x.name.equals("style")])
			warning("@style annotation has no effect on abstract elements", MglPackage.Literals::TYPE__NAME)
		if (graphicalModelElement.isIsAbstract && graphicalModelElement.annotations.exists[x | x.name.equals("icon")])
			warning("@icon annotation has no effect on abstract elements", MglPackage.Literals::TYPE__NAME)
		if (graphicalModelElement.isIsAbstract && graphicalModelElement.annotations.exists[x | x.name.equals("palette")])
			warning("@palette annotation has no effect on abstract elements", MglPackage.Literals::TYPE__NAME)
	}
	
//	@Check
//	def checkReferencedAttributeMatchesReferencedType(ReferencedAttribute attr){
//		if(attr.referencedType.type!=attr.feature.EType)
//			error("prime attribute must be an attribute from the prime reference",MglPackage.Literals::REFERENCED_ATTRIBUTE__FEATURE)
//		
//	}
	@Check
	def checkGraphModelContainableElements(ContainingElement model){
		if(model.containableElements.size>1){
			for(containment:model.containableElements){
				if(containment.types==null)
					error("Dont't care type must not be accompanied by other containable elements.",MglPackage.Literals::CONTAINING_ELEMENT__CONTAINABLE_ELEMENTS);
			}
		}
		if(model.containableElements.size==1){
			if(model.containableElements.get(0).types == null)
				if(model.containableElements.get(0).upperBound==0)
					warning("Container element cannot contain any model elements by this definition.",MglPackage.Literals::CONTAINING_ELEMENT__CONTAINABLE_ELEMENTS)
		}
	}
	
	@Check
	def checkBoundedConstraintCardinality(BoundedConstraint bc){
		var lower= bc.lowerBound
		var upper = bc.upperBound
		
		if(lower<0)
			error("Containment lower bound must not be lower 0.",MglPackage.Literals::BOUNDED_CONSTRAINT__LOWER_BOUND)
		if(lower>upper&&upper!=-1)
			error("Containment lower bound must not be bigger than upper bound.",MglPackage.Literals::BOUNDED_CONSTRAINT__LOWER_BOUND)
		if(upper<-1)
			error("Containment upper bound must not be lower -1",MglPackage.Literals::BOUNDED_CONSTRAINT__UPPER_BOUND)
	}
	
	@Check
	def checkDiagramExtensionisNotEmpty(GraphModel m){
		if(m.fileExtension.nullOrEmpty){
			error("The Diagram must have an extension.",MglPackage.Literals::GRAPH_MODEL__FILE_EXTENSION)
		}
	}
	
	@Check
	def checkGraphModelIconPath(GraphModel gm) {
		if (!gm.iconPath.nullOrEmpty) {
			val retVal = PathValidator.checkPath(gm, gm.iconPath) as String
 			if (!retVal.empty)
 				error(retVal, MglPackage.Literals.GRAPH_MODEL__ICON_PATH, "The specified path: \"" + gm.iconPath +"\" does not exist")
 		}
	}
	
	@Check
	def checkGraphModelImportUris(Import imp) {
		val retVal = PathValidator.checkPath(imp, imp.importURI)
		if (!retVal.nullOrEmpty)
			error(retVal, MglPackage.Literals.IMPORT__IMPORT_URI, "Could not load resource")
	}
	
	@Check
	def checkGraphModelNameFileName(GraphModel gm) {
		val gmName = gm.name
		if (!gm.eResource.URI.trimFileExtension.lastSegment.equals(gmName)) {
			error("The graph model \"" + gmName + "\" must match the file name", MglPackage.Literals.TYPE__NAME)
		}
	}
	
	@Check
	def checkMGLInheritanceCircles(ModelElement me) {
			var retvalList = me.checkMGLInheritance
			if (!retvalList.nullOrEmpty) {
				if (me instanceof Node)
					error("Circle in inheritance caused by: " + retvalList, MglPackage.Literals.NODE__EXTENDS)
				if (me instanceof Edge)
					error("Circle in inheritance caused by: " + retvalList, MglPackage.Literals.EDGE__EXTENDS)
				if (me instanceof UserDefinedType){
					error("Circle in inheritance caused by: " + retvalList, MglPackage.Literals.USER_DEFINED_TYPE__EXTENDS)
				}
			}
	}
	@Check
	def checkContainerInheritsFromContainer(NodeContainer nc){
		if(nc.extends!=null&&!(nc.extends instanceof NodeContainer)){
			error("Inheriting from Nodes is not possible for Containers.", MglPackage.Literals.NODE__EXTENDS)
		}
	}
	
	@Check
	def checkNodeInheritsFromNode(Node node){
		if(!(node instanceof NodeContainer)&&node.extends!=null&&(node.extends instanceof NodeContainer)){
			error("Inheriting from Containers is not possible for Nodes.", MglPackage.Literals.NODE__EXTENDS)
		}
	}
	
	@Check
	def checkHasFinalDefaultValue(Attribute attr){
		if(attr.notChangeable)
			if(attr.defaultValue==null||attr.defaultValue=="")
				error("Final Attribute must have a default value",MglPackage.Literals.ATTRIBUTE__NOT_CHANGEABLE)
	}
	
	@Check
	def checkIsPackageNameValidJavaPackageName(GraphModel gm){
		var splitPN = gm.package.split("\\.")
		for(part:splitPN){
			var ca = part.toCharArray
			var i=0;
			while(i<ca.length){
				if(i==0)
					if(!Character.isJavaIdentifierStart(ca.get(i)))
						error("Character "+ca.get(i)+" is no valid Java identifier start.",MglPackage.Literals.GRAPH_MODEL__PACKAGE);
						
				if(!Character.isJavaIdentifierPart(ca.get(i)))
						error("Character "+ca.get(i)+" is no valid Java identifier part.",MglPackage.Literals.GRAPH_MODEL__PACKAGE);
							
				i = i+1
			}
				
		}
	}
	
	@Check
	def checkReferencedNodeHasNameAttribute(ComplexAttribute attribute) {
		val modelElement = attribute.modelElement as ModelElement
		val graphModel = getGraphModel(modelElement)
		
		val refNodes = graphModel.nodes.filter[Node n | n.name.equals(attribute.type)]
		val refEdges = graphModel.edges.filter[Edge e | e.name.equals(attribute.type)]		
		
		if ((!refNodes.nullOrEmpty || !refEdges.nullOrEmpty)) {
			if (!nodesContainsName(refNodes) && !edgesContainsName(refEdges))
				error("Add a String attribute \"name\" to the NodeType(s): " + refNodes.map[name], MglPackage.Literals.COMPLEX_ATTRIBUTE__TYPE)
		}
	}
	
	def edgesContainsName(Iterable<Edge> edges) {
		val parentEdges = new ArrayList<Edge> 
		for (Edge e : edges) {
			var currentParent = e
			while (currentParent != null) {
				parentEdges.add(currentParent)
				currentParent = currentParent.extends
			}
		}
		val remainingParents = parentEdges.filter[Edge p |  p.attributes.map[name].contains("name")]
		return !remainingParents.isEmpty 
	}
	
	def nodesContainsName(Iterable<Node> nodes) {
		val parentNodes = new ArrayList<Node> 
		for (Node n : nodes) {
			var currentParent = n
			while (currentParent != null) {
				parentNodes.add(currentParent)
				currentParent = currentParent.extends
			}
		}
		val remainingParents = parentNodes.filter[Node p |  p.attributes.map[name].contains("name")]
		return !remainingParents.isEmpty 
	}
	
	def getGraphModel(ModelElement element) {
		switch element {
			Node : element.graphModel
			Edge : element.graphModel
		}
	}
	
	@Check 
	def checkContainableElementIsIndependent(GraphicalElementContainment e){
		var superType = getContainingSuperType(e.containingElement)
		while(superType!=null){
			
			if(superType.containableElements.exists[y | y.types.exists[x|e.types.contains(x)]]){
				error("Containment must be independent from inherited containments",MglPackage.Literals.GRAPHICAL_ELEMENT_CONTAINMENT__TYPES)
			}
			
			superType = getContainingSuperType(superType)
		}
		
	}
	
	
	
	def <T extends ContainingElement> T getContainingSuperType(T modelElement){
		switch(modelElement){
			GraphModel: (modelElement.extends) as T
			NodeContainer: (modelElement.extends) as T 
		} 
	}
	
	@Check
	def checkRightType(ReferencedType refType){
		
	}
	
	@Check
	def checkColorAnnotation(Annotation a) {
		if (a.name.equals("color")) {
		
		if((a.value.size == 1)){ //one parameter allowed
			if (a.parent instanceof PrimitiveAttribute) { //only correct Type (EString)
				val attr = a.parent as PrimitiveAttribute
				if(!attr.type.getName.equals("EString")){
					error("Attribute type has to be EString",MglPackage.Literals.ANNOTATION__NAME)
				}
				if(a.value.get(0).equals("rgb")){
					if(!(attr.defaultValue.empty) || attr.defaultValue.empty != ""){ //correct default values
						val defaultValue = attr.defaultValue
								var result = defaultValue.split(",")
								if(result.size !=3){
									error("default value doesn't have a RGB-scheme", MglPackage.Literals.ANNOTATION__NAME)
								}
								else{
									var r_string = result.get(0)
									var g_string = result.get(1)
									var b_string = result.get(2)
									try{
										var r = Integer.parseInt(r_string)	
										var g = Integer.parseInt(g_string)
										var b = Integer.parseInt(b_string)
										
										if(r < 0 || r > 255){
											error("r-value has to be bigger or equal than 0 and lower or equal than 255 ", MglPackage.Literals.ANNOTATION__NAME )
										}
										if(g < 0 || g > 255){
											error("g-value has to be bigger or equal than 0 and lower or equal than 255 ", MglPackage.Literals.ATTRIBUTE__DEFAULT_VALUE )
										}
										if(b < 0 || b > 255){
											error("b-value has to be bigger or equal than 0 and lower or equal than 255 ", MglPackage.Literals.ATTRIBUTE__DEFAULT_VALUE )
										}
									
									}catch(Exception e){
										error("Please enter only numbers as default value", MglPackage.Literals.ANNOTATION__NAME)
									}
						
								}
				
					}					
				}
				else if (a.value.get(0).equals("hex")){ //check default values
					
				}
			}
			else {
				error("Attribute has to be a PrimitiveAttribute ", MglPackage.Literals.ANNOTATION__NAME)
			}
			
		}
		else{
			error("color Annotation needs exactly one parameter like rgb, hex,...", MglPackage.Literals.ANNOTATION__VALUE)
		}
	}
}
	
	
	
	@Check
	def checkFileAnnotations(Annotation a){
		if (a.name.equals("file") && a.parent instanceof PrimitiveAttribute) { //only correct Type (EString)
			val attr = a.parent as PrimitiveAttribute
			if(!attr.type.getName.equals("EString")){
				error("Type has to be EString",MglPackage.Literals.ANNOTATION__NAME)
			}
			if(!(attr.defaultValue.empty) || attr.defaultValue.empty != ""){ //only correct default values
				val defaultValue = attr.defaultValue
				try{
					 file = new File(defaultValue);
					 if(!file.exists){
					 	error("Wrong Path: File doesn't exists", MglPackage.Literals.ANNOTATION__NAME)
					 }
				}
				catch (Exception e){
					error("Wrong Path: File doesn't exists", MglPackage.Literals.ANNOTATION__NAME)
				}
			}
		}
		
	}
}
	
