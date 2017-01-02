package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import de.jabc.cinco.meta.core.utils.CincoUtils
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Map.Entry
import mgl.Annotatable
import mgl.Annotation
import mgl.Attribute
import mgl.Edge
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.common.util.EList

import static extension de.jabc.cinco.meta.core.utils.CincoUtils.*
import javax.el.ExpressionFactory
import org.eclipse.graphiti.features.IAddFeature
import org.eclipse.graphiti.features.ICreateFeature
import org.eclipse.graphiti.features.IDeleteFeature
import org.eclipse.graphiti.features.ILayoutFeature
import org.eclipse.emf.ecore.EFactory

class GeneratorUtils {
	val static String ID_CONTAINER = "Containers";
	val static String ID_NODES = "Nodes";
	
	/**
	 * Generates the body of an if-condition for an instanceof
	 * check.
	 * 
	 * @param varName The name of the variable on the generated code
	 * which should be checked against the type of the given {@link ModelElement}
	 * @param me The {@link ModelElemet} against which the check is executed. 
	 */
	def instanceofCheck(ModelElement me, String varName) 
	'''«varName» instanceof «me.beanPackage».«me.fuName»'''
	
	
	def instanceofCheck(Annotatable a, String varName){
		if (a instanceof ModelElement) {
			var me = a as ModelElement
			return me.instanceofCheck(varName)
		}
		
	}
	
	/**
	 * Returns the {@link ModelElement}'s name in first upper case
	 */
	def fuName(Type t) {
		t.name.toFirstUpper
	}
	
	def fuName(ModelElement me) {
		me.name.toFirstUpper
	}
	
	/**
	 * Returns the {@link ModelElement}'s name in first lower
	 */
	def flName(ModelElement me) {
		me.name.toFirstLower
	}
	
	/**
	 * Returns the package name prefix for the generated graphiti sources.
	 * 
	 * @param gm The processed {@link GraphModel}
	 */
	def packageName(GraphModel gm)
	'''«gm.package».editor.graphiti'''
	
	/**
	 * Returns the package name prefix for the generated graphiti sources.
	 * 
	 * @param me The processed {@link ModelElement}
	 */
	def packageName(ModelElement me)
	'''«me.graphModel.packageName»'''
	
	/**
	 * Returns the package name for the generated {@link ExpressionFactory}
	 * class
	 */
	def packageNameExpression(GraphModel gm)
	'''«gm.package».editor.graphiti.expression'''
	
	/**
	 * Returns the package name for the generated {@link IAddFeature} implementing classes
	 */
	def packageNameAdd(ModelElement me)
	'''«me.graphModel.package».features.add'''
	
	/**
	 * Returns the package name for the generated {@link ICreateFeature} implementing classes
	 */
	def packageNameCreate(ModelElement me)
	'''«me.graphModel.package».features.create'''
	
	/**
	 * Returns the package name for the generated {@link IDeleteFeature} implementing classes
	 */
	def packageNameDelete(ModelElement me)
	'''«me.graphModel.package».features.delete'''
	
	/**
	 * Returns the package name for the generated {@link ILayoutFeature} implementing classes
	 */
	def packageNameLayout(ModelElement me)
	'''«me.graphModel.package».features.layout'''
	
	/**
	 * Returns the package name for the generated {@link IResizeFeature} implementing classes
	 */
	def packageNameResize(ModelElement me)
	'''«me.graphModel.package».features.resize'''
	
	/**
	 * Returns the package name for the generated {@link IMoveFeature} implementing classes
	 */
	def packageNameMove(ModelElement me)
	'''«me.graphModel.package».features.move'''
	
	/**
	 * Returns the package name for the generated {@link IUpdateFeature} implementing classes
	 */
	def packageNameUpdate(ModelElement me)
	'''«me.graphModel.package».features.update'''
	
	/**
	 * Returns the package name of the business object's java class which is generated for the given node
	 * 
	 * @param me The {@link ModelElement} for which the bean package name is retrieved
	 */
	def beanPackage(ModelElement me)
	'''«IF me instanceof UserDefinedType»«var gm = me.eContainer as GraphModel»«gm.package».«gm.name.toLowerCase»
		«ELSE»
		«me.graphModel.package».«me.graphModel.name.toLowerCase»«ENDIF»''' 
	
	/**
	 * Returns the fully qualified name of the generated business object java bean for the given {@link ModelElement}
	 * 
	 * @param me The {@link ModelElement} for which the fully qualified bean name should be retrieved
	 */
	def fqBeanName(ModelElement me)
	'''«me.beanPackage».«me.fuName»'''
	
	/**
	 * Returns the fully qualified name of the {@link EFactory} class for the given {@link ModelElement}, i.e. for the
	 * {@link ModelElement}'s {@link GraphModel}. 
	 */
	def fqFactoryName(ModelElement me) 
	'''«me.graphModel.package».«me.graphModel.name.toLowerCase».«me.graphModel.name.toLowerCase.toFirstUpper»Factory'''
	
	/**
	 * Returns the fully qulified name of the generated property view class
	 */
	def fqPropertyView(ModelElement me) 
	'''«me.graphModel.packageName».property.view.«me.graphModel.fuName»PropertyView'''
	
	/**
	 * Returns the package name for the generated {@link IDeleteFeature} implementing classes
	 */
	def modelElements(GraphModel gm) {
		var List<ModelElement> mes = new ArrayList<ModelElement>;
		mes.addAll(gm.nodes)
		mes.addAll(gm.edges)
		mes.add(gm)
		return mes
	}
	 
