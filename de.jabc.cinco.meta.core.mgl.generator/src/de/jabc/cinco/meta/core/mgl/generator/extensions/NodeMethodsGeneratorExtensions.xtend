package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import graphmodel.GraphmodelPackage
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import mgl.Edge
import mgl.EdgeElementConnection
import mgl.GraphModel
import mgl.Node
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EOperation

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.utils.InheritanceUtil.*

class NodeMethodsGeneratorExtensions {
	static def Iterable<? extends EOperation> createConnectionMethods(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses){
		 val eOps = new ArrayList<EOperation>
		 
		 eOps +=  node.connectionConstraints(graphModel,elmClasses)
		 eOps += node.specializeGetSuccessors(graphModel,elmClasses)
		// eOps += node.canEndMethods(graphModel,elmClasses)
		// eOps += node.startMethods(graphModel,elmClasses)
		 //eOps += node.endMethods(graphModel,elmClasses)
		 
		 eOps
		 
	}
	
	static def EOperation specializeGetSuccessors(Node node, GraphModel model, HashMap<String, ElementEClasses> map) {
		
		val nodeClass = map.get(node.name).mainEClass

		val lmNode = node.possibleSuccessors.lowestMutualSuperNode
		val eTypeClass = if(lmNode==null)
			GraphmodelPackage.eINSTANCE.getEClassifier("Node") as EClass
			 else map.get(lmNode.name).mainEClass
		
		nodeClass.createEOperation("getSuccessors",eTypeClass,0,-1,eTypeClass.getSuccessorsContent.toString)
	}
	
	static def getSuccessorsContent(EClass eTypeClass)'''
		return getSuccessors(«eTypeClass.name».class);
	'''
	
	static def EOperation connectionConstraints(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses){
		val  incomingContent = (node.incomingConnectionConstraintsContent).toString
		val  outgoingContent = (node.outgoingConnectionConstraintsContent).toString
		val nodeClass = elmClasses.get(node.name).mainEClass
		val connectionConstraintClassifier = GraphmodelPackage.eINSTANCE.getEClassifier("ConnectionConstraint")
		nodeClass.createEOperation("getIncomingConnectionConstraints",connectionConstraintClassifier,0,-1,incomingContent)
		nodeClass.createEOperation("getOutgoingConnectionConstraints",connectionConstraintClassifier,0,-1,outgoingContent)
		
		
	}
	
	static def incomingConnectionConstraintsContent(Node node)'''
	
	 «FOR pair: node.incomingEdgeConnections.indexed»
	 
	 ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.incomingEdgeConnections.get(pair.key).lowerBound»,«node.incomingEdgeConnections.get(pair.key).upperBound»,«node.incomingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
	 «ENDFOR»
	 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
	 	 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.incomingEdgeConnections.constraintVariables»));
	 	 		return eList;
	'''
	
	
	static def outgoingConnectionConstraintsContent(Node node)'''
	
	 «FOR pair: node.outgoingEdgeConnections.indexed»	 
	 ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.outgoingEdgeConnections.get(pair.key).lowerBound»,«node.outgoingEdgeConnections.get(pair.key).upperBound»,«node.outgoingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
	 «ENDFOR»
	 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
	 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.outgoingEdgeConnections.constraintVariables»));
	 		return eList;
	'''
	
	static def String edgesList(Iterable<Edge> edges){
		edges.map[edge| new GeneratorUtils().fqBeanName(edge)+".class"].join(",")
	}
	
	static def constraintVariables(Iterable<? extends EdgeElementConnection> connections){
		val vars = new ArrayList<String>
		connections.forEach[c,i|vars+="cons"+i]
		vars.join(",")
	}
	
	static def List<Node> possibleSuccessors(Node node){
		
	} 
}