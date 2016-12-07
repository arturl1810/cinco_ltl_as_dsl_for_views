package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.capi.generator.templates.NodeTemplate
import graphicalgraphmodel.impl.CContainerImpl
import graphicalgraphmodel.impl.CNodeImpl
import mgl.Node
import mgl.NodeContainer

public class Node_MainTemplate extends NodeTemplate {
	
	Node n
	
	new (Node node) {
		super(node)
		n = node
	}
	   
def create() 
'''package «packageName».newcapi;

«IF n instanceof NodeContainer»
public class C«fuMEName» extends «IF (n.extends == null)»«CContainerImpl.name»«ELSE»«n.extends.fqcn»«ENDIF»{
«ELSE»
public class C«fuMEName» extends «IF (n.extends == null)»«CNodeImpl.name»«ELSE»«n.extends.fqcn»«ENDIF»{
«ENDIF»

	«n.incomingEdgesGetter»
	
	«n.outgoingEdgesGetter»
	
	«n.attributeGetter»
	
	«n.attributeSetter»
	
	«n.viewGetter»
	
«««	«FOR c : n.possibleContainers»
«««		«n.moveToMethod(c)»
«««		
«««		«n.cloneMethod(c)»
«««	«ENDFOR»
«««	
«««	«FOR out : n.outgoingConnectingEdges»
«««		«out.newEdgeMethod(n)»
«««	«ENDFOR»
«««	
«««	«IF n instanceof NodeContainer»
«««		«val nc = n as NodeContainer»
«««		«FOR posNode : nc.getContainableNodes»
«««			«nc.newNodeMethod(posNode)»
«««		«ENDFOR»
«««	«ENDIF»
«««	
«««	
}'''

}
