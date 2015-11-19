package de.jabc.cinco.meta.plugin.gratext.template

import java.util.HashMap
import java.util.Map
import mgl.Attribute
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.ReferencedEClass
import mgl.ReferencedModelElement
import mgl.ReferencedType
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.ENamedElement
import org.eclipse.emf.ecore.EObject

class GratextGrammarTemplate extends AbstractGratextTemplate {

Map<String,String> references

override init() {
	references = new HashMap
	model.nodes.map[it.primeReference]
		.filter[it != null]
		.forEach[initReferences]
}

def initReferences(ReferencedType reftype) {
	switch reftype {
		ReferencedModelElement: reftype.type
		ReferencedEClass:		reftype.type
	}.addToReferences
}

def addToReferences(EObject obj) {
	val entry = switch obj {
		GraphModel: obj.acronym -> obj.nsURI
		Node: 		obj.graphModel.acronym -> obj.graphModel.nsURI
		EClass:		obj.EPackage.acronym -> obj.EPackage.nsURI
	}
	if (!graphmodel.nsURI.equals(entry.value)) {
		references.put(entry.key, entry.value)
		ctx.addGenPackageReference(entry.value);
	}
}

def String acronym(EObject obj) {
	switch obj {
		GraphModel:	obj.fileExtension
		ENamedElement:	obj.name
	}
}

def modelRule() {
	val containables = model.nonAbstractContainables
	'''
	«model.name» returns «model.name»:{«model.name»}
	'«model.name»' (id = CincoID)?
	('{'
		«attributes(graphmodel)»
		«IF !containables.empty»
			( modelElements += «containables.get(0).name»
			«IF (containables.size > 1)»
				«FOR i:1..(containables.size-1)»
				| modelElements += «containables.get(i).name»
				«ENDFOR»
			«ENDIF»
			)*
		«ENDIF»
	'}')?
	;
	'''
}


def containerRule(NodeContainer node) {
	val outEdges = model.resp(node).outgoingEdges
	val containables = model.resp(node).nonAbstractContainables
	'''
	«node.name» returns «node.name»:{«node.name»}
	'«node.name»' (id = CincoID)? placement = Placement
	('{'
		«attributes(node)»
		«IF !containables.empty»
			( modelElements += «containables.get(0).name»
			«IF (containables.size > 1)»
				«FOR i:1..(containables.size-1)»
				| modelElements += «containables.get(i).name»
				«ENDFOR»
			«ENDIF»
			)*
		«ENDIF»
		«IF !outEdges.empty»
			( outgoingEdges += «outEdges.get(0).name»
			«IF (outEdges.size > 1)»
				«FOR i:1..(outEdges.size-1)»
				| outgoingEdges += «outEdges.get(i).name»
				«ENDFOR»
			«ENDIF»
			)*
		«ENDIF»
	'}')?
	;
	'''
}


def nodeRule(Node node) {
	val outEdges = model.resp(node).outgoingEdges
	'''
	«node.name» returns «node.name»:{«node.name»}
	'«node.name»' (id = CincoID)? placement = Placement
	('{'
		«attributes(node)»
		«IF !outEdges.empty»
			( outgoingEdges += «outEdges.get(0).name»
			«IF (outEdges.size > 1)»
				«FOR i:1..(outEdges.size-1)»
				| outgoingEdges += «outEdges.get(i).name»
				«ENDFOR»
			«ENDIF»
			)*
		«ENDIF»
	'}')?
	;
	'''
}

def edgeRule(Edge edge) {
	'''
	«edge.name» returns «edge.name»:{«edge.name»}
	'-«edge.name»->' targetElement = [graphmodel::Node|CincoID]
	(route = Route)?
	('{'
		('id' id = CincoID)?
		«attributes(edge)»
	'}')?
	;
	'''
}

def typeRule(UserDefinedType type) {
	'''
	«type.name» returns «model.acronym»::«type.name»:{«model.acronym»::«type.name»}
	«attributes(type)»
	;
	'''
}

def enumRule(Enumeration type) {
	'''
	enum «type.name» returns «model.acronym»::«type.name»: 
		«type.literals.get(0)»
		«IF (type.literals.size > 1)»
			«FOR i:1..(type.literals.size-1)»
			| «type.literals.get(i)»
			«ENDFOR»
		«ENDIF»
	;
	'''
}
	
def type(Attribute attr) {
	if (model.contains(attr.type))
		'''[«model.acronym»::«attr.type»|CincoID]'''
	else attr.type
}

def type(ReferencedType ref) {
	val type = switch ref {
	 	ReferencedModelElement: ref.type
	 	ReferencedEClass: ref.type
	}
	if (type != null) {
		val entry = switch type {
			GraphModel: type.acronym -> type.name
			Node: 		type.graphModel.acronym -> type.graphModel.name
			EClass: 	type.EPackage.acronym -> type.name
		}
		println(" > Type: " + entry)
		'''[«entry.key»::«entry.value»|CincoID]'''
	}
}

def attributes(ModelElement elm) {
	val attrs = model.resp(elm).attributes
	val attrsStr = attrs.map['''( '«it.name»' «it.name» = «type(it)» )?'''].join(' &\n')
	val primeStr = switch elm {
		Node: elm.prime
	}
	if (attrs.empty) primeStr
	else if (primeStr != null) "( " + primeStr + ' &\n' + attrsStr + " )"
	else "( " + attrsStr + " )"
}

def prime(Node node) {
	val ref = node.primeReference
	if (ref != null) {
		println(node.name + ".prime: " + ref)
		'''( '«ref.name»' prime = «ref.type» | '«ref.name»UID' «ref.name»UID = EString )'''
	}
}

def imports() {
'''
import "«graphmodel.nsURI»/«project.acronym»"
import "«graphmodel.nsURI»" as «model.acronym»
«references.entrySet.map['''import "«it.value»" as «it.key»'''].join('\n')»
import "http://www.jabc.de/cinco/gdl/graphmodel" as graphmodel
import "http://www.eclipse.org/emf/2002/Ecore" as ecore
'''	
}

override template()
'''	
grammar «project.basePackage».«project.targetName» with org.eclipse.xtext.common.Terminals

«imports»

«modelRule»

«FOR node:model.nonAbstractContainers»«containerRule(node)»«ENDFOR»

«FOR node:model.nonAbstractNonContainerNodes»«nodeRule(node)»«ENDFOR»

«FOR edge:model.nonAbstractEdges»«edgeRule(edge)»«ENDFOR»

«FOR type:model.types»«typeRule(type)»«ENDFOR»

«FOR type:model.enumerations»«enumRule(type)»«ENDFOR»

Placement returns _Placement:{_Placement}
	( ('at' x=EInt ',' y=EInt)?
	& ('size' width=EInt ',' height=EInt)? )
;

Route returns _Route:{_Route}
	'via' (points += Point)+
;

Point returns _Point:{_Point}
	'(' x = EInt ',' y = EInt ')'
;

CincoID: ID (IDPART)*;

EString returns ecore::EString:
	STRING | ID;

EInt returns ecore::EInt:
	INT
;

ELong returns ecore::ELong:
	SIGN? INT
;

EDouble returns ecore::EDouble:
	SIGN? INT? '.' INT
;

EBoolean returns ecore::EBoolean:
	'true' | 'false'
;

terminal SIGN : '+' | '-' ;

terminal IDPART: SIGN('a'..'z'|'A'..'Z'|'_'|'0'..'9')*;
'''
}