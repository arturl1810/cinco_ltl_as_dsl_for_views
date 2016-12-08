package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import java.util.List
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer

class NodeTemplate extends ModelElementTemplate {
	
	new(ModelElement me) {
		super(me)
	}
	
	def outgoingEdgesGetter(Node n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.name»> getOutgoing«e.name.toFirstUpper» () {
		return getOutgoing(«e.name.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def outgoingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.name»> getOutgoing«e.name.toFirstUpper» () {
		return getOutgoing(«e.name.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(Node n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.name»> getIncoming«e.name.toFirstUpper» () {
		return getIncoming(«e.name.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.name»> getIncoming«e.name.toFirstUpper» () {
		return getIncoming(«e.name.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	
}
