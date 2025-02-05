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
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*
import org.eclipse.core.runtime.Path
import java.io.IOException
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalEdge
import mgl.OutgoingEdgeElementConnection
import mgl.MglPackage
import java.util.Set

class NodeMethodsGeneratorExtensions extends GeneratorUtils {

	var possiblePredecessorsMap = new HashMap<Node,Iterable<Node>>
	var possibleSuccessorsMap = new HashMap<Node,Iterable<Node>>

	def void createConnectionMethods(Node node, GraphModel graphModel, HashMap<String, ElementEClasses> elmClasses) {
		node.connectionConstraints(graphModel, elmClasses)
		node.specializeGetSuccessors(graphModel, elmClasses)
		node.specializeGetPredecessors(graphModel, elmClasses)
	}

	def void createGetContainmentConstraintsMethod(ContainingElement elem,
		HashMap<String, ElementEClasses> elmClasses) {

		val elc = elmClasses.get(elem.name)
		elc.internalEClass.createEOperation("getContainmentConstraints",
			GraphmodelPackage.eINSTANCE.containmentConstraint, 0, -1,
			elem.containmentConstraintContent);

	}

	def containmentConstraintContent(ContainingElement ce) '''
		 org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>constraints = 
			new org.eclipse.emf.common.util.BasicEList<ContainmentConstraint>();
		«FOR cc : ce.allContainmentConstraints.filter[types.size>0]»
			«cc.containmentConstraint»
		«ENDFOR»
		return constraints;
		
	'''

	def containmentConstraint(
		GraphicalElementContainment gec) '''
		constraints.add(new ContainmentConstraint(«gec.lowerBound»,«gec.upperBound»,«containedClasses(gec)»));
	'''
	
	protected def String containedClasses(GraphicalElementContainment gec) {
		if(gec.types.size>0){
			gec.types.map[fqBeanName+".class"].join(",")
		}else{
			(gec.containingElement.eContainer as GraphModel).nodes.map[fqBeanName+".class"].join(",")
		}
		
	}

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
	
