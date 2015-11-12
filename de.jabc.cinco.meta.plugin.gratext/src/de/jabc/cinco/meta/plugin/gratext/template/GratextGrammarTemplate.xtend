package de.jabc.cinco.meta.plugin.gratext.template

import mgl.Edge
import mgl.Enumeration
import mgl.Node
import mgl.NodeContainer
import mgl.UserDefinedType
import mgl.Attribute
import mgl.ModelElement

class GratextGrammarTemplate extends AbstractGratextTemplate {


def modelRule() {
	val containables = model.nonAbstractContainables
	'''
	«model.name» returns «model.name»:{«model.name»}
	'«model.name»' (id = CincoID)?
	('{'
		«attributes(graphmodel)»
		«IF !containables.empty»
			( ( modelElements += «containables.get(0).name» )*
			«IF (containables.size > 1)»
				«FOR i:1..(containables.size-1)»
				& ( modelElements += «containables.get(i).name» )*
				«ENDFOR»
			«ENDIF»
			)
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
		«prime(node)»
		«IF !containables.empty»
			( ( modelElements += «containables.get(0).name» )*
			«IF (containables.size > 1)»
				«FOR i:1..(containables.size-1)»
				& ( modelElements += «containables.get(i).name» )*
				«ENDFOR»
			«ENDIF»
			)
		«ENDIF»
		«IF !outEdges.empty»
			( ( outgoingEdges += «outEdges.get(0).name» )*
			«IF (outEdges.size > 1)»
				«FOR i:1..(outEdges.size-1)»
				& ( outgoingEdges += «outEdges.get(i).name» )*
				«ENDFOR»
			«ENDIF»
			)
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
		«prime(node)»
		«IF !outEdges.empty»
			( ( outgoingEdges += «outEdges.get(0).name» )*
			«IF (outEdges.size > 1)»
				«FOR i:1..(outEdges.size-1)»
				& ( outgoingEdges += «outEdges.get(i).name» )*
				«ENDFOR»
			«ENDIF»
			)
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

def attributes(ModelElement element) {
	val attrs = model.resp(element).attributes
'''
	«IF !attrs.empty»
		( ( '«attrs.get(0).name»' «attrs.get(0).name» = «type(attrs.get(0))» )
		«IF (attrs.size > 1)»
			«FOR i:1..(attrs.size-1)»
			& ( '«attrs.get(i).name»' «attrs.get(i).name» = «type(attrs.get(i))» )
			«ENDFOR»
		«ENDIF» )?
	«ENDIF»
'''
}

def prime(Node node) {
	val ref = (node as Node).primeReference
	if (ref != null) {
		return '''( '«ref.name»' EString )'''
	}
}

override template()
'''	
grammar «project.basePackage».«project.targetName» with org.eclipse.xtext.common.Terminals
	
import "«graphmodel.nsURI»/«project.acronym»"
import "«graphmodel.nsURI»" as «model.acronym»
import "http://www.jabc.de/cinco/gdl/graphmodel" as graphmodel
import "http://www.eclipse.org/emf/2002/Ecore" as ecore

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

CincoID: ID ('-' ID)*;

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
'''
}