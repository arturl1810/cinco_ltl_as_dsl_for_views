package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import java.util.List
import mgl.Edge
import mgl.ModelElement
import mgl.Node
import org.eclipse.graphiti.features.context.impl.CreateConnectionContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.ui.services.GraphitiUi
import mgl.NodeContainer
import org.eclipse.graphiti.features.context.impl.CreateContext
import mgl.ContainingElement

class NodeTemplate extends de.jabc.cinco.meta.core.capi.generator.templates.ModelElementTemplate {
	
	new(ModelElement me) {
		super(me)
	}
	
	def outgoingEdgesGetter(Node n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.getCName»> getOutgoing«e.getCName.toFirstUpper» () {
		return getOutgoing(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def outgoingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.outgoingConnectingEdges»
	public «List.name»<«e.getCName»> getOutgoing«e.getCName.toFirstUpper» () {
		return getOutgoing(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(Node n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.getCName»> getIncoming«e.getCName.toFirstUpper» () {
		return getIncoming(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	def incomingEdgesGetter(NodeContainer n) 
	'''«FOR e : n.incomingConnectingEdges»
	public «List.name»<«e.getCName»> getIncoming«e.getCName.toFirstUpper» () {
		return getIncoming(«e.getCName.toFirstUpper».class);
	}
	
	«ENDFOR»
	'''
	
	
}
