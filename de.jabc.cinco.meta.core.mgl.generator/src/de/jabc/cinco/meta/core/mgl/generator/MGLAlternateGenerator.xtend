package de.jabc.cinco.meta.core.mgl.generator

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.mgl.generator.extensions.AdapterGeneratorExtension
import de.jabc.cinco.meta.core.mgl.generator.extensions.NodeMethodsGeneratorExtensions
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry
import graphmodel.GraphmodelPackage
import graphmodel.internal.InternalPackage
import java.util.ArrayList
import java.util.HashMap
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.ContainingElement
import mgl.EDataTypeType
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.PrimitiveAttribute
import mgl.ReferencedModelElement
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EGenericType
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EParameter
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EdgeMethodsGeneratorExtension.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.FactoryGeneratorExtensions.*
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*
import java.util.HashSet
import java.util.Set

class MGLAlternateGenerator extends NodeMethodsGeneratorExtensions{

	extension AdapterGeneratorExtension = new AdapterGeneratorExtension

	HashMap<ModelElement, EClass> modelElementsMap

	HashMap<ModelElement, ModelElement> inheritMap

	HashMap<EReference, Type> toReferenceMap
	val GraphmodelPackage graphModelPackage = GraphmodelPackage.eINSTANCE
	val internalPackage = InternalPackage.eINSTANCE

	HashMap<String, ElementEClasses> eClassesMap

	HashMap<EOperation, Type> complexGetterParameterMap
	HashMap<EGenericType, Type> complexGenericGetterParameterMap
	HashMap<EParameter, Type> complexSetterParameterMap
	HashMap<EOperation, Type> enumGetterParameterMap
	HashMap<EParameter, Type> enumSetterParameterMap
	HashMap<Type,EClassifier> enumMap
	
	HashMap<EOperation, Edge> operationEdgeMap
	HashMap<EOperation, Node>  operationReferencedTypeMap
	
	
	
	def createFactory(GraphModel graphModel){
		graphModel.createFactory(eClassesMap.filter[p1, p2|!p2.mainEClass.abstract])
	}
	
	def createAdapter(ModelElement me) {
		me.generateAdapter
	}
	
	def createAdapter(UserDefinedType t) {
		t.generateAdapter
	}

	def Iterable<EPackage> generateEcoreModel(GraphModel graphModel, Iterable<EPackage> mglEPackages) {
		initializeMaps
		val elementEClasses = new HashMap<ModelElement,ElementEClasses>

		val epk = createEPackage(graphModel)
		val newEPackages = new ArrayList<EPackage>
		newEPackages += epk
		newEPackages+=mglEPackages
		val internalEPackage = createInternalEPackage(graphModel)
		val viewsEPackage = createViewsEPackage(graphModel)
		epk.ESubpackages += internalEPackage
		epk.ESubpackages += viewsEPackage
		epk.EClassifiers += graphModel.createEnums
		elementEClasses.putAll(graphModel.createGraphModel)
		elementEClasses.putAll(graphModel.createNodes)
		elementEClasses.putAll(graphModel.createEdges)
		elementEClasses.putAll(graphModel.createUserDefinedTypes)

		epk.EClassifiers += elementEClasses.values.map[ec|ec.mainEClass]
		internalEPackage.EClassifiers += elementEClasses.values.filter[internalEClass!== null].map[internalEClass]
		viewsEPackage.EClassifiers += elementEClasses.values.filter[mainView!== null].map[mainView]
		viewsEPackage.EClassifiers += elementEClasses.values.filter[!views.nullOrEmpty].map[views].flatten

		toReferenceMap.forEach[key, value|key.EType = eClassesMap.get(value.name).mainEClass]
		complexGetterParameterMap.forEach[key,value| /*println(value);*/key.EType = elementEClasses.get(value).mainEClass]
		complexGenericGetterParameterMap.forEach[key,value| /*println(value);*/key.EClassifier = elementEClasses.get(value).mainEClass]
		complexSetterParameterMap.forEach[key,value| key.EType = elementEClasses.get(value).mainEClass]
		enumSetterParameterMap.forEach[key,value|key.EType = enumMap.get(value)]
		enumGetterParameterMap.forEach[key,value|key.EType = enumMap.get(value)]
		operationReferencedTypeMap.forEach[operation, node| operation.setPrimeType(node, newEPackages)]
		operationEdgeMap.forEach[operation,edge| operation.EType = eClassesMap.get(edge.name).mainEClass]

		graphModel.createCanNewNodeMethods(eClassesMap)
		graphModel.createNewNodeMethods(eClassesMap.filter[p1,p2| !p2.mainEClass.abstract])
		graphModel.createGetContainmentConstraintsMethod(eClassesMap)
		graphModel.createModelElementGetter(eClassesMap)
		graphModel.createNewGraphModel(eClassesMap)
		
		graphModel.nodes.forEach[node|
			node.createInheritance(graphModel)
			node.createConnectionMethods(graphModel,eClassesMap)
			node.createCanNewEdgeMethods(eClassesMap)
			node.createNewEdgeMethods(eClassesMap)
			node.createCanMoveToMethods(eClassesMap)
			node.createMoveToMethods(eClassesMap)
			node.createGraphicalInformationGetter(eClassesMap)
			node.createPreDeleteMethods(eClassesMap)
			node.createPostDeleteMethods(eClassesMap)
			node.createResizeMethods(eClassesMap)
			node.createPostResizeMethods(eClassesMap)
		]
		
		graphModel.nodes.filter(NodeContainer).forEach[container|
			(container as NodeContainer).createGetContainmentConstraintsMethod(eClassesMap)
			(container as NodeContainer).createModelElementGetter(eClassesMap)
			container.createCanNewNodeMethods(eClassesMap)
			container.createNewNodeMethods(eClassesMap)
		]
		graphModel.edges.forEach[edge|
			edge.createInheritance(graphModel)
			edge.createCanReconnectMethods(eClassesMap)
			edge.createReconnectMethods(eClassesMap)
			edge.createPreDeleteMethods(eClassesMap)
			edge.createPostDeleteMethods(eClassesMap)
		]
		graphModel.modelElements.forEach[
			createRootElementGetter(eClassesMap)
		]
		graphModel.types.filter(UserDefinedType).forEach[udt|udt.createInheritance(graphModel)]
		graphModel.modelElements.forEach[
			it.createPostSave(eClassesMap)
		]
		return newEPackages
	}
	
