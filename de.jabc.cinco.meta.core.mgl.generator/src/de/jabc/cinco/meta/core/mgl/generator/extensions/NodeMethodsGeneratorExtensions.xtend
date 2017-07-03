package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.GraphmodelPackage
import graphmodel.ModelElementContainer
import graphmodel.internal.InternalNode
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
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
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*

class NodeMethodsGeneratorExtensions extends GeneratorUtils {

	def void createConnectionMethods(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses) {
		val eOps = new ArrayList<EOperation>

		node.connectionConstraints(graphModel, elmClasses)
		node.specializeGetSuccessors(graphModel, elmClasses)

	// eOps += node.canEndMethods(graphModel,elmClasses)
	// eOps += node.startMethods(graphModel,elmClasses)
	// eOps += node.endMethods(graphModel,elmClasses)
	}

	def void createGetContainmentConstraintsMethod(NodeContainer elem, GraphModel graphModel,
		HashMap<String, ElementEClasses> elmClasses) {

		val elc = elmClasses.get(elem.name)
		elc.internalEClass.createEOperation("getContainmentConstraints",
			GraphmodelPackage.eINSTANCE.containmentConstraint, 0, -1,
			elc.modelElement.containmentConstraintContent.toString);

	}

	def containmentConstraintContent(ModelElement modelElement) '''
		 org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>constraints = 
			new org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>();
		«FOR ce : (modelElement as ContainingElement).containableElements»
			«ce.containmentConstraint»
		«ENDFOR»
		constraints.addAll(super.getContainmentConstraints());
		return constraints;
		
	'''

	def containmentConstraint(
		GraphicalElementContainment gec) '''
		constraints.add(new ContainmentConstraint(«gec.lowerBound»,«gec.upperBound»,«gec.types.map[fqBeanName+".class"].join(",")»));
	'''

	def EParameter classParam(EClass gen, String name) {
		val param = EcoreFactory.eINSTANCE.createEParameter
		param.name = name
		param.upperBound = -1
		val javaEClass = EcorePackage.eINSTANCE.EJavaClass

		val eGenType = EcoreFactory.eINSTANCE.createEGenericType
		val eGenType2 = EcoreFactory.eINSTANCE.createEGenericType
		eGenType.EClassifier = javaEClass
		eGenType2.EClassifier = gen
		val eTypeArgument = EcoreFactory.eINSTANCE.createEGenericType
		eTypeArgument.EUpperBound = eGenType2
		eGenType.ETypeArguments.add(eTypeArgument)
		param.EGenericType = eGenType
		param

	}

	/**
	 * Generate the specialized getSuccessors method if the common super node type is *not* {@link graphmodel.Node}
	 * The method for the common super type {@link graphmodel.Node} is implemented in 
	 * {@link graphmodel.Node#getSuccessors}
	 */
	def specializeGetSuccessors(Node node, GraphModel model, HashMap<String, ElementEClasses> map) {

		val nodeClass = map.get(node.name).internalEClass

		val lmNode = node.possibleSuccessors.lowestMutualSuperNode
		val eTypeClass = if (lmNode == null)
				return
			else
				map.get(lmNode.name).mainEClass
				
		nodeClass.createEOperation("getSuccessors", eTypeClass, 0, -1, eTypeClass.getSuccessorsContent.toString)
	}

	def getSuccessorsContent(EClass eTypeClass) '''
		return ((graphmodel.Node)this.getElement()).getSuccessors(«eTypeClass.name».class);
	'''

	def void connectionConstraints(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses) {
		val incomingContent = (node.incomingConnectionConstraintsContent).toString
		val outgoingContent = (node.outgoingConnectionConstraintsContent).toString
		val nodeClass = elmClasses.get(node.name).internalEClass
		val connectionConstraintClassifier = GraphmodelPackage.eINSTANCE.getEClassifier("ConnectionConstraint")
		nodeClass.createEOperation("getOutgoingConstraints", connectionConstraintClassifier, 0, -1, outgoingContent)
		nodeClass.createEOperation("getIncomingConstraints", connectionConstraintClassifier, 0, -1, incomingContent)
	}

