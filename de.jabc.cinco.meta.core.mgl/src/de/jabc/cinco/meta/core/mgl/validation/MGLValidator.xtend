/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.core.mgl.validation

import mgl.Attribute
import mgl.ContainingElement
import mgl.Edge
import mgl.EdgeElementConnection
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.GraphicalModelElement
import mgl.MglPackage
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedType
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class MGLValidator extends AbstractMGLValidator {

	
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
	def checkEdgeElementConnectionCardinalities( EdgeElementConnection eec){
		if(eec.lowerBound<0)
			error("Lower Bound cannot be less than 0", MglPackage.Literals::EDGE_ELEMENT_CONNECTION__LOWER_BOUND)
		if(eec.lowerBound>eec.upperBound&&eec.upperBound!=-1)
			error("Lower Bound cannot be bigger than upper bound.", MglPackage.Literals::EDGE_ELEMENT_CONNECTION__LOWER_BOUND)
		if(eec.upperBound<-1)
			error("Lower Bound cannot be less than -1", MglPackage.Literals::EDGE_ELEMENT_CONNECTION__LOWER_BOUND)
		
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
	
	@Check
	def checkIsKnownEcoreType(Attribute attr){
		
		if(!attr.instanceAttribute){
		var GraphModel graphModel
				try{
					
				var element = attr.modelElement as Node
					graphModel = element.graphModel
				}catch(ClassCastException c){
					
					try{
						var element = attr.modelElement as Edge
						graphModel = element.graphModel
					}catch(ClassCastException ca){
						
						try{
							var element = attr.modelElement as NodeContainer
							graphModel = element.graphModel
						}catch(ClassCastException cb){
							
							try{
								graphModel = attr.modelElement as GraphModel
							}catch(ClassCastException cc){
								try{
								var element = attr.modelElement as UserDefinedType
								graphModel = element.eContainer as GraphModel
							}catch(ClassCastException cf){}								
							}
							
							
						}
					}
				}
		
		
		
		
			if(attr.type!=null&&attr.type.startsWith("EMap<")){
				var map = attr.type.replaceAll("\\s", "")
				var left = map.substring(5,attr.type.indexOf(","))
				var right = attr.type.substring(attr.type.indexOf(",")+1).replace(">","")
				
				
				if(!typeKnown(left,graphModel)){
					error("Left Attribute Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)
				}
				if(!typeKnown(right,graphModel)){
					error("Right Attribute Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)
				
				}
							
			}else {
				if(!typeKnown(attr.type,graphModel)){
					error("Attribute Type Unknown",MglPackage.Literals::ATTRIBUTE__TYPE)	
				}
		}
			}else{
				if(!(attr.modelElement instanceof Node)){
					error("Instance Attribute Only allowed on Nodes",MglPackage.Literals::ATTRIBUTE__INSTANCE_ATTRIBUTE)
				}
				if((attr.modelElement as Node).primeReference==null){
					error("Prime Reference must be set for Instance Attribute",MglPackage.Literals::ATTRIBUTE__INSTANCE_ATTRIBUTE)
				}
			}
		}
		
		def boolean typeKnown(String type,GraphModel graphModel){
					var ecorePackageInstance = EcorePackage::eINSTANCE
				return (ecorePackageInstance.getEClassifier(type)!=null)||((ecorePackageInstance.getEClassifier(type)instanceof EClass))||typeDefined(type,graphModel)
						
				
				
		}
	
	def boolean typeDefined(String type, GraphModel model) {
		if(model!=null){
				
					if(type.equals(model.name)){
						return true
						
						}
					
					//println(graphModel)
					
					for(element: model.eAllContents.toIterable.filter(typeof(Type))){
						//println(element)
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
			if(a!=attr&&a.name==attr.name)
				error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
		if(attr.modelElement instanceof Edge){
			var element = attr.modelElement as Edge
			
			var superType = element.extends
			while(superType!=null){
				
					for(a: superType.attributes){
						if(a.name==attr.name)
							error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
						
					}
				
				
				
				superType=superType.extends				
			}
			
		}else if(attr.modelElement instanceof Node){
			
			var element = attr.modelElement as Node
			
			var superType = element.extends
			while(superType!=null){
				for(a: superType.attributes){
						if(a.name==attr.name)
							error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
						
					}
				
				
				superType=superType.extends				
			}
		}else if(attr.modelElement instanceof GraphModel){
			var element = attr.modelElement as GraphModel
			var superType = element.extends
			while(superType!=null){
				
					for(a: superType.attributes){
						if(a.name==attr.name)
							error("Attribute Names must be unique",MglPackage.Literals::ATTRIBUTE__NAME)
						
					}
				
				
			
				superType=superType.extends				
			}
		}
	}
	@Check
	def checkCanResolveEClass(ReferencedType ref){
		var eclass = ref.type
		
		
		if(eclass.eIsProxy){
			
			try{
				var EObject obj
				ref.type = EcoreUtil2::resolve(eclass,obj) as EClass
			}catch(Exception e){
				error("Cannot resolve EClass: "+eclass,MglPackage.Literals::REFERENCED_TYPE__TYPE)
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
	
	@Check
	def checkPrimeReferenceIsPrime(ReferencedType refType){
		var containingNode = refType.eContainer as Node
		for(node: containingNode.graphModel.nodes){
			if(node!=containingNode&&node.primeReference!=null&&node.primeReference.type==refType.type)
				error("The Same type cannot be referenced by two different Nodes in the same graph model.",MglPackage.Literals::REFERENCED_TYPE__TYPE)
		} 
	}
	
	@Check
	def checkCanAttributeBeInstantiatedWithDefaultValue(Attribute attr){
		if(attr.defaultValue!=null){
			var ecorePackageInstance = EcorePackage::eINSTANCE
			try{
			var eDataType = ecorePackageInstance.getEClassifier(attr.type)as EDataType
			if(eDataType!=null){
				
					var obj = eDataType.EPackage.EFactoryInstance.createFromString(eDataType,attr.defaultValue)
					if(obj==null)
						 error(String::format("DataType %s cannot be instantiated with default value: %s.",attr.type,attr.defaultValue),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
				
			}else{
				error("Default Value cannot be set, if type of attribute is not an EDataType",MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
			}
			}catch(Exception s){
					error(String::format("DataType %s cannot be instantiated with default value: %s.",attr.type,attr.defaultValue),MglPackage.Literals::ATTRIBUTE__DEFAULT_VALUE)
				
		
			}
		}
		
	}
	@Check
	def checkGraphModelHasStyleDocument(GraphModel graphModel){
		if(!graphModel.annotations.exists[x|x.name.equals("Style")])
			error("GraphModel must have a Style document.",graphModel.eClass.getEStructuralFeature("annotations"));
	}
	
	@Check
	def checkGraphicalModelElementHasStyleAnnotation(GraphicalModelElement graphicalModelElement){
		if(!graphicalModelElement.annotations.exists[x|x.name.equals("Style")])
			error("GraphModel must have a Style annotation.",graphicalModelElement.eClass.getEStructuralFeature("annotations"))
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
				if(containment.type==null)
					error("Dont't care type must not be accompanied by other containable elements.",MglPackage.Literals::CONTAINING_ELEMENT__CONTAINABLE_ELEMENTS);
			}
		}
		if(model.containableElements.size==1){
			if(model.containableElements.get(0).type == null)
				if(model.containableElements.get(0).upperBound==0)
					warning("Container element cannot contain any model elements by this definition.",MglPackage.Literals::CONTAINING_ELEMENT__CONTAINABLE_ELEMENTS)
		}
	}
	
	@Check
	def checkContainableElementsCardinality(GraphicalElementContainment containment){
		var lower= containment.lowerBound
		var upper = containment.upperBound
		
		if(lower<0)
			error("Containment lower bound must not be lower 0.",MglPackage.Literals::GRAPHICAL_ELEMENT_CONTAINMENT__LOWER_BOUND)
		if(lower>upper&&upper!=-1)
			error("Containment lower bound must not be bigger than upper bound.",MglPackage.Literals::GRAPHICAL_ELEMENT_CONTAINMENT__LOWER_BOUND)
		if(upper<-1)
			error("Containment upper bound must not be lower -1",MglPackage.Literals::GRAPHICAL_ELEMENT_CONTAINMENT__UPPER_BOUND)
	}
	
	
	
}
