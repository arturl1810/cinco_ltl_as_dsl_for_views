package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Map.Entry
import mgl.Attribute
import mgl.Edge
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.Type
import mgl.UserDefinedType

import static extension de.jabc.cinco.meta.core.utils.CincoUtils.*
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.BasicEList
import mgl.ReferencedEClass
import mgl.ReferencedType
import mgl.ReferencedModelElement
import org.eclipse.emf.ecore.EClass

class GeneratorUtils {
	val static String ID_CONTAINER = "Containers";
	val static String ID_NODES = "Nodes";
	
	
	def instanceofCheck(ModelElement me, String varName) 
	'''«varName» instanceof «me.beanPackage».«me.fuName»'''
		
	static def fuName(Type t) {
		t.name.toFirstUpper
	}
	
	static def fuName(ModelElement me) {
		me.name.toFirstUpper
	}
	
	static def flName(ModelElement me) {
		me.name.toFirstLower
	}
	
	static def packageName(GraphModel gm)
	'''«gm.package».editor.graphiti'''
	
	def packageNameExpression(GraphModel gm)
	'''«gm.package».editor.graphiti.expression'''
	
	def packageNameAdd(ModelElement me)
	'''«me.graphModel.package».features.add'''
	
	def packageNameCreate(ModelElement me)
	'''«me.graphModel.package».features.create'''
	
	def packageNameDelete(ModelElement me)
	'''«me.graphModel.package».features.delete'''
	
	def packageNameLayout(ModelElement me)
	'''«me.graphModel.package».features.layout'''
	
	def packageNameResize(ModelElement me)
	'''«me.graphModel.package».features.resize'''
	
	def packageNameMove(ModelElement me)
	'''«me.graphModel.package».features.move'''
	
	def packageNameUpdate(ModelElement me)
	'''«me.graphModel.package».features.update'''
	
	def beanPackage(ModelElement me)
	'''«IF me instanceof UserDefinedType»«var gm = me.eContainer as GraphModel»«gm.package».«gm.name.toLowerCase»
		«ELSE»
		«me.graphModel.package».«me.graphModel.name.toLowerCase»«ENDIF»''' 
	
	def fqBeanName(ModelElement me)
	'''«me.beanPackage».«me.fuName»'''
	
	def fqFactoryName(ModelElement me) 
	'''«me.graphModel.package».«me.graphModel.name.toLowerCase».«me.graphModel.name.toLowerCase.toFirstUpper»Factory'''
	
	def fqPropertyView(ModelElement me) 
	'''«me.graphModel.packageName».property.view.«me.graphModel.fuName»PropertyView'''
	def modelElements(GraphModel gm) {
		var List<ModelElement> mes = new ArrayList<ModelElement>;
		mes.addAll(gm.nodes)
		mes.addAll(gm.edges)
		return mes
	}
	 
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
	
	def firstUpperOnly(ModelElement me)
	'''«me.name.toLowerCase.toFirstUpper»'''
	
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
		var EList <mgl.Annotation> annots = n.annotations;
		for (annot : annots){
			if(annot.name.equals("icon")){
				icon = annot.value.get(0);
			}
		}
		return icon;		
	}
	
	def isPrime(mgl.Node n)
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
}