		val internalNodeClass = map.get(node.name).internalEClass
		val nodeClass = map.get(node.name).mainEClass
		val lmNode = node.possibleSuccessors.lowestMutualSuperNode
		if (lmNode != null){
			val eTypeClass = map.get(lmNode.name).mainEClass
			nodeClass.createGenericListEOperation("getSuccessors", eTypeClass, lmNode.getSuccessorsContent.toString)
		}
		node.possibleSuccessors.toSet.forEach[ predecessorNode |
			val successorClass = map.get(predecessorNode.name).mainEClass
			val methodName = "get"+predecessorNode.name.toFirstUpper+"Successors"
			internalNodeClass.createEOperation(methodName, successorClass, 0, -1, predecessorNode.getInternalSuccessorsContent.toString)
			nodeClass.createEOperation(methodName, successorClass, 0, -1, predecessorNode.getSuccessorsContent.toString)
		]
	}
	
	
	def allNodesAndSubTypes(Iterable<Node> nodes){
		nodes + nodes.allNodeSubTypes
	}
	
	def allNodesSuperTypesAndSubTypes(Node node){
		#[node] + #[node].allNodeSubTypes + node.allSuperNodes
	}
	
	
	def allOtherNodes(Iterable<Node> nodes){
		if(!nodes.nullOrEmpty){
			nodes.head.graphModel.nodes.drop[node| nodes.contains(node)]
			
		}
			
			
		else
			#[]
	}
	
	def Iterable<? extends Node> allNodeSubTypes(Iterable<Node> it){
		
		allOtherNodes.map[node|
			(node -> node.allSuperNodes)].
			filter[pair|
				pair.value.exists[v| it.contains(v)]
			].map[key]
	}
	
	

	def getInternalSuccessorsContent(Node node) '''
		return ((graphmodel.Node)this.getElement()).getSuccessors(«node.fqBeanName».class);
	'''
	
	def getSuccessorsContent(Node node) '''
		return ((graphmodel.Node)this).getSuccessors(«node.fqBeanName».class);
	'''
	

	def specializeGetPredecessors(Node node, GraphModel model, HashMap<String, ElementEClasses> map) {
		
		val internalNodeClass = map.get(node.name).internalEClass
		val nodeClass = map.get(node.name).mainEClass
		val lmNode = node.possiblePredecessors.lowestMutualSuperNode
		if (lmNode != null){
			val eTypeClass = map.get(lmNode.name).mainEClass
			nodeClass.createGenericListEOperation("getPredecessors", eTypeClass, lmNode.getPredecessorsContent.toString)
		}
		node.possiblePredecessors.toSet.forEach[ predecessorNode |
			val eTypeClass = map.get(predecessorNode.name).mainEClass
			val methodName = "get"+predecessorNode.name.toFirstUpper+"Predecessors"
			nodeClass.createEOperation(methodName, eTypeClass, 0, -1, predecessorNode.getPredecessorsContent.toString)
			internalNodeClass.createEOperation(methodName, eTypeClass, 0, -1, predecessorNode.internalePredecessorsContent.toString)
		]
		
	}

	def getPredecessorsContent(Node node) '''
		return ((graphmodel.Node)this).getPredecessors(«node.fqBeanName».class);
	'''

	def getInternalePredecessorsContent(Node node) '''
		return ((graphmodel.Node)this.getElement()).getPredecessors(«node.fqBeanName».class);
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
		 	ConnectionConstraint cons«pair.key» = new ConnectionConstraint(true,«node.outgoingEdgeConnections.get(pair.key).lowerBound»,«node.outgoingEdgeConnections.get(pair.key).upperBound»,«node.outgoingEdgeConnections.get(pair.key).connectingEdges.edgesList»);
		 «ENDFOR»
		 org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>eList = new org.eclipse.emf.common.util.BasicEList<ConnectionConstraint>();
		 		 eList.addAll(com.google.common.collect.Lists.newArrayList(«node.outgoingEdgeConnections.constraintVariables»));
		 		return eList;
	'''

	def createCanNewEdgeMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val edges = node.outgoingConnectingEdges.map[subTypes  as Iterable<Edge> + #[it]].flatten.filter[!isIsAbstract].toSet
		for (edge : edges) {
			val operationName = "canNew" + edge.fuName
			for (target : edge.allPossibleTargets) {
				val sourceEClass = elemClasses.get(node.name).mainEClass
				val targetEClass = elemClasses.get(target.name).mainEClass
				var content = edge.canNewEdgeMethodContent
				sourceEClass.createEOperation(operationName, EcorePackage.eINSTANCE.EBoolean, 0, 1, content,
					targetEClass.createEParameter("target", 1, 1))
			}
		}
	}

	def canNewEdgeMethodContent(Edge edge) '''
		return this.canStart(«edge.fuName».class) && target.canEnd(«edge.fuName».class);
	'''

	def createNewEdgeMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val edges = node.outgoingConnectingEdges.map[subTypes  as Iterable<Edge> + #[it]].flatten.filter[!isIsAbstract].toSet
		for (edge : edges) {
			val operationName = "new" + edge.fuName
			val edgeEClass = elemClasses.get(edge.name).mainEClass
			val sourceEClass = elemClasses.get(node.name).mainEClass
			for (target : edge.allPossibleTargets) {
				val targetEClass = elemClasses.get(target.name).mainEClass
				
				sourceEClass.createEOperation(operationName, edgeEClass, 0, 1,
					node.newIdEdgeMethodContent(edge),
					targetEClass.createEParameter("target", 1, 1),
					createEStringParameter("id",1,1))
					
				sourceEClass.createEOperation(operationName, edgeEClass, 0, 1,
					node.newEdgeMethodContent(edge),
					targetEClass.createEParameter("target", 1, 1))
			}
		}
	}

	def newIdEdgeMethodContent(Node node, Edge edge) '''
		if (target.canEnd(«edge.fuName».class)) {
			«edge.fqBeanName» edge = «node.fqFactoryName».eINSTANCE.create«edge.fuName»(id, («InternalNode.name») this.getInternalElement(), («InternalNode.name») target.getInternalElement());
			edge.setSourceElement(this);
			edge.setTargetElement(target);
			return edge;
		}
		else return null;
	'''
	
	def newEdgeMethodContent(Node node, Edge edge) '''
		if (target.canEnd(«edge.fuName».class)) {
			«edge.fqBeanName» edge = «node.fqFactoryName».eINSTANCE.create«edge.fuName»((«InternalNode.name») this.getInternalElement(), («InternalNode.name») target.getInternalElement());
			edge.setSourceElement(this);
			edge.setTargetElement(target);
			«InternalModelElementContainer.name» commonContainer = new «GraphModelExtension.name»().getCommonContainer(target.getContainer().getInternalContainerElement(), («InternalEdge.name») edge.getInternalElement());
			commonContainer.getModelElements().add(edge.getInternalElement());			
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
					createEIntParameter("x",1,1), 
					createEIntParameter("y",1,1)
			)
		]
	}

	def canMoveToMethodContent(Node node, ContainingElement ce) '''
		return «ce.name.toFirstLower.paramEscape».canContain(«node.fqBeanName».class);
	'''
	

	def createMoveToMethods(Node node, HashMap<String, ElementEClasses> elemClasses) {
		val containers = node.possibleContainers
		val nodeEClass = elemClasses.get(node.name).mainEClass
		containers.forEach[
			c |	nodeEClass.createEOperation("moveTo",null,1,1,node.moveToMethodContent(c), 
					elemClasses.get(c.name).mainEClass.createEParameter(c.name.toFirstLower,1,1), createEIntParameter("x",1,1), createEIntParameter("y",1,1)
				)
				
				nodeEClass.createEOperation("s_moveTo",null,1,1,node._moveToMethodContent(c), 
					elemClasses.get(c.name).mainEClass.createEParameter(c.name.toFirstLower,1,1), createEIntParameter("x",1,1), createEIntParameter("y",1,1)
				)
		]
		
		nodeEClass.createEOperation("s_moveTo",null,1,1,"", 
			GraphmodelPackage.Literals.MODEL_ELEMENT_CONTAINER.createEParameter("container",1,1), createEIntParameter("x",1,1), createEIntParameter("y",1,1)
		)
		
		nodeEClass.createEOperation("postMove", null,1,1,node.postMoveContent,
			GraphmodelPackage.eINSTANCE.modelElementContainer.createEParameter("source",1,1),
			GraphmodelPackage.eINSTANCE.modelElementContainer.createEParameter("target",1,1),
			createEIntParameter("x",1,1),
			createEIntParameter("y",1,1),
			createEIntParameter("deltaX",1,1), 
			createEIntParameter("deltaY",1,1)
		)
	}

	def moveToMethodContent(Node node, ContainingElement ce) '''
		transact("Set width", () -> {
			«ModelElementContainer.name» source = this.getContainer();
			int deltaX = x - ((«InternalNode.name») this.getInternalElement()).getX();
			int deltaY = y - ((«InternalNode.name») this.getInternalElement()).getY();
			s_moveTo(«ce.name.toFirstLower.paramEscape», x, y);
			«ce.name.toFirstLower.paramEscape».getInternalContainerElement().getModelElements().add(this.getInternalElement());
			setX(x);
			setY(y);
			new «GraphModelExtension.name»().moveEdgesToCommonContainer((«InternalNode.name») this.getInternalElement());
			«IF node.booleanWriteMethodCallPostMove»
				postMove(source, «ce.name.toFirstLower», x,y, deltaX, deltaY);
			«ENDIF»
		});
	'''

	/**
	 * This method is only generated to allow for the implementation of the api. Thus, to add additional behavior for move
	 * the method "s_moveTo(...)" should be overridden.
	 * 
	 * ATTENTION: Overriding the "moveTo(...)" overrides the post move hook call! 
	 */
	def _moveToMethodContent(Node node, ContainingElement ce) '''

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
		ce.containableNodes.filter[!isIsAbstract && !isPrime].forEach[n | 
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newNodeSimpleMethodContent(n),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newNodeMethodContent(n),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1),
						createEIntParameter("width",1,1),
						createEIntParameter("height",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdNodeSimpleMethodContent(n),
						createEStringParameter("id",1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdNodeMethodContent(n),
						createEStringParameter("id",1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1),
						createEIntParameter("width",1,1),
						createEIntParameter("height",1,1)
					)
			]
			
		ce.containableNodes.filter[!isIsAbstract && isPrime].forEach[n | 
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newPrimeNodeSimpleMethodContent(n),
						createEObjectParameter(n.primeName, 1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newPrimeNodeMethodContent(n),
						createEObjectParameter(n.primeName, 1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1),
						createEIntParameter("width",1,1),
						createEIntParameter("height",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdPrimeNodeSimpleMethodContent(n),
						createEObjectParameter(n.primeName, 1,1),
						createEStringParameter("id", 1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdPrimeNodeMethodContent(n),
						createEObjectParameter(n.primeName, 1,1),
						createEStringParameter("id", 1,1),
						createEIntParameter("x",1,1),
						createEIntParameter("y",1,1),
						createEIntParameter("width",1,1),
						createEIntParameter("height",1,1)
					)
				]
	} 

	def newIdNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»(id, (graphmodel.internal.InternalModelElementContainer)this.getInternalElement());
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			node.move(x, y);
			node.resize(width, height);
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''
	
	def newIdNodeSimpleMethodContent(ContainingElement ce, Node n) '''
		return new«n.fuName»(id,x,y,-1,-1);
	'''

	def newNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»((graphmodel.internal.InternalModelElementContainer) this.getInternalElement());
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

	def newIdPrimeNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»(id);
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			((«n.fqInternalBeanName») node.getInternalElement())
				.setLibraryComponentUID(org.eclipse.emf.ecore.util.EcoreUtil.getID(«n.primeName»));
			node.move(x, y);
			node.resize(width, height);
			«IF n.hasPostCreateHook»
				«n.fqFactoryName».eINSTANCE.postCreates(node);
			«ENDIF»
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''

	def newIdPrimeNodeSimpleMethodContent(ContainingElement ce, Node n) '''
		return new«n.fuName»(«n.primeName»,id,x,y,-1,-1);
	'''

	def newPrimeNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»();
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			((«n.fqInternalBeanName») node.getInternalElement())
				.setLibraryComponentUID(org.eclipse.emf.ecore.util.EcoreUtil.getID(«n.primeName»));
			node.move(x, y);
			node.resize(width, height);
			«IF n.hasPostCreateHook»
				«n.fqFactoryName».eINSTANCE.postCreates(node);
			«ENDIF»
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''

	def newPrimeNodeSimpleMethodContent(ContainingElement ce, Node n) '''
		return new«n.fuName»(«n.primeName»,x,y,-1,-1);
	'''

	def createModelElementGetter(ContainingElement ce, HashMap<String, ElementEClasses> elmClasses) {
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

	def createNewGraphModel(GraphModel gm, HashMap<String, ElementEClasses> elmClasses){
		var eClass = elmClasses.get(gm.name).mainEClass
		var opName = "new"+gm.fuName
		var pathParam = createEStringParameter("path", 1,1)
		var fileParam = createEStringParameter("fileName", 1,1)
		var hookParam = createEBooleanParameter("postCreateHook",1,1)
		var content = gm.createNewGraphModelContent
		eClass.createEOperation(opName, eClass, 1,1, content, pathParam, fileParam, hookParam)
	}

	def createNewGraphModelContent(GraphModel gm) '''
		«IPath.name» filePath = new «Path.name»(path).append(fileName).addFileExtension("«gm.name.toLowerCase»");
		«URI.name» uri = «URI.name».createPlatformResourceURI(filePath.toOSString(), true);
		«IFile.name» file = «ResourcesPlugin.name».getWorkspace().getRoot().getFile(filePath);
		«Resource.name» res = new «ResourceSetImpl.name»().createResource(uri);
		«gm.fqBeanName» graph = «gm.fqFactoryName».eINSTANCE.create«gm.fuName»();
		
		«EcoreUtil.name».setID(graph, «EcoreUtil.name».generateUUID());

		res.getContents().add(graph.getInternalElement());
		
		«IF gm.hasPostCreateHook»
		if (postCreateHook)
			«gm.fqFactoryName».eINSTANCE.postCreates((«gm.fqBeanName») graph);
		«ENDIF»
		try {
			res.save(null);
		} catch («IOException.name» e) {
			e.printStackTrace();
		}

		return graph;
	'''

	def createRootElementGetter(ModelElement me, HashMap<String, ElementEClasses> elmClasses) {
		var modelElementClass = elmClasses.get(me.name).mainEClass
		var graphModelClass = elmClasses.get(me.graphModel.name).mainEClass
		
		modelElementClass.createEOperation("getRootElement", graphModelClass,0,1, me.rootElementGetterContent(me.graphModel))
	}
	
	def rootElementGetterContent(ModelElement me, GraphModel gm) '''
	«IF me instanceof GraphModel»
	return this;
	«ELSE»
	return («gm.fqBeanName») this.getInternalElement().getRootElement().getElement();
	«ENDIF» 
	'''

	def createGraphicalInformationGetter(Node n, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(n.name).mainEClass.createEOperation(
			"getX",
			EcorePackage.eINSTANCE.EInt,
			1,
			1,
			getterContent("X")
		)
		
		elemClasses.get(n.name).mainEClass.createEOperation(
			"getY",
			EcorePackage.eINSTANCE.EInt,
			1,
			1,
			getterContent("Y")
		)
		
		elemClasses.get(n.name).mainEClass.createEOperation(
			"getWidth",
			EcorePackage.eINSTANCE.EInt,
			1,
			1,
			getterContent("Width")
		)
		
		elemClasses.get(n.name).mainEClass.createEOperation(
			"getHeight",
			EcorePackage.eINSTANCE.EInt,
			1,
			1,
			getterContent("Height")
		)
	}

	def createPostSave(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"postSave",
			null,
			1,1,
			me.postSaveContent
		)
	}

	def createPreDeleteMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"preDelete",
			null,
			1,1,
			me.preDeleteContent
		)
	}

	def createPostDeleteMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"getPostDeleteFunction",
			GraphmodelPackage.eINSTANCE.runnable,
			1,1,
			me.getPostDeleteFunctionContent
		)
	}

	def postSaveContent(ModelElement me) {
		val annot = me.getAnnotation("postSave")
		if (annot != null) '''
		new «annot.value.get(0)»().postSave(this.getRootElement());
		'''
		else ""
	}

	def preDeleteContent(ModelElement me) {
		val annot = me.getAnnotation("preDelete")
		if (annot != null) '''
		new «annot.value.get(0)»().preDelete(this);
		'''
		else ""
	}
	
	def getPostDeleteFunctionContent(ModelElement me) {
		val annot = me.getAnnotation("postDelete")
		if (annot !== null) '''
			de.jabc.cinco.meta.runtime.hook.CincoPostDeleteHook<? super «me.fqBeanName»> postDeleteHook = new «annot.value.get(0)»();
			return postDeleteHook.getPostDeleteFunction(this);
		'''
		else "return () -> {};"
		
	}

	def createResizeMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"resize",
			null,
			1,1,
			me.resizeContent,
			createEIntParameter("width",1,1),
			createEIntParameter("height",1,1)
		)
	}

	def createPostResizeMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"postResize",
			null,
			1,1,
			me.postResizeContent,
			createEParameter(elemClasses.get(me.name).mainEClass,"modelElement",1,1),
			createEIntParameter("direction",1,1),
			createEIntParameter("width",1,1),
			createEIntParameter("height",1,1)
		)
	}
	
	def resizeContent(ModelElement me) '''
		transact("Set width", () -> {
			((graphmodel.internal.InternalNode)getInternalElement()).setWidth(width);
			((graphmodel.internal.InternalNode)getInternalElement()).setHeight(height);
			this.postResize(this, 0, width, height);
			this.update();
		});
	'''
	
	def postResizeContent(ModelElement me) {
		val annot = me.getAnnotation("postResize")
		if (annot != null) '''
		new «annot.value.get(0)»().postResize(this, direction, width, height);
		'''
		else ""
	}

	def getterContent(String variableName) '''
		return ((«InternalNode.name») getInternalElement()).get«variableName»(); 
	'''

	def modelElementGetterContent(ModelElement me) '''
		return getModelElements(«me.fqBeanName».class);
	'''

