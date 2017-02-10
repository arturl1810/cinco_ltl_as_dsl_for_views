package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.util.HashMap
import mgl.Edge

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.utils.MGLUtils.*
import mgl.Node

class EdgeMethodsGeneratorExtension extends GeneratorUtils {
	
	static def createReconnectMethods(Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val sources = edge.possibleSources
		val targets = edge.possibleTargets
		
		sources.forEach[createReconnectSourceMethods(edge, elemClasses)]
		targets.forEach[createReconnectTargetMethods(edge, elemClasses)]
	}
	
	static def createReconnectSourceMethods(Node source, Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val edgeEClass = elemClasses.get(edge.name).mainEClass
		val sourceEClass = elemClasses.get(source.name).mainEClass
		
		edgeEClass.createEOperation("reconnectSource", null,1,1,edge.reconnectSourceMethodContent(source),createEParameter(sourceEClass,"source",1,1))
	}
	
	static def reconnectSourceMethodContent(Edge e, Node n) '''
		this.setSourceElement(source);
	'''
	
	static def createReconnectTargetMethods(Node target, Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val edgeEClass = elemClasses.get(edge.name).mainEClass
		val targetEClass = elemClasses.get(target.name).mainEClass
		
		edgeEClass.createEOperation("reconnectTarget", null,1,1,edge.reconnectTargetMethodContent(target),createEParameter(targetEClass,"target",1,1))
	}
	
	static def reconnectTargetMethodContent(Edge e, Node n) '''
		this.setTargetElement(target);
	'''
}