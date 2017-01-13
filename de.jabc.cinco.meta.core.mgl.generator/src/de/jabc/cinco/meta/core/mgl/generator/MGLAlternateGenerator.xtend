package de.jabc.cinco.meta.core.mgl.generator

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.dependency.DependencyGraph
import de.jabc.cinco.meta.core.utils.dependency.DependencyNode
import graphmodel.GraphmodelPackage
import java.util.ArrayList
import java.util.HashMap
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.EDataTypeType
import mgl.Edge
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.PrimitiveAttribute
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier
import org.eclipse.emf.ecore.EDataType
import org.eclipse.emf.ecore.EOperation
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.EcorePackage

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.NodeMethodsGeneratorExtensions.*
import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.FactoryGeneratorExtensions.*
import mgl.Enumeration
import org.eclipse.emf.ecore.EEnumLiteral
import mgl.ContainingElement
import org.eclipse.xtext.generator.IFileSystemAccess

class MGLAlternateGenerator {

	HashMap<ModelElement, EClass> modelElementsMap

	HashMap<ModelElement, ModelElement> inheritMap

	HashMap<EReference, Type> toReferenceMap

	val GraphmodelPackage graphModelPackage = GraphmodelPackage.eINSTANCE
	val internalPackage = graphmodel.internal.InternalPackage.eINSTANCE

	HashMap<String, ElementEClasses> eClassesMap

	HashMap<EOperation, EStructuralFeature> setterParameterMap
	HashMap<EOperation, EStructuralFeature> getterParameterMap
	HashMap<Type,EClassifier> enumMap
	
	def createFactory(GraphModel graphModel){
		graphModel.createFactory(eClassesMap)
		
	}

	def EPackage generateEcoreModel(GraphModel graphModel) {
		eClassesMap = new HashMap
		modelElementsMap = new HashMap
		inheritMap = new HashMap
		toReferenceMap = new HashMap
		setterParameterMap = new HashMap
		getterParameterMap = new HashMap
		enumMap = new HashMap
		val elementEClasses = new ArrayList<ElementEClasses>

		var epk = createEPackage(graphModel)
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
		internalEPackage.EClassifiers += elementEClasses.map[ec|ec.internalEClass]
		viewsEPackage.EClassifiers += elementEClasses.map[ec|ec.mainView]
		viewsEPackage.EClassifiers += elementEClasses.map[ec|ec.views].flatten
	
		
		toReferenceMap.forEach[key, value|key.EType = eClassesMap.get(value.name).mainEClass]
		getterParameterMap.forEach[key, value|key.EType = value.EType]
		setterParameterMap.forEach[key, value|key.EParameters.get(0).EType = value.EType]

		graphModel.nodes.forEach[node|
			node.createInheritance(graphModel)
			eClassesMap.get(node.name).mainEClass.EOperations+=node.createConnectionMethods(graphModel,eClassesMap)
		]
		
		graphModel.edges.forEach[edge|edge.createInheritance(graphModel)]
		graphModel.types.filter(UserDefinedType).forEach[udt|udt.createInheritance(graphModel)]
		return epk
	}