	/**
	 * Returns the {@link GraphModel} of the given {@link ModelElement}
	 * 
	 * @param me The {@link ModelElement} for which to retrieve the {@link GraphModel} 
	 */
	def getGraphModel(ModelElement me) {
		if (me instanceof GraphModel)
			return me
		if (me instanceof Node) {
			var n = me as Node
			return n.graphModel
		}
		if (me instanceof Edge) {
			var e = me as Edge
			return e.graphModel
		}
	}
	
	/**
	 * Returns the {@link ModelElement}'s name. All letters except for the first letter are in lower case
	 * 
	 * @param The {@ModelElement}
	 */
	def firstUpperOnly(ModelElement me)
	'''«me.name.toLowerCase.toFirstUpper»'''
	
	/** 
	 * Returns the fully qualified name of the java.util.Map$Entry class
	 */
	def entryName(Class<Entry> e) '''java.util.Map.Entry'''
	
	def getPaletteGroupsMap(GraphModel gm) {
		val map = new HashMap<String, List<GraphicalModelElement>>
		map.put(ID_NODES, new ArrayList)
		for (Node n : gm.nodes.filter[!isIsAbstract && primeReference == null && !isCreateDisabled]) {
			if (!hasPaletteCategory(n))
				map.get(ID_NODES).add(n);

			n.annotations.filter[name.equals("palette")].forEach[value.forEach[v | addToMap(map, v, n)]]
		}
		
		for (Edge e : gm.edges.filter[e | !e.isIsAbstract && !e.isCreateDisabled]){
			e.annotations.filter[name.equals("palette")].forEach[value.forEach[v | addToMap(map,v, e)]]
		}
			
		map.remove("none");
		map.remove("None");
		map.remove("NONE");
		
		return map
	}
	
	def addToMap(Map<String, List<GraphicalModelElement>> m, String paletteName, GraphicalModelElement me) {
		if (m.get(paletteName) == null)
			m.put(paletteName, new ArrayList)
		m.get(paletteName).add(me)
	}
	
	def hasPaletteCategory(ModelElement me) {
		me.annotations.filter[a | a.name.equals("palette")].size > 0
	}
	
	def allModelAttributes(GraphModel gm) {
		gm.eResource.allContents.toIterable.filter[c | c instanceof Attribute].map[a | a as Attribute]
	}
	
	def String getIconNodeValue(Node n){
		var icon ="";
		var EList <Annotation> annots = n.annotations;
		for (annot : annots){
			if(annot.name.equals("icon")){
				icon = annot.value.get(0);
			}
		}
		return icon;		
	}
	
	def isPrime(Node n)
	{
		if(n.primeReference != null)
			return true
		return false;
	}

	dispatch def primeType(ReferencedModelElement rme) {
		return rme.type.name
	}
	
	dispatch def primeType(ReferencedEClass rec) {
		return rec.type.name
	}
	
	def primeName(Node n)
	{
		return n.primeReference.name
	}
	
	dispatch def nsURI(ReferencedModelElement rem) {
		return rem.type.graphModel.nsURI
	}
	
	dispatch def nsURI(ReferencedEClass refEClass) {
		return refEClass.type.EPackage.nsURI
	}
	
	def addFeaturePrimeCode(Node n) '''
	new AddFeaturePrime«n.fuName»(this),
	'''
	
	/**
	 *  Checks if a postCreateHook is annotated at the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def booleanWriteMethodCallPostCreate(ModelElement me){
		
		var annot = CincoUtils.findAnnotationPostCreate(me);
		if(annot != null)
			return true;
		return false;
	}
	
	/**
	 * Generates the postCreate code for the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def writeMethodCallPostCreate(ModelElement me){
		var annot = CincoUtils.findAnnotationPostCreate(me);
		if(annot != null)
		{
			var class = annot.value.get(0)
			return '''new «class»().postCreate((«me.fqBeanName») modelCreate);'''	
		}
	}
	
	/**
	 *  Checks if a postMoveHook is annotated at the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	 def booleanWriteMethodCallPostMove(ModelElement me){
		var annot = CincoUtils.findAnnotationPostMove(me);
		if(annot != null)
			return true;
		return false;
	}
	
	/**
	 * Generates the postMove code for the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def writeMethodCallPostMove(ModelElement me){
		var annot = CincoUtils.findAnnotationPostMove(me);
		if(annot != null)
		{
			var class = annot.value.get(0)
			
			return '''new «class»().postMove(«me.name.toLowerCase», CSource, CTarget, x ,y, deltaX, deltaY);'''
		}
	}
	
	/**
	 * Checks if a postResizeHook is annotated at the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def booleanWriteMethodCallPostResize(ModelElement me){
		var annot = CincoUtils.findAnnotationPostResize(me);
		if(annot != null)
			return true;
		return false;
	}
	
	/**
	 * Generates the postResize code for the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def writeMethodCallPostResize(ModelElement me){
		var annot = CincoUtils.findAnnotationPostResize(me);
		me.graphModel
		if(annot != null)
		{
			var class = annot.value.get(0)
			return '''new «class»().postResize(«me.name.toLowerCase», direction, height, width);'''	
		}
	}

	/**
	 *  Checks if a postMoveHook is annotated at the {@link ModelElement}
	 * 
	 * @param me The processed {@link mgl.ModelElement} 
	 */
	def booleanWriteMethodCallPostSelect(ModelElement me){
		var annot = CincoUtils.findAnnotationPostSelect(me);
		if(annot != null)
			return true;
		return false;
	}
	
	def writeMethodCallPostSelect(ModelElement me){
		var annot = CincoUtils.findAnnotationPostSelect(me);
		if(annot != null)
		{
			var class = annot.value.get(0)
			return '''new «class»().postSelect((«me.fqBeanName»)modelSelect);'''	
		}
	}
}