//	def createLibraryUIDMethods(Node n, HashMap<String, ElementEClasses> elemClasses) {
//		var nodeClass = elemClasses.get(n.name).mainEClass
//		var internalClass = elemClasses.get(n.name).internalEClass 
//		var type = EcorePackage.eINSTANCE.EString
//		nodeClass.createEOperation("getLibraryComponentUID", type, 0,1, n.libraryUIDGetterContent)
//		nodeClass.createEOperation("setLibraryComponentUID", null, 0,1, n.libraryUIDSetterContent, createEString("id",0,1))
//		internalClass.createEOperation("getLibraryComponentUID", type, 0,1, n.internalLibraryUIDGetterContent)
//		internalClass.createEOperation("setLibraryComponentUID", null, 0,1, n.internalLibraryUIDSetterContent, createEString("id",0,1))
//	}
//
//	def libraryUIDGetterContent(Node n)'''
//	return ((«n.fqInternalBeanName») this.getInternalElement()).getLibraryComponentUID();
//	'''
//	
//	def libraryUIDSetterContent(Node n)'''
//	((«n.fqInternalBeanName») this.getInternalElement()).setLibraryComponentUID(id);
//	'''
//	
//	def internalLibraryUIDGetterContent(Node n)'''
//	return ((«n.fqInternalBeanName») this.getLibraryComponentUID();
//	'''
//	
//	def internalLibraryUIDSetterContent(Node n)'''
//	((«n.fqInternalBeanName») this.setLibraryComponentUID(id);
//	'''

