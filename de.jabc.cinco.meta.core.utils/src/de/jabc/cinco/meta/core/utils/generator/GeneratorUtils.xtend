package de.jabc.cinco.meta.core.utils.generator

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Map.Entry
import javax.el.ExpressionFactory
import mgl.Annotatable
import mgl.Annotation
import mgl.Attribute
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.Type
import mgl.UserDefinedType
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EPackage
import de.jabc.cinco.meta.core.utils.CincoUtils

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
	
	dispatch def fuCName(Type me) {
		"C"+me.name.toFirstUpper
	}
	
	dispatch def fuCName(ContainingElement me) {
		switch(me){
		NodeContainer: "C"+me.name.toFirstUpper
		GraphModel:  "C"+me.name.toFirstUpper
		}
	}
	
	def fuCImplName(Type me) {
		"C"+me.name.toFirstUpper+"Impl"
	}
	
	/**
	 * Returns the {@link ModelElement}'s name in first lower
	 */
	def flName(ModelElement me) {
		me.name.toFirstLower
	}
	
	def fuInternalName(ModelElement me) {
		"Internal"+me.name.toFirstUpper
	}
	

	
	
	/**
	 * Returns the package name prefix for the generated graphiti sources.
	 * 
	 * @param gm The processed {@link GraphModel}
	 */
	def packageName(GraphModel gm)
	'''«gm.package».editor.graphiti'''
	
	def packageNameAPI(GraphModel gm)
	'''«gm.packageName».api'''
	
	/**
	 * Returns the package name prefix for the generated graphiti sources.
	 * 
	 * @param me The processed {@link ModelElement}
	 */
	def packageName(ModelElement me)
	'''«me.graphModel.packageName»'''
	
	def packageNameAPI(ModelElement me)
	'''«me.graphModel.packageName».api'''
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
	'''«me.graphModel.packageName».features.add'''
	
	/**
	 * Returns the package name for the generated {@link ICreateFeature} implementing classes
	 */
	def packageNameCreate(ModelElement me)
	'''«me.graphModel.packageName».features.create'''
	
	/**
	 * Returns the package name for the generated {@link IDeleteFeature} implementing classes
	 */
	def packageNameDelete(ModelElement me)
	'''«me.graphModel.packageName».features.delete'''
	
	/**
	 * Returns the package name for the generated {@link ILayoutFeature} implementing classes
	 */
	def packageNameLayout(ModelElement me)
	'''«me.graphModel.packageName».features.layout'''
	
	/**
	 * Returns the package name for the generated {@link IResizeFeature} implementing classes
	 */
	def packageNameResize(ModelElement me)
	'''«me.graphModel.packageName».features.resize'''
	
	/**
	 * Returns the package name for the generated {@link IMoveFeature} implementing classes
	 */
	def packageNameMove(ModelElement me)
	'''«me.graphModel.packageName».features.move'''
	
	/**
	 * Returns the package name for the generated {@link IUpdateFeature} implementing classes
	 */
	def packageNameUpdate(ModelElement me)
	'''«me.graphModel.packageName».features.update'''
	
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
	
	def fqBeanImplName(ModelElement me)
	'''«me.beanPackage».impl.«me.fuName»Impl'''
	
	/**
	 * Returns the fully qualified name of the {@link EFactory} class for the given {@link ModelElement}, i.e. for the
	 * {@link ModelElement}'s {@link GraphModel}. 
	 */
	def fqFactoryName(ModelElement me) 
	'''«me.graphModel.package».«me.graphModel.name.toLowerCase».«me.graphModel.name.toLowerCase.toFirstUpper»Factory'''
	
	def fqCreateFeatureName(ModelElement me)
	'''«me.packageNameCreate».CreateFeature«me.fuName»'''
	
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
	
	def getExtends(ModelElement me) {
		switch (me) {
			Node : me.extends
			Edge : me.extends
			GraphModel : me.extends
			default : null
		}
	}
	
	def superClass(ModelElement me) {
		switch (me) {
			NodeContainer : '''«CContainer.name»'''
			Node : '''«CNode.name»'''
			Edge : '''«CEdge.name»'''
			GraphModel : '''«CGraphModel.name»'''
		}
	}
	
	/**
	 * Returns the {@link ModelElement}'s name. All letters except for the first letter are in lower case
	 * 
	 * @param The {@link ModelElement}
	 */
	def firstUpperOnly(ModelElement me)
	'''«me.name.toLowerCase.toFirstUpper»'''
	
	/** 
	 * Returns the fully qualified name of the {@link Entry} class
	 */
	def entryName(Class<Entry> e) '''java.util.Map.Entry'''
	
	
	/**
	 * Returns a map of palette group names to a list of {@link GraphicalModelElement}s. The map is used to
	 * create the appropriate palette groups and the corresponding create tools
	 * 
	 * @param gm The processes {@link GraphModel}
	 */
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
	
	/**
	 * Adds a {@link ModelElement} to the list of the corresponding palette group.
	 * 
	 * @param m The map holding the palette group name to {@link GraphicalModelElement} list mapping
	 * @param paletteName The palette group name the {@link GraphicalModelElement} should be added
	 * @param me The {@link GraphicalModelElement} that should be added into the given palette group
	 */
	def addToMap(Map<String, List<GraphicalModelElement>> m, String paletteName, GraphicalModelElement me) {
		if (m.get(paletteName) == null)
			m.put(paletteName, new ArrayList)
		m.get(paletteName).add(me)
	}
	
	/**
	 * Checks if the given {@link ModelElement} contains a palette annotation
	 * 
	 * @param me The processed {@link ModelElement}
	 * @return true if the {@link ModelElement} contains a palette annotation
	 */
	def hasPaletteCategory(ModelElement me) {
		me.annotations.filter[a | a.name.equals("palette")].size > 0
	}
	
	/**
	 * @param gm The processed {@link GraphModel}
	 * @return All {@link mgl.Attributes} (including {@link Node}, 
	 * {@link Edge}, {@link mgl.Container}, and {@link GraphModel})
	 * used in the definition of the given {@link GraphModel}.
	 */
	def allModelAttributes(GraphModel gm) {
		gm.eResource.allContents.toIterable.filter[c | c instanceof Attribute].map[a | a as Attribute]
	}
	
	/**
	 * @param n The processed {@link Node}
	 * @return The {@link String} value of the {@link Node}'s "icon" annotation 
	 * and the empty {@link String} if no icon annotation provided  
	 */
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
	
	/**
	 * @param n The processed {@link Node}
	 * @return True, if the given node is a primeNode
	 */
	def isPrime(Node n)
	{
		if(n.primeReference != null)
			return true
		return false;
	}

	/**
	 * @param rme The {@link ReferencedModelElement} of a prime node. 
	 * @return The name of the prime reference's type
	 */
	dispatch def primeType(ReferencedModelElement rme) {
		return rme.type.name
	}
	
	/**
	 * @param The {@link ReferencedEClass} of a prime node
	 * @return The name of the prime reference's type
	 */
	dispatch def primeType(ReferencedEClass rec) {
		return rec.type.name
	}
	
	/**
	 * @param The processed {@link Node}
	 * @return The {@link Node}'s prime reference name
	 */
	def primeName(Node n)
	{
		return n.primeReference.name
	}
	
	/**
	 * This method retrieves the {@link GraphModel} of the {@link ReferencedModelElement}'s type
	 * and returns its nsUri {@see GraphModel}
	 * 
	 * @param rem The {@link ReferencedModelElement} of a prime node
	 * @return The {@link GraphModel#getNsURI nsURI} of the {@link ReferencedModelElement}'s {@link GraphModel}
	 */
	dispatch def nsURI(ReferencedModelElement rem) {
		return rem.type.graphModel.nsURI
	}
	
	/**
	 * This method retrieves the {@link EPackage} of the {@link ReferencedEClass}' type
	 * and returns its {@link EPackage#getNsURI nsURI}.
	 * 
	 * @param refEClass The prime referenced {@link EClass}
	 * @param The {@link EPackage#getNsURI nsURI} of the given {@link EClass}
	 */
	dispatch def nsURI(ReferencedEClass refEClass) {
		return refEClass.type.EPackage.nsURI
	}
	
	/**
	 * @param n The processed {@link Node}
	 * @return The name of the (additional) {@link IAddFeature} for a prime node
	 */
	def addFeaturePrimeCode(Node n) '''
	new AddFeaturePrime«n.fuName»(this),
	'''
	
	/**
	 *  Checks if a postCreateHook is annotated at the {@link ModelElement}
	 * 
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	 * @param me The processed {@link ModelElement} 
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
	
	def fqInternalName(mgl.ModelElement me) {
		'''«me.beanPackage».internal.«me.fuInternalName»'''
	}
	

}