	def incomingConnectionConstraintsContent(
		Node node) '''
		
		 «FOR pair : node.incomingEdgeConnections.indexed»
		 	
		 	ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.incomingEdgeConnections.get(pair.key).lowerBound»,«node.incomingEdgeConnections.get(pair.key).upperBound»,«node.incomingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
		 «ENDFOR»
		 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
		 	 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.incomingEdgeConnections.constraintVariables»));
		 	 		return eList;
	'''

	def outgoingConnectionConstraintsContent(
		Node node) '''
		
		 «FOR pair : node.outgoingEdgeConnections.indexed»	 
		 	ConnectionConstraint cons«pair.key» = new ConnectionConstraint(false,«node.outgoingEdgeConnections.get(pair.key).lowerBound»,«node.outgoingEdgeConnections.get(pair.key).upperBound»,«node.outgoingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
		 «ENDFOR»
		 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
		 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.outgoingEdgeConnections.constraintVariables»));
		 		return eList;
	'''

	def createCanNewEdgeMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val edges = node.outgoingConnectingEdges
		for (edge : edges) {
			val operationName = "canNew" + edge.fuName
			val edgeEClass = elemClasses.get(edge.name).mainEClass
			for (target : edge.possibleTargets) {
				val sourceEClass = elemClasses.get(node.name).mainEClass
				val targetEClass = elemClasses.get(target.name).mainEClass
				val content = edge.canNewEdgeMethodContent
				sourceEClass.createEOperation(operationName, EcorePackage.eINSTANCE.EBoolean, 0, 1, content,
					targetEClass.createEParameter("target", 1, 1))
			}
		}
	}

	def canNewEdgeMethodContent(Edge edge) '''
		return this.canStart(«edge.fuName».class) && target.canEnd(«edge.fuName».class);
	'''

	def createNewEdgeMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val edges = node.outgoingConnectingEdges
		for (edge : edges) {
			val operationName = "new" + edge.fuName
			val edgeEClass = elemClasses.get(edge.name).mainEClass
			for (target : edge.possibleTargets) {
				val sourceEClass = elemClasses.get(node.name).mainEClass
				val targetEClass = elemClasses.get(target.name).mainEClass
				val content = node.newEdgeMethodContent(edge)
				sourceEClass.createEOperation(operationName, edgeEClass, 0, 1, content,
					targetEClass.createEParameter("target", 1, 1))
			}
		}
	}

	def newEdgeMethodContent(Node node, Edge edge) '''
		if (target.canEnd(«edge.fuName».class)) {
			«edge.fqBeanName» edge = «node.fqFactoryName».eINSTANCE.create«edge.fuName»();
			edge.setSourceElement(this);
			edge.setTargetElement(target);
			return edge;
		}
		else return null;
	'''

	
	def createCanMoveToMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val containers = node.possibleContainers
		val nodeEClass = elemClasses.get(node.name).mainEClass
		containers.forEach[
			c |	nodeEClass.createEOperation(
					"canMoveTo",
					EcorePackage.eINSTANCE.EBoolean,
					1,
					1,
					node.canMoveToMethodContent(c),
					elemClasses.get(c.name).mainEClass.createEParameter(c.name.toFirstLower,1,1), 
					createEInt("x",1,1), 
					createEInt("y",1,1)
			)
		]
	}

	def canMoveToMethodContent(Node node, ContainingElement ce) '''
		return «ce.name.toFirstLower».canContain(«node.fqBeanName».class);
	'''
	

	def createMoveToMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val containers = node.possibleContainers
		val nodeEClass = elemClasses.get(node.name).mainEClass
		containers.forEach[
			c |	nodeEClass.createEOperation("moveTo",null,1,1,node.moveToMethodContent(c), 
					elemClasses.get(c.name).mainEClass.createEParameter(c.name.toFirstLower,1,1), createEInt("x",1,1), createEInt("y",1,1)
				)
				
				nodeEClass.createEOperation("_moveTo",null,1,1,node._moveToMethodContent(c), 
					elemClasses.get(c.name).mainEClass.createEParameter(c.name.toFirstLower,1,1), createEInt("x",1,1), createEInt("y",1,1)
				)
		]
		
		nodeEClass.createEOperation("postMove", null,1,1,node.postMoveContent,
			GraphmodelPackage.eINSTANCE.modelElementContainer.createEParameter("source",1,1),
			GraphmodelPackage.eINSTANCE.modelElementContainer.createEParameter("target",1,1),
			createEInt("x",1,1),
			createEInt("y",1,1),
			createEInt("deltaX",1,1), 
			createEInt("deltaY",1,1)
		)
	}

	def moveToMethodContent(Node node, ContainingElement ce) '''
		«ModelElementContainer.name» source = this.getContainer();
		int deltaX = ((«InternalNode.name») this.getInternalElement()).getX();
		int deltaY = ((«InternalNode.name») this.getInternalElement()).getY();
		_moveTo(«ce.name.toFirstLower», x, y);
		«IF node.booleanWriteMethodCallPostMove»
		postMove(source, «ce.name.toFirstLower», x,y, deltaX, deltaY);
		«ENDIF»
	'''

	def _moveToMethodContent(Node node, ContainingElement ce) '''
		«ce.name.toFirstLower».getInternalContainerElement().getModelElements().add(this.getInternalElement());
		this.move(x, y);
		new «GraphModelExtension.name»().moveEdgesToCommonContainer((«InternalNode.name») this.getInternalElement());
	'''

	def postMoveContent(Node n) '''
		«n.writeMethodCallPostMove("this", "source", "target", "x", "y", "deltaX", "deltaY")»
	'''

	def createCanNewNodeMethods(ContainingElement ce, HashMap<String, ElementEClasses> elemClasses) {
		ce.containableNodes.filter[!isAbstract].forEach[n | 
			elemClasses.get(ce.name).mainEClass.
				createEOperation("canNew"+n.fuName,
					EcorePackage.eINSTANCE.EBoolean,
					1,
					1,
					ce.canNewNodeMethodContent(n)
				)
		]
	}

	def canNewNodeMethodContent(ContainingElement ce, Node n) '''
		return this.canContain(«n.fuName».class);
	'''

	def createNewNodeMethods(ContainingElement ce, Map<String, ElementEClasses> elemClasses) {
		println("the containing element: "+ce)
		println("them elmClasses:" + elemClasses)
		ce.containableNodes.filter[!isIsAbstract].forEach[n | 
			println("the containable node: "+n)
			elemClasses.get(ce.name).mainEClass.
				createEOperation("new"+n.fuName,
					elemClasses.get(n.name).mainEClass,
					1,
					1,
					ce.newNodeSimpleMethodContent(n),
					createEInt("x",1,1),
					createEInt("y",1,1)
				)
				
			elemClasses.get(ce.name).mainEClass.
				createEOperation("new"+n.fuName,
					elemClasses.get(n.name).mainEClass,
					1,
					1,
					ce.newNodeMethodContent(n),
					createEInt("x",1,1),
					createEInt("y",1,1),
					createEInt("width",1,1),
					createEInt("height",1,1)
				)
		]
	} 

	def newNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»();
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			node.move(x, y);
			node.resize(width, height);
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''

	def newNodeSimpleMethodContent(ContainingElement ce, Node n) '''
		return new«n.fuName»(x,y,-1,-1);
	'''

	def createModelElementGetter(ContainingElement ce, GraphModel gm, HashMap<String, ElementEClasses> elmClasses) {
		ce.containableNodes.forEach[
			elmClasses.get(ce.name).mainEClass.createEOperation(
				"get"+fuName+"s",
				elmClasses.get(name).mainEClass,
				0,
				-1,
				modelElementGetterContent
			)
		]
	}

	def modelElementGetterContent(ModelElement me) '''
		return getModelElements(«me.fqBeanName».class);
	'''

	def String edgesList(Iterable<Edge> edges) {
		edges.map[edge|new GeneratorUtils().fqBeanName(edge) + ".class"].join(",")
	}

	def constraintVariables(Iterable<? extends EdgeElementConnection> connections) {
		val vars = new ArrayList<String>
		connections.forEach[c, i|vars += "cons" + i]
		vars.join(",")
	}

	def List<Node> possibleSuccessors(Node node) {
		node.outgoingEdgeConnections.map [
			connectingEdges.map [ edge |
				edge.edgeElementConnections.filter(IncomingEdgeElementConnection).map[connectedElement]
			]
		].flatten.flatten.map[it as Node].toList
	}
}
	