//	def createPrimeAttributeMethods(Node n, HashMap<String, ElementEClasses> elemClasses) {
//		var nodeClass = elemClasses.get(n.name).mainEClass
//		var internalNodeClass = elemClasses.get(n.name).internalEClass
//		
//		var primeTypeEClass = n.primeTypeEClass
//		var primeAttributeName = n.primeName.toFirstUpper
//		
//		nodeClass.createEOperation("get"+primeAttributeName, primeTypeEClass, 0,1, primeAttributeGetterContent)
//		internalNodeClass.createEOperation("get"+primeAttributeName, primeTypeEClass, 0,1, primeAttributeGetterContent)
//	}

//	def primeAttributeGetterContent() '''
//	String uid = this.getLibraryComponentUID();
//	return  «ReferenceRegistry.name».getInstance().getEObject(uid);
//	'''

	def generateTypedOutgoingEdgeMethod(ElementEClasses it, Edge edge){
		
		mainEClass.createEOperation('''getOutgoing«edge.name»s''',null,0,-1,edge.outgoingContent)
	}
	
	def outgoingContent(Edge edge)'''
		return this.getOutgoing(«edge.name».class);
	'''
	def generateTypedIncomingEdgeMethod(ElementEClasses it, Edge edge){
		
		mainEClass.createEOperation('''getIncoming«edge.name»s''',null,0,-1,edge.incomingContent)
	}
	
	def incomingContent(Edge edge)'''
		return this.getIncoming(«edge.name».class);
	'''
	def String edgesList(Iterable<Edge> edges) {
		edges.map[edge|new GeneratorUtils().fqBeanName(edge) + ".class"].join(",")
	}

	def constraintVariables(Iterable<? extends EdgeElementConnection> connections) {
		val vars = new ArrayList<String>
		connections.forEach[c, i|vars += "cons" + i]
		vars.join(",")
	}

	def possibleSuccessors(Node it) {
			var posSuc = possibleSuccessorsMap.get(it)
		if(posSuc === null ){
			posSuc = (allNodesSuperTypesAndSubTypes).map[node| node.outgoingEdgeConnections.filter[upperBound>0 || upperBound==-1].map [
			connectingEdges.toSet.allEdgesSuperTypesAndSubTypes.map [ edge |
				edge.edgeElementConnections.filter(IncomingEdgeElementConnection).map[connectedElement]
			]]
		].flatten.flatten.flatten.map[it as Node]
		possibleSuccessorsMap.put(it,posSuc)	
		}
		
		return posSuc
		
		
	}
	def Set<Edge> allEdgesSuperTypesAndSubTypes(Set<Edge> edges){
		(edges +edges.allEdgeSuperTypes + edges.allEdgeSubTypes).toSet
	}
	def allEdgeSuperTypes(Iterable<Edge> edges){
		edges.map[allSuperTypes.map[i| i as Edge]].flatten.toSet		
	}		
	
	def allOtherEdges(Iterable<Edge> edges){
		if(!edges.nullOrEmpty)
			edges.head.graphModel.edges.drop[edge| edges.contains(edge)]
		else
			#[]
	}
	
	def Iterable<? extends Edge> allEdgeSubTypes(Iterable<Edge> it){
		allOtherEdges.map[edge|edge.allSuperTypes.map[i| i as Edge]].filter[edges|edges.exists[edge| it.contains(edge)]].flatten
	}
	def possiblePredecessors(Node it) {
		var posPre=	possiblePredecessorsMap.get(it)
		
		if(posPre===null){
			posPre = (allNodesSuperTypesAndSubTypes).map[node| node.incomingEdgeConnections.filter[upperBound>0 || upperBound==-1].map [
			connectingEdges.toSet.allEdgesSuperTypesAndSubTypes.toSet.map [ edge |
				edge.edgeElementConnections.filter(OutgoingEdgeElementConnection).map[connectedElement]
			]]
		].flatten.flatten.flatten.map[it as Node]
		possiblePredecessorsMap.put(it,posPre)
		}
		posPre
		
	}
	/**
	 * Collects all containment constraints of a given ContainingElement including all inherited
	 * containment constraints.
	 * Will Fail if ContainignElement is not instance of NodeContainer or GraphModel.
	 * @param ce - ContainingElement (May be GraphModel or NodeContainer)
	 * @return Iterable containing references to containment reference defined in ce and inherited from other
	 * ContainingElements
	 * */
	def getAllContainmentConstraints(ContainingElement ce){
		ce.containableElements+ce.allSuperTypes.filter(ContainingElement).map[containableElements].flatten
	}

	/**
	 * Returns List of all super types of a ContainingElement
	 * List contains of GraphModel if ce is instance of GraphModel
	 * or NodeContainer if ce is instance of NodeContainer.
	 * Fails otherwise.
	 * May return empty list.
	 * @param ce - ContainingElement (May be GraphModel or NodeContainer)
	 * @return ArrayList containing super types of ce
	 */
	def allSuperTypes(ContainingElement ce){
		val superTypes = new ArrayList<ModelElement>
		var sType = ce.extend

		while(sType!=null){
			superTypes.add(sType)
			sType = sType.extend
		}
		superTypes
	}

	/**
	 * Returns Inherited Type of a ContainingElement. This  may be a GraphModel if ce is a GraphModel
	 * or NodeContainer if ce is instance of NodeContainer
	 * Fails otherwise.
	 * May return @null.
	 * @param ce: ContainingElement
	 * @returns ContainingElement
	 */
	def extend(ContainingElement ce){
		switch(ce){
			case ce instanceof GraphModel: return ((ce as GraphModel).extends)
			case ce instanceof NodeContainer: return ((ce as NodeContainer).extends)
			default : throw new IllegalArgumentException(String.format("Can not match Type: %s", ce))
		}

	}

}
