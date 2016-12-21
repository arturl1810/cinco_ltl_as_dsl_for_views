package de.jabc.cinco.meta.core.ge.style.generator.api.main

import de.jabc.cinco.meta.core.ge.style.generator.api.templates.NodeViewTemplate
import mgl.Node
import mgl.NodeContainer

public class NodeView_MainTemplate extends NodeViewTemplate{
	
	Node n
	
	new (Node node) {
		super(node)
		n = node
	}
	   
def doGenerate() 
'''package «packageName».api;

«IF n instanceof NodeContainer»
public class C«fuMEName»View {
«ELSE»
public class C«fuMEName»View {
«ENDIF»

	private «n.fqn» viewable;

	«n.incomingEdgesGetter»
	
	«n.outgoingEdgesGetter»
	
	«n.attributeGetter»
	
	«n.attributeSetter»
	
	«n.viewableGetter»
	
	«n.viewableSetter»
	
	«n.modelElementGetter»
	
	«n.featureProviderGetter»
	
	«n.diagramGetter»
	
	«n.canMoveToContainer»
	
	«n.moveToContainer»
	
	«FOR c : n.possibleContainers»
	«n.moveToMethod(c)»
		
«««	«n.cloneMethod(c)»
	«ENDFOR»
	
	«FOR out : n.outgoingConnectingEdges»
	«out.newEdgeMethod(n)»
	«ENDFOR»
	
	«IF n instanceof NodeContainer»
	«val nc = n as NodeContainer»
	«FOR posNode : nc.getContainableNodes»
	«nc.canNewMethod(posNode)»
	«nc.newNodeMethod(posNode)»
	«ENDFOR»
	«ENDIF»
}'''

}
