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

class NodeMethodsGeneratorExtensions extends GeneratorUtils {

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
		//FIXME: For the simple case this method does not create successor methods.
//		val lmNode = node.possibleSuccessors.lowestMutualSuperNode
//		val eTypeClass = if (lmNode == null)
//				return
//			else
//				map.get(lmNode.name).mainEClass
//
//		nodeClass.createEOperation("getSuccessors", eTypeClass, 0, -1, eTypeClass.getSuccessorsContent.toString)
		
		// FIXME: Adding the missing successor methods (see above)
		node.possibleSuccessors.toSet.forEach[
			val eTypeClass = map.get(it.name).mainEClass
			val methodName = "get"+it.name.toFirstUpper+"Successors"
			internalNodeClass.createEOperation(methodName, eTypeClass, 0, -1, eTypeClass.getInternalSuccessorsContent.toString)
			nodeClass.createEOperation(methodName, eTypeClass, 0, -1, eTypeClass.getSuccessorsContent.toString)
		]
	}

	def getInternalSuccessorsContent(EClass eTypeClass) '''
		return ((graphmodel.Node)this.getElement()).getSuccessors(«eTypeClass.name».class);
	'''
	
	def getSuccessorsContent(EClass eTypeClass) '''
		return ((graphmodel.Node)this).getSuccessors(«eTypeClass.name».class);
	'''

	def specializeGetPredecessors(Node node, GraphModel model, HashMap<String, ElementEClasses> map) {
		
		val internalNodeClass = map.get(node.name).internalEClass
		val nodeClass = map.get(node.name).mainEClass
		// FIXME: Adding the missing predecessors methods (see above)
		node.possiblePredecessors.toSet.forEach[
			val eTypeClass = map.get(it.name).mainEClass
			val methodName = "get"+it.name.toFirstUpper+"Predecessors"
			nodeClass.createEOperation(methodName, eTypeClass, 0, -1, eTypeClass.getPredecessorContent.toString)
			internalNodeClass.createEOperation(methodName, eTypeClass, 0, -1, eTypeClass.internalePredecessorContent.toString)
		]
	}

	def getPredecessorContent(EClass eTypeClass) '''
		return ((graphmodel.Node)this).getPredecessors(«eTypeClass.name».class);
	'''

	def getInternalePredecessorContent(EClass eTypeClass) '''
		return ((graphmodel.Node)this.getElement()).getPredecessors(«eTypeClass.name».class);
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
		val edges = node.outgoingConnectingEdges.filter[!isIsAbstract]
		for (edge : edges) {
			val operationName = "canNew" + edge.fuName
			for (target : edge.possibleTargets) {
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
		val edges = node.outgoingConnectingEdges.filter[!isIsAbstract]
		for (edge : edges) {
			val operationName = "new" + edge.fuName
			val edgeEClass = elemClasses.get(edge.name).mainEClass
			val sourceEClass = elemClasses.get(node.name).mainEClass
			for (target : edge.possibleTargets) {
				val targetEClass = elemClasses.get(target.name).mainEClass
				val content = node.newEdgeMethodContent(edge)
				sourceEClass.createEOperation(operationName, edgeEClass, 0, 1, content,
					targetEClass.createEParameter("target", 1, 1))
			}
		}
	}

	def newIdEdgeMethodContent(Node node, Edge edge) '''
		if (target.canEnd(«edge.fuName».class)) {
			«edge.fqBeanName» edge = «node.fqFactoryName».eINSTANCE.create«edge.fuName»(id);
			edge.setSourceElement(this);
			edge.setTargetElement(target);
			return edge;
		}
		else return null;
	'''
	
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
		return «ce.name.toFirstLower.paramEscape».canContain(«node.fqBeanName».class);
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
		_moveTo(«ce.name.toFirstLower.paramEscape», x, y);
		«IF node.booleanWriteMethodCallPostMove»
		postMove(source, «ce.name.toFirstLower», x,y, deltaX, deltaY);
		«ENDIF»
	'''

	def _moveToMethodContent(Node node, ContainingElement ce) '''
		«ce.name.toFirstLower.paramEscape».getInternalContainerElement().getModelElements().add(this.getInternalElement());
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
		ce.containableNodes.filter[!isIsAbstract && !isPrime].forEach[n | 
					
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
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdNodeMethodContent(n),
						createEString("id",1,1),
						createEInt("x",1,1),
						createEInt("y",1,1),
						createEInt("width",1,1),
						createEInt("height",1,1)
					)
			]
			
		ce.containableNodes.filter[!isIsAbstract && isPrime].forEach[n | 
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newPrimeNodeSimpleMethodContent(n),
						createEObject(n.primeName, 1,1),
						createEInt("x",1,1),
						createEInt("y",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newPrimeNodeMethodContent(n),
						createEObject(n.primeName, 1,1),
						createEInt("x",1,1),
						createEInt("y",1,1),
						createEInt("width",1,1),
						createEInt("height",1,1)
					)
					
				elemClasses.get(ce.name).mainEClass.
					createEOperation("new"+n.fuName,
						elemClasses.get(n.name).mainEClass,
						1,
						1,
						ce.newIdPrimeNodeMethodContent(n),
						createEObject(n.primeName, 1,1),
						createEString("id", 1,1),
						createEInt("x",1,1),
						createEInt("y",1,1),
						createEInt("width",1,1),
						createEInt("height",1,1)
					)
				]
	} 

	def newIdNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»(id, (InternalModelElementContainer)this.getInternalElement());
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			node.move(x, y);
			node.resize(width, height);
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''

	def newNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»((InternalModelElementContainer) this.getInternalElement());
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
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»(id, (InternalModelElementContainer) this.getInternalElement());
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			node.move(x, y);
			node.resize(width, height);
			return node;
		} else throw new «RuntimeException.name»(
			«String.name».format("Cannot add node %s to %s", «n.fuName».class, this.getClass()));
	'''

	def newPrimeNodeMethodContent(ContainingElement ce, Node n) '''
		if (this.canContain(«n.fuName».class)) {
			«n.fqBeanName» node = «n.fqFactoryName».eINSTANCE.create«n.fuName»();
			this.getInternalContainerElement().getModelElements().add(node.getInternalElement());
			node.move(x, y);
			node.resize(width, height);
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
		var pathParam = createEString("path", 1,1)
		var fileParam = createEString("fileName", 1,1)
		var hookParam = createEBoolean("postCreateHook",1,1)
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

	def createPreDeleteMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"preDelete",
			null,
			1,1,
			me.preDeleteContent
		)
	}

	def preDeleteContent(ModelElement me) {
		val annot = me.getAnnotation("preDelete")
		if (annot != null) '''
		new «annot.value.get(0)»().preDelete(this);
		'''
		else ""
	}

	def createPostResizeMethods(ModelElement me, HashMap<String, ElementEClasses> elemClasses) {
		elemClasses.get(me.name).mainEClass.createEOperation(
			"postResize",
			null,
			1,1,
			me.postResizeContent,
			createEParameter(elemClasses.get(me.name).mainEClass,"modelElement",1,1),
			createEInt("direction",1,1),
			createEInt("width",1,1),
			createEInt("height",1,1)
		)
	}
	
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

	/**
	 * Collects all containment constraints of a given ContainingElement including all inherited
	 * containment constraints.
	 * Will Fail if ContainignElement is not instance of NodeContainer or GraphModel.
	 * @param ce - ContainingElement (May be GraphModel or NodeContainer)
	 * @return Iterable containing references to containment reference defined in ce and inherited from other
	 * ContainingElements
	 * */
	def getAllContainmentConstraints(ContainingElement ce){
		ce.containableElements+ce.allSuperTypes.map[containableElements].flatten
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
		val superTypes = new ArrayList<ContainingElement>
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
	def ContainingElement extend(ContainingElement ce){
		switch(ce){
			case ce instanceof GraphModel: return ((ce as GraphModel).extends) as ContainingElement
			case ce instanceof NodeContainer: return ((ce as NodeContainer).extends) as ContainingElement
			default : throw new IllegalArgumentException(String.format("Can not match Type: %s", ce))
		}

	}

}
