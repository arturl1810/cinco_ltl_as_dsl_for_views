package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

import java.util.Set

abstract class AbstractBasicCheckableNode<E> {
	protected val String id
	protected var boolean isStartNode
	protected val Set<E> incoming
	protected val Set<E> outgoing
	protected val Set<String> atomicPropositions
	
	
	new (String id, boolean isStartNode, Set<String> atomicPropositions){
		this.atomicPropositions = newHashSet
		this.incoming = newHashSet
		this.outgoing = newHashSet
		this.id = id
		this.isStartNode = isStartNode
		addAtomicPropositions(atomicPropositions)
	}
	
	def addAtomicPropositions(String atomicPropositions){
		if (atomicPropositions !== null){
			for (ap : atomicPropositions.replaceAll(" ","").split(",")){
				this.atomicPropositions.add(ap)
			}
		}
	}
	
	def addAtomicPropositions(Set<String> atomicPropositions){
		if (atomicPropositions !== null){
			for (ap : atomicPropositions){
				addAtomicPropositions(ap)
			}
		}
	}
	
	def getId() {id}
	def isStartNode() {isStartNode}
	def getAtomicPropositions() {atomicPropositions}
	def getIncoming() {incoming}
	def getOutgoing() {outgoing}
	
	def setIsStartNode(boolean isStartNode){
		this.isStartNode = isStartNode
	}
	
	def addIncoming(E edge){
		this.incoming.add(edge)
	}
	
	def addOutgoing(E edge){
		this.outgoing.add(edge)
	}
}