	def createViewsEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = "views"
		epk.nsPrefix = model.name.toLowerCase + "-views"
		epk.nsURI = model.nsURI + "/views"
		epk
	}

	def createInternalEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = "internal"
		epk.nsPrefix = model.name.toLowerCase + "-internal"
		epk.nsURI = model.nsURI + "/internal"
		epk
	}

	def createEPackage(GraphModel model) {
		var epk = EcoreFactory.eINSTANCE.createEPackage
		epk.name = model.name.toLowerCase
		epk.nsPrefix = model.name.toLowerCase
		epk.nsURI = model.nsURI
		epk
	}

	def ElementEClasses createGraphModel(GraphModel model) {
		val gmClasses = model.createModelElementClasses
		gmClasses.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("GraphModel") as EClass
		gmClasses.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalGraphModel") as EClass		
		gmClasses

	}

	def Iterable<? extends ElementEClasses> createNodes(GraphModel model) {
		val nodeClasses = new ArrayList<ElementEClasses>

		var sorted = model.nodes.topSort

		println(sorted.map[n|n.name])

		sorted.forEach[node|nodeClasses += node.createModelElementClasses]
		nodeClasses.filter[n| !(n instanceof ContainingElement)].forEach[nc|
			nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Node") as EClass);
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalNode") as EClass);
		]
		nodeClasses.filter[n| (n instanceof ContainingElement)].forEach[nc|nc.mainEClass.ESuperTypes.add(graphModelPackage.getEClassifier("Container") as EClass);
			nc.internalEClass.ESuperTypes.add(graphModelPackage.ESubpackages.filter[sp| sp.name.equals("internal")].get(0).getEClassifier("InternalContainer") as EClass);
		]
		
		nodeClasses
	}

	def topSort(Iterable<? extends ModelElement> elements) {
		new DependencyGraph<ModelElement>(new ArrayList).createGraph(elements.map[el|el.dependencies], new ArrayList).
			topSort

	}

	def DependencyNode<ModelElement> dependencies(ModelElement elem) {
		val dNode = new DependencyNode<ModelElement>(elem)
		dNode.addDependencies(elem.allSuperTypes.map[t|t].toList)
		dNode
	}

	def void createInheritance(ModelElement me, GraphModel gm) {
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
	def ElementEClasses createModelElementClasses(ModelElement element) {
		val elementEClasses = new ElementEClasses
		elementEClasses.modelElement = element
		elementEClasses.mainEClass = element.createEClass
		elementEClasses.internalEClass = element.createInternalEClass(elementEClasses)
		elementEClasses.mainView = createMainView(element, elementEClasses)
		elementEClasses.views += createViews(element, elementEClasses)

		eClassesMap.put(elementEClasses.mainEClass.name, elementEClasses)

		elementEClasses
	}

	def Iterable<? extends EClass> createViews(ModelElement element, ElementEClasses elementEClasses) {

		var views = new ArrayList<EClass>();

		var String parentName = null
		if (element.extend != null) {
			parentName = element.extend.name
			val parentClasses = eClassesMap.get(parentName)
			elementEClasses.views += parentClasses.createSubViews(elementEClasses)
		}

		views
	}

	def createSubViews(ElementEClasses parent, ElementEClasses subClasses) {
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

	def ModelElement getHighestSuperView(ModelElement view) {
		var v = view;
		println(v.name)
		while (v.extend != null) {
			v = v.extend
		}
		v
	}

	def createMainView(ModelElement element, ElementEClasses elmEClasses) {
		val viewName = element.name + "View"
		val getterName = "get" + viewName.toFirstUpper
		val view = createView(viewName, getterName, elmEClasses,true )

		view
	}

	def EClass createView(String name, String getterName, ElementEClasses elmEClasses, boolean mainView) {
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
	

	def EStructuralFeature internalEClassFeature(Attribute attr, EClass internalEClass){
		internalEClass.EStructuralFeatures.findFirst[f |attr.name==f.name]		
	}

	def EClass createEClass(ModelElement element) {
		var eClass = EcoreFactory.eINSTANCE.createEClass
		eClass.name = element.name

		inheritMap.put(element, element.extend)

		modelElementsMap.put(element, eClass);

		eClass
	}

	def EClass createInternalEClass(ModelElement element, ElementEClasses elmEClasses) {
		val eClass = elmEClasses.mainEClass
		val internalEClass = EcoreFactory.eINSTANCE.createEClass
		internalEClass.name = "Internal" + element.name

		eClass.createReference(
			"internal" + element.name,
			internalEClass,
			0,
			1,
			true,
			internalEClass.createReference(element.name.toFirstLower, eClass, 0, 1, false, null)
		)

		element.attributes.forEach[attribute|internalEClass.createAttribute(attribute)]
		
		internalEClass
	}

	def Iterable<? extends ModelElement> allSuperTypes(ModelElement element) {
		val superTypes = new ArrayList<ModelElement>
		var current = element.extend
		while (current.extend != null || current != current.extend) {
			superTypes += current
			current = current.extend
		}

		superTypes
	}

	def ModelElement extend(ModelElement element) {
		if (element instanceof Node) {
			return element.extends
		} else if (element instanceof Edge) {
			return element.extends
		} else if (element instanceof UserDefinedType) {
			element.extends
		}
		null
	}

	def void createAttribute(EClass eClass, Attribute attribute) {
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

	def void createEAttributeFromAttribute(EClass eClass, Attribute attribute) {
		if(attribute instanceof PrimitiveAttribute){
		eClass.createEAttribute(attribute.name, attribute.type.getEDataType, attribute.lowerBound, attribute.upperBound)
		
		}else if(attribute instanceof ComplexAttribute){
			val enmAttr = eClass.createEAttribute(attribute.name, enumMap.get(attribute.type), attribute.lowerBound, attribute.upperBound)
		}

	}

	def getEDataType(EDataTypeType type) {
		EcorePackage.eINSTANCE.getEClassifier(type.literal) as EDataType
	}

	def void createEReferenceFromAttribute(EClass eClass, ComplexAttribute attribute) {
		val eReference = eClass.createReference(attribute.name, null, attribute.lowerBound, attribute.upperBound, false,
			null)
		toReferenceMap.put(eReference, attribute.type)
	}

	def Iterable<? extends ElementEClasses> createEdges(GraphModel model) {
		val edg = new ArrayList<ElementEClasses> ();
		model.edges.forEach[e| edg+= e.createModelElementClasses]
		edg.forEach[ec|ec.mainEClass.ESuperTypes += graphModelPackage.getEClassifier("Edge") as EClass;
			ec.internalEClass.ESuperTypes += internalPackage.getEClassifier("InternalEdge") as EClass
		]

		edg

	}

	def Iterable<? extends ElementEClasses> createUserDefinedTypes(GraphModel model) {
		model.types.filter(UserDefinedType).map[udt|udt.createModelElementClasses]

	}

	def Iterable<? extends EClassifier> createEnums(GraphModel model) {
		model.types.filter(Enumeration).map[en| en.createEnumeration]
	}
	
	def EClassifier createEnumeration(Enumeration enumeration){
		val eenum = EcoreFactory.eINSTANCE.createEEnum
		eenum.name=enumeration.name
		val lits = new ArrayList<EEnumLiteral>
		enumeration.literals.forEach[lit,i| var el= EcoreFactory.eINSTANCE.createEEnumLiteral;el.literal=lit;el.name=lit;el.value=i;lits+=el]
		eenum.ELiterals+=lits
		enumMap.put(enumeration,eenum)
		eenum
		
	}

	def createGetView(EClass modelElementClass, EClass view, String getterName, String ePackageName, String javaPackageName) {
		val content = modelElementClass.createGetViewContent(view, ePackageName, javaPackageName)

		modelElementClass.createEOperation(getterName, view, 0, 1, content.toString)

	}

	def createGetViewContent(EClass modelElementClass, EClass view, String ePackageName, String packageName) '''
		«view.name» «view.name.toFirstLower» = «packageName».«ePackageName».views.ViewsFactory.eINSTANCE.create«view.name»();
				«view.name.toFirstLower».setInternal«modelElementClass.name»(getInternal«modelElementClass.name»());
				return «view.name.toFirstLower»;
	'''

	def createSetter(EClass view, EClass modelElementClass, EStructuralFeature eFeature) {
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
	

	def createSetterContent(EClass modelElementClass, EStructuralFeature eFeature) '''
		getInternal«modelElementClass.name»().set«eFeature.name.toFirstUpper»(«eFeature.name»);
	'''

	def createGetter(EClass view, EClass modelElementClass, EStructuralFeature eFeature) {
		val content = createGetterContent(modelElementClass, eFeature)
		val getterName = "get" + eFeature.name.toFirstUpper
		val eOp = view.createEOperation(getterName, eFeature.EType, eFeature.lowerBound, eFeature.upperBound,
			content.toString)
		if (eFeature.EType == null) {
			getterParameterMap.put(eOp, eFeature)
		}

	}

	def createGetterContent(EClass eClass, EStructuralFeature eFeature) '''
		return getInternal«eClass.name»().get«eFeature.name.toFirstUpper»();
	'''
}