	/**
     * Returns EClasses of generated model elements.
     */
	def getModelElementsClasses() {
		modelElementsMap.values
	}

	private def initializeMaps() {
		eClassesMap = new HashMap
		modelElementsMap = new HashMap
		inheritMap = new HashMap
		toReferenceMap = new HashMap
		complexSetterParameterMap = new HashMap
		complexGetterParameterMap = new HashMap
		complexGenericGetterParameterMap = new HashMap
		enumMap = new HashMap
		operationReferencedTypeMap = new HashMap
		enumSetterParameterMap = new HashMap
		enumGetterParameterMap = new HashMap
		operationEdgeMap = new HashMap
	}

//	FIXME: Workaround for Issue #20589. Returning EObject type if Package not found 
	private def void setPrimeType(EOperation operation, Node node, Iterable<EPackage> ePackages){
		val prime = node.retrievePrimeReference as ReferencedModelElement
		var pkg = ePackages.findFirst[nsURI==prime.type.graphModel.nsURI]
		val etype = 
			if (pkg !== null) pkg.getEClassifier(prime.type.name) as EClass
			else EcorePackage.eINSTANCE.EObject 
		operation.EType = etype

	}

	private def createViewsEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = "views"
		epk.nsPrefix = model.name.toLowerCase + "-views"
		epk.nsURI = model.nsURI + "/views"
		epk
	}

	private def createInternalEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = "internal"
		epk.nsPrefix = model.name.toLowerCase + "-internal"
		epk.nsURI = model.nsURI + "/internal"
		epk
	}

	private def createEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = model.name.toLowerCase
		epk.nsPrefix = model.name.toLowerCase
		epk.nsURI = model.nsURI
		epk
	}

	private def HashMap<ModelElement,ElementEClasses> createGraphModel(GraphModel model) {
		val gmClasses = model.createModelElementClasses
		if(gmClasses.modelElement.extends === null)
			gmClasses.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("GraphModel") as EClass
			
		gmClasses.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalGraphModel") as EClass		
		gmClasses.generateTypedModelElementGetter
		val map = new HashMap
		map.put(model,gmClasses)
		map

	}

	private def HashMap<ModelElement,? extends ElementEClasses> createNodes(GraphModel model) {
		val nodeClasses = new HashMap<ModelElement,ElementEClasses>
		var sorted = model.nodes.topSort
		
		sorted.forEach[node|nodeClasses.put(node,node.createModelElementClasses)]
		nodeClasses.forEach[node,nodeClass|
			nodeClass.generateConnectionMethods(node as Node);
			nodeClass.createSpecializedGetContainer
		]
		nodeClasses.values.filter[n| !(n.modelElement instanceof ContainingElement)].forEach[nc|
			
			if(nc.modelElement.extends === null)
				nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Node") as EClass);
				
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalNode") as EClass);
		]
		nodeClasses.values.filter[n| (n.modelElement instanceof ContainingElement)].forEach[nc|
			if(nc.modelElement.extends === null || !(nc.modelElement.extends instanceof ContainingElement))
				nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Container") as EClass);
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalContainer") as EClass);
			nc.generateTypedModelElementGetter
			
		]
		
		nodeClasses.values
		.filter[(modelElement as Node).prime]
		.forEach[createPrimeReference]
		
		nodeClasses
	}
	
	private def generateConnectionMethods(ElementEClasses classes, Node it) {
		val outgoingEdges = allNodesSuperTypesAndSubTypes.map[outgoingEdgeConnections.drop[upperBound == 0]].flatten.map[co|co.connectingEdges].flatten.
			drop[edge|outgoingEdgeConnections.exists[connectingEdges.contains(edge) && upperBound == 0]].toSet.allEdgesSuperTypesAndSubTypes
		outgoingEdges.specializeGetOutgoingMethod(classes,it)
		outgoingEdges.forEach[edge|val op = classes.generateTypedOutgoingEdgeMethod(edge);operationEdgeMap.put(op,edge)]
		val incomingEdges = allNodesSuperTypesAndSubTypes.map[incomingEdgeConnections.drop[upperBound==0]].flatten.map[co| co.connectingEdges].flatten.
		drop[edge|incomingEdgeConnections.exists[connectingEdges.contains(edge) && upperBound == 0 ]].toSet.allEdgesSuperTypesAndSubTypes
		incomingEdges.forEach[edge|val op = classes.generateTypedIncomingEdgeMethod(edge);operationEdgeMap.put(op,edge)]
		incomingEdges.specializeGetIncomingMethod(classes,it)
	}
	
	def void specializeGetOutgoingMethod(Set<Edge> edges,ElementEClasses classes, Node it){
		val returnType = edges.lowestMutualSuperEdge
		if(returnType !== null){
			val eOp = classes.mainEClass.createEOperation("getOutgoing", null, 0, -1, outgoingGetterContent(returnType))
			complexGetterParameterMap.put(eOp,returnType)	
		}
		
		
	}
	
	def outgoingGetterContent(Node node,Edge edge)'''
		EList<graphmodel.internal.InternalEdge> out = ((graphmodel.internal.Internal«IF node instanceof NodeContainer»Container«ELSE»Node«ENDIF»)getInternalElement()).getOutgoing();
		return org.eclipse.emf.common.util.ECollections.unmodifiableEList(out
			.stream().map(me -> («edge.fqBeanName»)me.getElement()).
				collect(java.util.stream.Collectors.toList()));
		'''
		
	def void specializeGetIncomingMethod(Set<Edge> edges,ElementEClasses classes, Node it){
		val returnType = edges.lowestMutualSuperEdge
		if(returnType !== null){
			val eOp = classes.mainEClass.createEOperation("getIncoming", null, 0, -1, incomingGetterContent(returnType))
			complexGetterParameterMap.put(eOp,returnType)
		
		}
		
	}
	
	def incomingGetterContent(Node node,Edge edge)'''
		EList<graphmodel.internal.InternalEdge> in = ((graphmodel.internal.Internal«IF node instanceof NodeContainer»Container«ELSE»Node«ENDIF»)getInternalElement()).getIncoming();
		return org.eclipse.emf.common.util.ECollections.unmodifiableEList(in
			.stream().map(me -> («edge.fqBeanName»)me.getElement()).
				collect(java.util.stream.Collectors.toList()));
		'''
	
	

	private def void createPrimeReference(ElementEClasses nc) {
		val node = nc.modelElement as Node
		val operationName = '''get«node.primeName.toFirstUpper»'''
		val primeType = EcorePackage.eINSTANCE.EObject
		val stringType = EcorePackage.eINSTANCE.EString
		nc.internalEClass.createEAttribute("libraryComponentUID", EcorePackage.eINSTANCE.EString,0,1)
		nc.mainEClass.createEOperation("getLibraryComponentUID", stringType, 1,1, node.libraryComponentIdGetterContent)
		nc.mainEClass.createEOperation("setLibraryComponentUID", null, 1,1, node.libraryComponentIdSetterContent, createEStringParameter("id",1,1))
		val op = nc.mainEClass.createEOperation(operationName, primeType, 0,1,node.primeReferenceGetter)
		val internalOp = nc.internalEClass.createEOperation(operationName, primeType, 0,1,node.primeReferenceInternalGetter)
		if(node.retrievePrimeReference instanceof ReferencedModelElement) {
			operationReferencedTypeMap.put(op, node)
			operationReferencedTypeMap.put(internalOp, node)
		}
	}
	
	private def libraryComponentIdGetterContent(Node n) '''
	return ((«n.fqInternalBeanName») this.getInternalElement()).getLibraryComponentUID();
	'''
	
	private def libraryComponentIdSetterContent(Node n) '''
	((«n.fqInternalBeanName») this.getInternalElement()).setLibraryComponentUID(id);
	'''
	
	private def getPrimeReferenceGetter(Node node)'''
		String uid = ((«node.fqInternalBeanName»)getInternalElement()).getLibraryComponentUID();
		return «node.primeTypeCast» «ReferenceRegistry.name».getInstance().getEObject(uid);
	'''

	private def getPrimeReferenceInternalGetter(Node node)'''
		String uid = getLibraryComponentUID();
		return «node.primeTypeCast» «ReferenceRegistry.name».getInstance().getEObject(uid);
	'''
	
	/**
	 * Returns cast for prime referenced ModelElement or EClass
	 * will return
	 */
	private def getPrimeTypeCast(Node node){
			switch(node.retrievePrimeReference){
				case node.retrievePrimeReference instanceof ReferencedModelElement : return '''(«node.primeFqTypeName»)'''
				default: return ''''''
			}
	}
	
