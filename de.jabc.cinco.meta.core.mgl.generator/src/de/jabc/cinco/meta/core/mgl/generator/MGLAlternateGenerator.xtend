package de.jabc.cinco.meta.core.mgl.generator

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.dependency.DependencyGraph
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode
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
import mgl.ModelElement
import mgl.Node
import mgl.PrimitiveAttribute
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EEnumLiteral
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.FactoryGeneratorExtensions.*
//import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.NodeMethodsGeneratorExtensions.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EdgeMethodsGeneratorExtension.*
import mgl.NodeContainer
import de.jabc.cinco.meta.core.mgl.generator.extensions.NodeMethodsGeneratorExtensions
import de.jabc.cinco.meta.core.mgl.generator.extensions.AdapterGeneratorExtension
import mgl.ReferencedModelElement
import mgl.ReferencedEClass

class MGLAlternateGenerator extends NodeMethodsGeneratorExtensions{

	extension AdapterGeneratorExtension = new AdapterGeneratorExtension


	HashMap<ModelElement, EClass> modelElementsMap

	HashMap<ModelElement, ModelElement> inheritMap

	HashMap<EReference, Type> toReferenceMap

	val GraphmodelPackage graphModelPackage = GraphmodelPackage.eINSTANCE
	val internalPackage = InternalPackage.eINSTANCE

	HashMap<String, ElementEClasses> eClassesMap

	HashMap<EOperation, EStructuralFeature> setterParameterMap
	HashMap<EOperation, EStructuralFeature> getterParameterMap
	HashMap<Type,EClassifier> enumMap
	
	HashMap<Node, EOperation>  operationReferencedTypeMap
	
	def createFactory(GraphModel graphModel){
		graphModel.createFactory(eClassesMap.filter[p1, p2|!p2.mainEClass.abstract])
	}
	
	def createAdapter(ModelElement me) {
		me.generateAdapter
	}

	def Iterable<EPackage> generateEcoreModel(GraphModel graphModel, Iterable<EPackage> mglEPackages) {
		eClassesMap = new HashMap
		modelElementsMap = new HashMap
		inheritMap = new HashMap
		toReferenceMap = new HashMap
		setterParameterMap = new HashMap
		getterParameterMap = new HashMap
		enumMap = new HashMap
		operationReferencedTypeMap = new HashMap
		val elementEClasses = new ArrayList<ElementEClasses>

		val epk = createEPackage(graphModel)
		val newEPackages = new ArrayList<EPackage>
		newEPackages += epk
		newEPackages+=mglEPackages
		val internalEPackage = createInternalEPackage(graphModel)
		val viewsEPackage = createViewsEPackage(graphModel)
		epk.ESubpackages += internalEPackage
		epk.ESubpackages += viewsEPackage
		epk.EClassifiers += graphModel.createEnums
		elementEClasses += graphModel.createGraphModel
		elementEClasses += graphModel.createNodes
		elementEClasses += graphModel.createEdges
		elementEClasses += graphModel.createUserDefinedTypes
		
		
		epk.EClassifiers += elementEClasses.map[ec|ec.mainEClass]
		internalEPackage.EClassifiers += elementEClasses.filter[internalEClass!=null].map[internalEClass]
		viewsEPackage.EClassifiers += elementEClasses.filter[mainView!=null].map[mainView]
		viewsEPackage.EClassifiers += elementEClasses.filter[!views.nullOrEmpty].map[views].flatten
	
		
		toReferenceMap.forEach[key, value|key.EType = eClassesMap.get(value.name).mainEClass]
		getterParameterMap.forEach[key, value|key.EType = value.EType]
		setterParameterMap.forEach[key, value|key.EParameters.get(0).EType = value.EType]
		operationReferencedTypeMap.forEach[node, operation| operation.setPrimeType(node, newEPackages)]

		graphModel.createCanNewNodeMethods(eClassesMap)
		graphModel.createNewNodeMethods(eClassesMap.filter[p1,p2| !p2.mainEClass.abstract])
		
		graphModel.nodes.forEach[node|
			node.createInheritance(graphModel)
			node.createConnectionMethods(graphModel,eClassesMap)
			node.createCanNewEdgeMethods(eClassesMap)
			node.createNewEdgeMethods(eClassesMap)
			node.createCanMoveToMethods(eClassesMap)
			node.createMoveToMethods(eClassesMap)			
		]
		
		graphModel.nodes.filter(NodeContainer).forEach[container|
			(container as NodeContainer).createGetContainmentConstraintsMethod(graphModel, eClassesMap)
			container.createCanNewNodeMethods(eClassesMap)
			container.createNewNodeMethods(eClassesMap)
		]
		graphModel.edges.forEach[edge|
			edge.createInheritance(graphModel)
			edge.createCanReconnectMethods(eClassesMap)
			edge.createReconnectMethods(eClassesMap)
		]
		graphModel.types.filter(UserDefinedType).forEach[udt|udt.createInheritance(graphModel)]
		return newEPackages
	}
	
