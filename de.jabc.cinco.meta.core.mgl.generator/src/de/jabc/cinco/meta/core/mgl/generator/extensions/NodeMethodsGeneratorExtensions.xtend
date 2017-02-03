package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.GraphmodelPackage
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import mgl.ContainingElement
import mgl.Edge
import mgl.EdgeElementConnection
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.IncomingEdgeElementConnection
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.utils.InheritanceUtil.*

class NodeMethodsGeneratorExtensions extends GeneratorUtils{
	 def void createConnectionMethods(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses){
		 val eOps = new ArrayList<EOperation>
		 
		 node.connectionConstraints(graphModel,elmClasses)
		 node.specializeGetSuccessors(graphModel,elmClasses)
		// eOps += node.canEndMethods(graphModel,elmClasses)
		// eOps += node.startMethods(graphModel,elmClasses)
		 //eOps += node.endMethods(graphModel,elmClasses)
		 
		 
	}
	
	 def void createGetContainmentConstraintsMethod(NodeContainer elem, GraphModel graphModel,HashMap<String, ElementEClasses> elmClasses ){
		
		val elc = elmClasses.get(elem.name)
		elc.internalEClass.createEOperation("getContainmentConstraints",GraphmodelPackage.eINSTANCE.containmentConstraint,0,-1,elc.modelElement.containmentConstraintContent.toString);
		
	}
	

	def containmentConstraintContent(ModelElement modelElement)'''
	 org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>constraints = 
		new org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>();
	«FOR ce: (modelElement as ContainingElement).containableElements»
	«ce.containmentConstraint»
	«ENDFOR»
	constraints.addAll(super.getContainmentConstraints());
	return constraints;
	
	'''
	def containmentConstraint(GraphicalElementContainment gec)'''
	constraints.add(new ContainmentConstraint(«gec.lowerBound»,«gec.upperBound»,«gec.types.map[fqBeanName+".class"].join(",")»));
	'''
	

	def EParameter classParam(EClass gen, String name){
		val param = EcoreFactory.eINSTANCE.createEParameter
		param.name = name
		param.upperBound = -1
		val javaEClass = EcorePackage.eINSTANCE.EJavaClass
		
		val eGenType = EcoreFactory.eINSTANCE.createEGenericType
		val eGenType2 = EcoreFactory.eINSTANCE.createEGenericType
		eGenType.EClassifier = javaEClass
		eGenType2.EClassifier = gen
		val eTypeArgument = EcoreFactory.eINSTANCE.createEGenericType
		eTypeArgument.EUpperBound=eGenType2
		eGenType.ETypeArguments.add(eTypeArgument)
		param.EGenericType = eGenType
		param
		
	}
	
	def specializeGetSuccessors(Node node, GraphModel model, HashMap<String, ElementEClasses> map) {
		
		val nodeClass = map.get(node.name).internalEClass

		val lmNode = node.possibleSuccessors.lowestMutualSuperNode
		val eTypeClass = if(lmNode==null)
			GraphmodelPackage.eINSTANCE.getEClassifier("Node") as EClass
			 else map.get(lmNode.name).mainEClass
		
		nodeClass.createEOperation("getSuccessors",eTypeClass,0,-1,eTypeClass.getSuccessorsContent.toString)
	}
	
	def getSuccessorsContent(EClass eTypeClass)'''
		return ((Node)this.getElement()).getSuccessors(«eTypeClass.name».class);
	'''
	
	 def void connectionConstraints(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses){
		val  incomingContent = (node.incomingConnectionConstraintsContent).toString
		val  outgoingContent = (node.outgoingConnectionConstraintsContent).toString
		val nodeClass = elmClasses.get(node.name).internalEClass
		val connectionConstraintClassifier = GraphmodelPackage.eINSTANCE.getEClassifier("ConnectionConstraint")
		nodeClass.createEOperation("getOutgoingConstraints",connectionConstraintClassifier,0,-1,outgoingContent)
		nodeClass.createEOperation("getIncomingConstraints",connectionConstraintClassifier,0,-1,incomingContent)
		
		
	}
	
	def incomingConnectionConstraintsContent(Node node)'''
	
	 «FOR pair: node.incomingEdgeConnections.indexed»
	 
	 ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.incomingEdgeConnections.get(pair.key).lowerBound»,«node.incomingEdgeConnections.get(pair.key).upperBound»,«node.incomingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
	 «ENDFOR»
	 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
	 	 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.incomingEdgeConnections.constraintVariables»));
	 	 		return eList;
	'''
	
	
	def outgoingConnectionConstraintsContent(Node node)'''
	
	 «FOR pair: node.outgoingEdgeConnections.indexed»	 
	 ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.outgoingEdgeConnections.get(pair.key).lowerBound»,«node.outgoingEdgeConnections.get(pair.key).upperBound»,«node.outgoingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
	 «ENDFOR»
	 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
	 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.outgoingEdgeConnections.constraintVariables»));
	 		return eList;
	'''
	
	def String edgesList(Iterable<Edge> edges){
		edges.map[edge| new GeneratorUtils().fqBeanName(edge)+".class"].join(",")
	}
	
	def constraintVariables(Iterable<? extends EdgeElementConnection> connections){
		val vars = new ArrayList<String>
		connections.forEach[c,i|vars+="cons"+i]
		vars.join(",")
	}
	
	def List <Node> possibleSuccessors(Node node){
		node.outgoingEdgeConnections.map[
			connectingEdges.map[
				edge| edge.edgeElementConnections.filter(IncomingEdgeElementConnection).map[connectedElement]
			]
		].flatten.flatten.map[it as Node].toList
	} 
}