//	private def getInternalPrimeTypeCast(Node node){
//			switch(node.retrievePrimeReference){
//				case node.retrievePrimeReference instanceof ReferencedModelElement : {
//					return '''(«(node.retrievePrimeReference as ReferencedModelElement).type.fqInternalBeanName»)'''
//				}
//				default: return ''''''
//			}
//	}
	

	private def void createInheritance(ModelElement me, GraphModel gm) {
		if (me.extend !== null) {
			val elmClasses = eClassesMap.get(me.name)
			val inh = eClassesMap.get(me.extend.name)
			elmClasses.mainEClass.ESuperTypes += inh.mainEClass
		}
	}

	private def ElementEClasses createModelElementClasses(ModelElement element) {
		val elementEClasses = new ElementEClasses
		if (!(element instanceof Enumeration)) {

			elementEClasses.modelElement = element
			elementEClasses.mainEClass = element.createEClass

			elementEClasses.internalEClass = element.createInternalEClass(elementEClasses)
			elementEClasses.mainView = createMainView(element, elementEClasses)
			createParentViewMethods(element, elementEClasses)
			element.nonConflictingAttributes.forEach[att| 
				var ec = elementEClasses.mainEClass
				ec.createGetter(ec,att)
				ec.createSetter(ec, att)
				if (att.upperBound !=1) {
					ec.createAdder(ec, att, element instanceof UserDefinedType)
					ec.createRemove(ec,att)
				}
			]

			elementEClasses.createTypedInternalGetter
			elementEClasses.createIsExactlyMethods
			eClassesMap.put(elementEClasses.mainEClass.name, elementEClasses)
		}
		
		return elementEClasses
	}
	
	private def createParentViewMethods(ModelElement element, ElementEClasses elementEClasses) {
		var String parentName = null
		if (element.extend !== null) {
			parentName = element.extend.name
			val parentClasses = eClassesMap.get(parentName)
			var getterName = "get" + parentClasses.mainView.name
			elementEClasses.mainEClass.createEOperation(getterName,parentClasses.mainView,0,1,'''throw new RuntimeException("Not Exactly «parentClasses.modelElement.name»");''')
		}
	}
	
	private def createMainView(ModelElement element, ElementEClasses elmEClasses) {
		val viewName = element.name + "View"
		val getterName = "get" + viewName.toFirstUpper
		val view = createView(viewName, getterName, elmEClasses,true )

		view
	}

	private def EClass createView(String name, String getterName, ElementEClasses elmEClasses, boolean mainView) {
		val eClass = elmEClasses.mainEClass
		val internalEClass = elmEClasses.internalEClass
		val element = elmEClasses.modelElement
		val view = EcoreFactory.eINSTANCE.createEClass
		view.name = name
		view.createReference(internalEClass.name.toFirstLower, internalEClass, 0, 1, false, null)
		var gm = null as GraphModel
		if (element instanceof GraphModel)
			gm = element
		else
			gm = (element.eContainer as GraphModel)

		element.allAttributes.forEach [ attr |
			if (!(attr instanceof ComplexAttribute && (attr as ComplexAttribute).override && mainView)) {
				val feature = attr.internalEClassFeature(internalEClass)
				if (feature !== null) {
					view.createGetter(eClass, attr)
					view.createSetter(eClass, attr)
					if(attr.upperBound !=1 ){
						view.createAdder(eClass, attr, element instanceof UserDefinedType)
						view.createRemove(eClass,attr)
					}
				}
			}

		]

		eClass.createGetView(view, getterName, gm.name.toLowerCase, gm.package)
		view
	}

	private def EStructuralFeature internalEClassFeature(Attribute attr, EClass internalEClass){
		internalEClass.EStructuralFeatures.findFirst[f |attr.name==f.name]		
	}

	private def EClass createEClass(ModelElement element) {
		var eClass = EcoreFactory.eINSTANCE.createEClass
		eClass.name = element.name

		inheritMap.put(element, element.extend)

		modelElementsMap.put(element, eClass);
		if(element.isIsAbstract) {
			eClass.abstract = true
		}
			
		return eClass
	}
		
	private def EClass createInternalEClass(ModelElement element, ElementEClasses elmEClasses) {
		val internalEClass = EcoreFactory.eINSTANCE.createEClass
		internalEClass.name = "Internal" + element.name
		element.allAttributes.forEach[attribute|internalEClass.createAttribute(attribute)]

		return internalEClass
	}

	private  def void createAttribute(EClass eClass, Attribute attribute) {
		if (attribute instanceof ComplexAttribute) {
			if(attribute.type instanceof Enumeration){
				eClass.createEAttributeFromAttribute(attribute)
			}else{
				eClass.createEReferenceFromAttribute(attribute)
			}
		} else if (attribute instanceof PrimitiveAttribute) {
			eClass.createEAttributeFromAttribute(attribute)
		}

	}

	private def void createEAttributeFromAttribute(EClass eClass, Attribute attribute) {
		if(attribute instanceof PrimitiveAttribute){
			val eattr = eClass.createEAttribute(attribute.name, attribute.type.getEDataType, attribute.lowerBound, attribute.upperBound)
			eattr.defaultValue = attribute.defaultValue
		} else if(attribute instanceof ComplexAttribute){
			val eattr = eClass.createEAttribute(attribute.name, enumMap.get(attribute.type), attribute.lowerBound, attribute.upperBound)
			eattr.defaultValue = attribute.defaultValue
		}

	}

	private  def getEDataType(EDataTypeType type) {
		EcorePackage.eINSTANCE.getEClassifier(type.literal) as EDataType
	}

	private def void createEReferenceFromAttribute(EClass eClass, ComplexAttribute attribute) {
		val containment = attribute.type instanceof UserDefinedType
		val eReference = eClass.createReference(attribute.name, null, attribute.lowerBound, attribute.upperBound, containment, null)
		toReferenceMap.put(eReference, attribute.type)
	}

	private def HashMap<ModelElement,? extends ElementEClasses> createEdges(GraphModel model) {
		val edg = new HashMap<ModelElement,ElementEClasses> ();
		model.edges.topSort.forEach[edg.put(it,createModelElementClasses)]
		edg.values.forEach[ec|
			if(ec.modelElement.extends=== null)
				ec.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("Edge") as EClass;
			ec.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalEdge") as EClass;
			ec.generateTypedSourceGetter
			ec.generateTypedTargetGetter
		]

		return edg
	}
	
	private def generateTypedSourceGetter(ElementEClasses ec) {
		val mec = (ec.modelElement as Edge)
		val bestSource = (mec.subTypes.map[it as Edge] + mec.iterable).map[allPossibleSources].flatten.lowestMutualSuperNode
		if(bestSource!== null){
			val beanName = bestSource.fqBeanName
			val eOp = ec.mainEClass.createEOperation("getSourceElement", null, 0, 1, '''return(«beanName»)super.getSourceElement();''')
			putToGetterMap(eOp,bestSource)
		}
	}

	private def generateTypedTargetGetter(ElementEClasses ec){
		val mec = (ec.modelElement as Edge)
		val bestTarget = (mec.subTypes.map[it as Edge] + mec.iterable).map[allPossibleTargets].flatten.lowestMutualSuperNode
		if(bestTarget!== null){
			val beanName = bestTarget.fqBeanName
			val eOp = ec.mainEClass.createEOperation("getTargetElement",null,0,1,'''return(«beanName»)super.getTargetElement();''')
			putToGetterMap(eOp,bestTarget)
		}
		
	}
	
	private def generateTypedModelElementGetter(ElementEClasses ec){
		val me = ec.modelElement
		val ecl = ec.mainEClass
		if(me instanceof ContainingElement){
			//val l = me.containableElements.map[types].flatten.filter(Node).lowestMutualSuperNode
			val l = me.allContainableNodes.lowestMutualSuperNode
			var content = null as CharSequence
			if(l!== null){
				content = typedModelElementGetterContent(l.fqBeanName)
				val eGen = ecl.createGenericListEOperation("getNodes",null,0,-1,content)
				complexGenericGetterParameterMap.put(eGen,l)
			}
		}
	}
	
	private def typedModelElementGetterContent(CharSequence fqBeanName) '''
		return org.eclipse.emf.common.util.ECollections.unmodifiableEList(getInternalContainerElement().getModelElements()
				.stream().map(me -> («fqBeanName»)me.getElement()).
					collect(java.util.stream.Collectors.toList()));
	'''
	

	private def HashMap<ModelElement,? extends ElementEClasses> createUserDefinedTypes(GraphModel model) {
		val internalTypeClass = internalPackage.internalType
		val typeClass = graphModelPackage.getType
		val udts = new HashMap<ModelElement,ElementEClasses>
		model.types.filter(UserDefinedType).topSort.forEach[udt|/*println(udt);*/udts.put(udt,udt.createModelElementClasses)]

		udts.values.forEach[
			internalEClass.ESuperTypes+=internalTypeClass
			mainEClass.ESuperTypes+=typeClass

		]
		udts

	}

	private def Iterable<? extends EClassifier> createEnums(GraphModel model) {
		model.types.filter(Enumeration).map[en| en.createEnumeration]
	}

	private def EClassifier createEnumeration(Enumeration enumeration){
		val eenum = EcoreFactory.eINSTANCE.createEEnum
		eenum.name=enumeration.name
		val lits = new ArrayList<EEnumLiteral>
		enumeration.literals.forEach[lit,i| var el= EcoreFactory.eINSTANCE.createEEnumLiteral;el.literal=lit;el.name=lit;el.value=i;lits+=el]
		eenum.ELiterals+=lits
		enumMap.put(enumeration,eenum)
		eenum

	}

	private def createGetView(EClass modelElementClass, EClass view, String getterName, String ePackageName, String javaPackageName) {
		val content = modelElementClass.createGetViewContent(view, ePackageName, javaPackageName)

		modelElementClass.createEOperation(getterName, view, 0, 1, content.toString)

	}
	
	private def createIsExactlyMethods(ElementEClasses mec){
		val mClass = mec.mainEClass
		val me = mec.modelElement
		mClass.createEOperation("isExactly"+me.name,EcorePackage.eINSTANCE.EBoolean,0,1,"return true;")
		if(me.extends!== null)
			mClass.createEOperation("isExactly"+me.extends.name,EcorePackage.eINSTANCE.EBoolean,0,1,"return false;") 
		
	}

	private def createGetViewContent(EClass modelElementClass, EClass view, String ePackageName, String packageName) '''
		«view.name» «view.name.toFirstLower» = «packageName».«ePackageName».views.ViewsFactory.eINSTANCE.create«view.name»();
				«view.name.toFirstLower».setInternal«modelElementClass.name»((«packageName».«ePackageName».internal.Internal«modelElementClass.name»)getInternalElement());
				return «view.name.toFirstLower»;
	'''
	
	

	private dispatch def createGetter(EClass view, EClass modelElementClass, PrimitiveAttribute attr) {
		val content = createGetterContent(modelElementClass, attr.name, attr.getterPrefix)
		val getterName = attr.getterPrefix + attr.name.toFirstUpper
		val opType = attr.type.EDataType
		view.createEOperation(getterName, opType, attr.lowerBound, attr.upperBound, content.toString)

	}
	
	private dispatch def createGetter(EClass view, EClass modelElementClass, ComplexAttribute attr) {
		var CharSequence content
		if(!(attr.type instanceof Enumeration)){
			content = createComplexGetterContent(modelElementClass, attr)
		}else{
			content = modelElementClass.createGetterContent(attr.name, '''get''')
		}
		val getterName = "get" + attr.name.toFirstUpper
		val eOp = view.createEOperation(getterName, null, attr.lowerBound, attr.upperBound,content.toString)
		putToGetterMap(eOp,attr.type)

	}

	private def createGetterContent(EClass eClass, String attrName, CharSequence getterPrefix) '''
	return getInternal«eClass.name»().«getterPrefix»«attrName.toFirstUpper»();
	'''
	
	private def createComplexGetterContent(EClass eClass, ComplexAttribute attr) '''
«««	«attr.type.fqInternalBeanName» «attr.name.toLowerCase» = 
	return getInternal«eClass.name»().get«attr.name.toFirstUpper»();
«««	if(«attr.name.toLowerCase»!=null){
«««		return («attr.type.name»)«attr.name.toLowerCase».getElement();
«««	}else{
«««		return null;
«««	}
	'''
	
	dispatch def putToGetterMap(EOperation eOp, Type type){
		complexGetterParameterMap.put(eOp,type)	
	}
	
	dispatch def putToGetterMap(EOperation eOp, Enumeration type){
		enumGetterParameterMap.put(eOp,type)
	}
	
	private dispatch def createSetter(EClass view, EClass modelElementClass, PrimitiveAttribute attr) {
		var name = "set" + attr.name.toFirstUpper
		
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = "_arg"
//		parameter.name = attr.name.toFirstLower
		parameter.lowerBound = 0
		parameter.upperBound = attr.upperBound
		
		println("\t" + attr.type)
		val opType = attr.type.EDataType
		parameter.EType = opType
		
		var content = if (attr.upperBound == 1) { createSetterContent(modelElementClass, attr.name)     }
		              else                      { createListSetterContent(modelElementClass, attr.name) } 
		
		view.createEOperation(name, null, 0, 1, content, parameter)
	}

	private dispatch def createSetter(EClass view, EClass modelElementClass, ComplexAttribute attr) {
		var name = "set" + attr.name.toFirstUpper
		
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = "_arg"
//		parameter.name = attr.name.toFirstLower
		parameter.lowerBound = 0
		parameter.upperBound = attr.upperBound
		
		var content = if (attr.upperBound == 1) { createSetterContent(modelElementClass, attr.name)     }
		              else                      { createListSetterContent(modelElementClass, attr.name) } 
		
		view.createEOperation(name, null, 0, 1, content, parameter)
		putSetterParameter(parameter, attr.type)
	}
	
	private def createSetterContent(EClass modelElementClass, String featureName) '''
		getInternal«modelElementClass.name»().getElement().transact("Set «featureName.toFirstUpper»", () -> {
			getInternal«modelElementClass.name»().set«featureName.toFirstUpper»(_arg);
		});
			
	'''
	
	private def createListSetterContent(EClass modelElementClass, String featureName) '''
		getInternal«modelElementClass.name»().getElement().transact("Set «featureName.toFirstUpper»", () -> {
			getInternal«modelElementClass.name»().get«featureName.toFirstUpper»().clear();
			getInternal«modelElementClass.name»().get«featureName.toFirstUpper»().addAll(_arg);
		});
			
	'''

	private dispatch def Type putSetterParameter(EParameter parameter, Enumeration type) {
		enumSetterParameterMap.put(parameter, type)
	}

	private dispatch def Type putSetterParameter(EParameter parameter, Type type) {
		complexSetterParameterMap.put(parameter, type)
	}

	private dispatch def createAdder(EClass view, EClass modelElementClass, PrimitiveAttribute attr, boolean isUserDefinedType) {
		var name = "add" + attr.name.toFirstUpper
			
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = "_arg"
//		parameter.name = attr.name.toFirstLower
		parameter.lowerBound = 0
		parameter.upperBound = 1
		val opType = attr.type.EDataType
		parameter.EType = opType
			
		var content = createAdderContent(modelElementClass, attr.name, isUserDefinedType)
		
		view.createEOperation(name, null, 0, 1, content, parameter)
	}

	private dispatch def createAdder(EClass view, EClass modelElementClass,ComplexAttribute attr, boolean isUserDefinedType) {
		var name = "add" + attr.name.toFirstUpper
			
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = "_arg"
//		parameter.name = attr.name.toFirstLower
		parameter.lowerBound = 0	
		parameter.upperBound = 1
			
		var content = createAdderContent(modelElementClass, attr.name, isUserDefinedType)
		
		view.createEOperation(name, null, 0, 1, content, parameter)
		putSetterParameter(parameter, attr.type)
	}
	
	private def createAdderContent(EClass modelElementClass, String featureName, boolean isUserDefinedType) '''
		getInternal«modelElementClass.name»().getElement().transact("Set «featureName.toFirstUpper»", () -> {
			getInternal«modelElementClass.name»().get«featureName.toFirstUpper»().add(_arg);
		});
	'''

	dispatch def void createRemove(EClass view, EClass modelElementClass,ComplexAttribute attr){
		var CharSequence content = removeContent(modelElementClass,attr.name)
		val removeName = "remove"+ attr.name.toFirstUpper
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = attr.name.toFirstLower
		parameter.upperBound = 1
		parameter.lowerBound = 0
		view.createEOperation(removeName, null, 0, 1, content, parameter)
		putSetterParameter(parameter, attr.type)
	}
	
	dispatch def void createRemove(EClass view, EClass modelElementClass,PrimitiveAttribute attr){
		val content = removeContent(modelElementClass,attr.name)
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = attr.name.toFirstLower
		val setterName = "remove" + attr.name.toFirstUpper
		parameter.upperBound = 1
		parameter.lowerBound = 0
		val opType = attr.type.EDataType
		parameter.EType = opType
		view.createEOperation(setterName, null, 0, 1, content.toString, parameter)
	}
	
	def removeContent(EClass modelElementClass, String featureName)'''
	getInternal«modelElementClass.name»().getElement().transact("Set «featureName.toFirstUpper»", () -> {
		getInternal«modelElementClass.name»().get«featureName.toFirstUpper»().remove(«featureName»);
	});	
	'''

	private def createTypedInternalGetter(ElementEClasses elmClasses){
		val methodName = '''getInternal«elmClasses.modelElement.name»'''
		elmClasses.mainEClass.createEOperation(methodName,elmClasses.internalEClass,0,1,elmClasses.typedInternalGetterContent)
	}

	private def typedInternalGetterContent(ElementEClasses elmClasses)'''
	return («elmClasses.modelElement.fqInternalBeanName») getInternalElement();
	'''

	private def getterPrefix(PrimitiveAttribute attr) {
		if (attr.type !== null && attr.type==EDataTypeType.EBOOLEAN) '''is''' else '''get'''
	}
	
	private def createSpecializedGetContainer(ElementEClasses it){
		val n = modelElement as GraphicalModelElement
		
		val containers = n.allContainingElements
		if(!containers.nullOrEmpty && containers.filter(GraphModel).size == 0){
			val lmsn  = containers.filter(Node).lowestMutualSuperNode
			println(containers)
			println(lmsn)
			if(lmsn !== null){
				val content = specializedGetContainerContent(lmsn.fqBeanName)
				val eObj = mainEClass.createEOperation("getContainer",null,0,1,content)
				complexGetterParameterMap.put(eObj,lmsn)
			}
		}else if(containers.size == 1 && containers.head instanceof GraphModel){
			val content = specializedGetContainerContent(modelElement.graphModel.fqBeanName)
				val eObj = mainEClass.createEOperation("getContainer",null,0,1,content)
				complexGetterParameterMap.put(eObj,modelElement.graphModel)
		}
	}
	
	
	def Iterable<ContainingElement>allContainingElements(GraphicalModelElement element){
		if(element !== null){
		val containingElements = new HashSet<ContainingElement> 
		val containable = element.graphModel.allContainmentConstraints
		if (containable.exists[(types.contains(element)||types.empty) && upperBound !== 0] || element.graphModel.containableElements.empty) {			
			containingElements += element.graphModel
		}
		
		containingElements += element.containingElements
		containingElements += element.allSuperTypes.map[(it as GraphicalModelElement).containingElements].flatten
		containingElements += element.subTypes.map[(it as GraphicalModelElement).containingElements].flatten
		containingElements
		
		}else #[]
	}
	
	def containingElements(GraphicalModelElement element){
		element.graphModel.nodeContainers.filter[allContainmentConstraints.exists[types.contains(element) && upperBound !== 0]]
	}
	
	def specializedGetContainerContent(CharSequence fqName)'''
	return («fqName»)getInternalElement().getContainer().getContainerElement();
	'''

}