	def void setPrimeType(EOperation operation, Node node, Iterable<EPackage> ePackages){
		
		val prime = node.primeReference as ReferencedModelElement
		val etype = ePackages.findFirst[nsURI==prime.type.graphModel.nsURI].getEClassifier(prime.type.name) as EClass
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

	private def ElementEClasses createGraphModel(GraphModel model) {
		val gmClasses = model.createModelElementClasses
		gmClasses.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("GraphModel") as EClass
		gmClasses.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalGraphModel") as EClass		
		gmClasses

	}

	private def Iterable<? extends ElementEClasses> createNodes(GraphModel model) {
		val nodeClasses = new ArrayList<ElementEClasses>

		var sorted = model.nodes.topSort

		println(sorted.map[n|n.name])

		sorted.forEach[node|nodeClasses += node.createModelElementClasses]
		nodeClasses.filter[n| !(n.modelElement instanceof ContainingElement)].forEach[nc|
			nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Node") as EClass);
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalNode") as EClass);
		]
		nodeClasses.filter[n| (n.modelElement instanceof ContainingElement)].forEach[nc|
			nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Container") as EClass);
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalContainer") as EClass);
			
		]
		
		nodeClasses.filter[ (modelElement as Node).prime].filter[(modelElement as Node).primeReference.imprt==null || !(modelElement as Node).primeReference.imprt.stealth].forEach[createPrimeReference]
		
		nodeClasses
	}
	
	def void createPrimeReference(ElementEClasses nc) {
		val node = nc.modelElement as Node
		val operationName = '''get«node.primeName.toFirstUpper»'''
		val primeType = EcorePackage.eINSTANCE.EObject
		nc.internalEClass.createEAttribute("libraryComponentUID", EcorePackage.eINSTANCE.EString,0,1)
		val op = nc.mainEClass.createEOperation(operationName, primeType, 0,1,node.primeReferenceGetter)
		if(node.primeReference instanceof ReferencedModelElement)
			operationReferencedTypeMap.put(node, op)
		
		
	}
	
	def getPrimeReferenceGetter(Node node)'''
		String uid = ((«node.fqInternalBeanName»)getInternalElement()).getLibraryComponentUID();
		«IF node.primeReference instanceof ReferencedEClass»
		return «node.primeTypeCast»de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry.getInstance().getEObject(uid);
		«ELSE»
		return «node.primeTypeCast» («node.internalPrimeTypeCast» de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry.getInstance().getEObject(uid)).getElement();
		«ENDIF»
	'''
	
	def getPrimeTypeCast(Node node){
			switch(node.primeReference){
				case node.primeReference instanceof ReferencedModelElement : return '''(«node.primeTypeName»)'''
				default: return ''''''
			}
	}
	
	def getInternalPrimeTypeCast(Node node){
			switch(node.primeReference){
				case node.primeReference instanceof ReferencedModelElement : {
					return '''(«(node.primeReference as ReferencedModelElement).type.fqInternalBeanName»)'''
				}
				default: return ''''''
			}
	}
	
	/**
	 * Returns Cast fpr prime referenced ModelElement or EClass
	 * Will return
	 */
	
	private def topSort(Iterable<? extends ModelElement> elements) {
		new DependencyGraph<ModelElement>(new ArrayList).createGraph(elements.map[el|el.dependencies], new ArrayList).
			topSort

	}

	private def DependencyNode<ModelElement> dependencies(ModelElement elem) {
		val dNode = new DependencyNode<ModelElement>(elem)
		dNode.addDependencies(elem.allSuperTypes.map[t|t].toList)
		dNode
	}

	private def void createInheritance(ModelElement me, GraphModel gm) {
		if (me.extend != null) {
			val elmClasses = eClassesMap.get(me.name)
			val inh = eClassesMap.get(me.extend.name)
			elmClasses.mainEClass.ESuperTypes += inh.mainEClass
		// elmClasses.overrideGetView(inh,gm)
		}
	}

//	def overrideGetView(ElementEClasses classes, ElementEClasses parent, GraphModel gm) {
//		parent.mainEClass.EOperations.filter[eOp| parent.mainView==eOp.EType || parent.views.contains(eOp.EType)].forEach[op| classes.mainEClass.createGetView(op.EType as EClass,getterName,gm.package)]
//	}
	private def ElementEClasses createModelElementClasses(ModelElement element) {
		val elementEClasses = new ElementEClasses
		if(!(element instanceof Enumeration)){
			
			elementEClasses.modelElement = element
			elementEClasses.mainEClass = element.createEClass
			
				elementEClasses.internalEClass = element.createInternalEClass(elementEClasses)
				elementEClasses.mainView = createMainView(element, elementEClasses)
				elementEClasses.views += createViews(element, elementEClasses)
			
			
		eClassesMap.put(elementEClasses.mainEClass.name, elementEClasses)

	
		
		}
	elementEClasses
	}

	private def Iterable<? extends EClass> createViews(ModelElement element, ElementEClasses elementEClasses) {

		var views = new ArrayList<EClass>();

		var String parentName = null
		if (element.extend != null) {
			parentName = element.extend.name
			val parentClasses = eClassesMap.get(parentName)
			elementEClasses.views += parentClasses.createSubViews(elementEClasses)
		}

		views
	}

	private def createSubViews(ElementEClasses parent, ElementEClasses subClasses) {
		var views = new ArrayList<EClass>
		var getterName = "get" + parent.mainView.name
		var viewName = subClasses.mainEClass.name + parent.mainView.name
		var view = createView(viewName, getterName, subClasses,false)
		view.ESuperTypes += parent.mainView
		views += view
		for (v : parent.views) {
			viewName = subClasses.mainEClass.name + v.name
			getterName = "get" + subClasses.modelElement.highestSuperView.name + "View"
			val sv = createView(viewName, getterName, subClasses,false)
			sv.ESuperTypes += v
			views += sv
		}

		views
	}

	private def ModelElement getHighestSuperView(ModelElement view) {
		var v = view;
		println(v.name)
		while (v.extend != null) {
			v = v.extend
		}
		v
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
		
		
		element.attributes.forEach [attr| 
			if(!(attr instanceof ComplexAttribute && (attr as ComplexAttribute).override && mainView)){
				val feature = attr.internalEClassFeature(internalEClass)
				if(feature!=null){
					view.createGetter(eClass, feature)
					view.createSetter(eClass, feature)
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
		if(element.isIsAbstract)
			eClass.abstract = true
			
		eClass
	}

	private def EClass createInternalEClass(ModelElement element, ElementEClasses elmEClasses) {
//		val eClass = elmEClasses.mainEClass
		val internalEClass = EcoreFactory.eINSTANCE.createEClass
		internalEClass.name = "Internal" + element.name

//		eClass.createReference(
//			"internal" + element.name,
//			internalEClass,
//			0,
//			1,
//			true,
//			internalEClass.createReference(element.name.toFirstLower, eClass, 0, 1, false, null)
//		)

		element.attributes.forEach[attribute|internalEClass.createAttribute(attribute)]
		
		internalEClass
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
		}else if(attribute instanceof ComplexAttribute){
			eClass.createEAttribute(attribute.name, enumMap.get(attribute.type), attribute.lowerBound, attribute.upperBound)
		}

	}

	private  def getEDataType(EDataTypeType type) {
		EcorePackage.eINSTANCE.getEClassifier(type.literal) as EDataType
	}

	private def void createEReferenceFromAttribute(EClass eClass, ComplexAttribute attribute) {
		val eReference = eClass.createReference(attribute.name, null, attribute.lowerBound, attribute.upperBound, false,
			null)
		toReferenceMap.put(eReference, attribute.type)
	}

	private def Iterable<? extends ElementEClasses> createEdges(GraphModel model) {
		val edg = new ArrayList<ElementEClasses> ();
		model.edges.forEach[e| edg+= e.createModelElementClasses]
		edg.forEach[ec|ec.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("Edge") as EClass;
			ec.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalEdge") as EClass
		]

		edg

	}

	private def Iterable<? extends ElementEClasses> createUserDefinedTypes(GraphModel model) {
		val internalTypeClass = internalPackage.internalType
		val typeClass = graphModelPackage.getType
		var udts = model.types.filter(UserDefinedType).map[udt|println(udt);udt.createModelElementClasses]
		udts = 
		udts.map[
			internalEClass.ESuperTypes+=internalTypeClass
			mainEClass.ESuperTypes+=typeClass
			
			it
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

	private def createGetViewContent(EClass modelElementClass, EClass view, String ePackageName, String packageName) '''
		«view.name» «view.name.toFirstLower» = «packageName».«ePackageName».views.ViewsFactory.eINSTANCE.create«view.name»();
				«view.name.toFirstLower».setInternal«modelElementClass.name»((«packageName».«ePackageName».internal.Internal«modelElementClass.name»)getInternalElement());
				return «view.name.toFirstLower»;
	'''

	private def createSetter(EClass view, EClass modelElementClass, EStructuralFeature eFeature) {
		val content = createSetterContent(modelElementClass, eFeature)
		val parameter = EcoreFactory.eINSTANCE.createEParameter
		parameter.name = eFeature.name.toFirstLower
		parameter.EType = eFeature.EType
		val setterName = "set" + eFeature.name.toFirstUpper
		parameter.upperBound = 1
		parameter.lowerBound = 0
		val eOp = view.createEOperation(setterName, null, 0, 1, content.toString, parameter)

		if (parameter.EType == null) {
			setterParameterMap.put(eOp, eFeature)
		}

	}
	

	private def createSetterContent(EClass modelElementClass, EStructuralFeature eFeature) '''
		getInternal«modelElementClass.name»().set«eFeature.name.toFirstUpper»(«eFeature.name»);
	'''

	private def createGetter(EClass view, EClass modelElementClass, EStructuralFeature eFeature) {
		val content = createGetterContent(modelElementClass, eFeature)
		val getterName = "get" + eFeature.name.toFirstUpper
		val eOp = view.createEOperation(getterName, eFeature.EType, eFeature.lowerBound, eFeature.upperBound,
			content.toString)
		if (eFeature.EType == null) {
			getterParameterMap.put(eOp, eFeature)
		}

	}

	private def createGetterContent(EClass eClass, EStructuralFeature eFeature) '''
		return getInternal«eClass.name»().get«eFeature.name.toFirstUpper»();
	'''
	
	/**
	 * Returns EClasses of generated model elements.
	 */
	def getModelElementsClasses() {
		modelElementsMap.values
	}
	
	
	
}
