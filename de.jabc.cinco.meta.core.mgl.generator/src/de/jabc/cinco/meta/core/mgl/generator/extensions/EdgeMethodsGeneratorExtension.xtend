package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.mgl.generator.elements.ElementEClasses
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.util.HashMap
import mgl.Edge

import static extension de.jabc.cinco.meta.core.mgl.generator.extensions.EcoreExtensions.*
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*
import mgl.Node
import org.eclipse.emf.ecore.EcorePackage

class EdgeMethodsGeneratorExtension extends GeneratorUtils {
	
	static def createCanReconnectMethods(Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val sources = edge.possibleSources
		val targets = edge.possibleTargets
		
		sources.forEach[createCanReconnectSourceMethods(edge, elemClasses)]
		targets.forEach[createCanReconnectTargetMethods(edge, elemClasses)]
	}
	
	static def createReconnectMethods(Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val sources = edge.possibleSources
		val targets = edge.possibleTargets
		
		sources.forEach[createReconnectSourceMethods(edge, elemClasses)]
		targets.forEach[createReconnectTargetMethods(edge, elemClasses)]
	}
	
	
	static def createCanReconnectSourceMethods(Node source, Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val edgeEClass = elemClasses.get(edge.name).mainEClass
		val sourceEClass = elemClasses.get(source.name).mainEClass
		
		edgeEClass.createEOperation("canReconnectSource", 
			EcorePackage.eINSTANCE.EBoolean,
			1,
			1,
			edge.canReconnectSourceMethodContent(source),
			createEParameter(sourceEClass,"source",1,1)
		)
	}
	
	
	static def createReconnectSourceMethods(Node source, Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val edgeEClass = elemClasses.get(edge.name).mainEClass
		val sourceEClass = elemClasses.get(source.name).mainEClass
		
		edgeEClass.createEOperation("reconnectSource", null,1,1,edge.reconnectSourceMethodContent(source),createEParameter(sourceEClass,"source",1,1))
	}
	
	static def canReconnectSourceMethodContent(Edge e, Node s) '''
		return source.canStart(this.getClass());
	'''
	
	static def reconnectSourceMethodContent(Edge e, Node n) '''
		this.setSourceElement(source);
	'''
	
	static def createCanReconnectTargetMethods(Node target, Edge edge, HashMap<String, ElementEClasses> elemClasses) {
		val edgeEClass = elemClasses.get(edge.name).mainEClass
		val targetEClass = elemClasses.get(target.name).mainEClass
		
		edgeEClass.createEOperation("canReconnectTarget",
			EcorePackage.eINSTANCE.EBoolean,
			1,
			1,
			edge.canReconnectTargetMethodContent(target),
			createEParameter(targetEClass,"target",1,1)
		)
	}
	
	static def canReconnectTargetMethodContent(Edge edge, Node n) '''
		return target.canEnd(this.getClass());
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