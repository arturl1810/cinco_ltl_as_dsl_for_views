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
import de.jabc.cinco.meta.plugin.gratext.GratextProjectGenerator

class GratextGrammarTemplate extends AbstractGratextTemplate {

Map<String,String> references

override init() {
	references = new HashMap
	model.nodes.map[primeReference]
		.filterNull
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
		(ctx as GratextProjectGenerator).addGenPackageReference(entry.value);
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
	'«model.name»' (id = ID)?
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
	'«node.name»' (id = ID)? placement = Placement
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
	'«node.name»' (id = ID)? placement = Placement
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
	'-«edge.name»->' targetElement = [graphmodel::Node|ID]
	(route = Route)?
	(decorations += Decoration)*
	('{'
		('id' id = ID)?
		«attributes(edge)»
	'}')?
	;
	'''
}

def typeRule(UserDefinedType type) {
	'''
	«type.name» returns «model.acronym»::«type.name»:{«model.acronym»::«type.name»}
	'«type.name»' '{'
		«attributes(type)»
	'}'
	;
	'''
}

def enumRule(Enumeration type) {
	'''
	enum «type.name» returns «model.acronym»::«type.name»: 
		«type.literals.map(literal | '''^«literal»''').join(' | ')»
	;
	'''
}
	
def type(Attribute attr) {
	if (model.contains(attr.type)) {
		if (model.containsEnumeration(attr.type) || model.containsUserDefinedType(attr.type))
			attr.type
		else '''[«model.acronym»::«attr.type»|ID]'''
	} else attr.type
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
//		println(" > Type: " + entry)
		'''[«entry.key»::«entry.value»|ID]'''
	}
}

def attributes(ModelElement elm) {
	val attrs = model.resp(elm).attributes
	val attrsStr = attrs.map[switch it {
		case (upperBound < 0) || (upperBound > 1): '''( '«it.name»' '[' ( «it.name» += «type(it)» ( ',' «it.name» += «type(it)» )* )? ']' )?'''
		default: '''( '«it.name»' «it.name» = «type(it)» )?'''
	}].join(' &\n')
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
//		println(node.name + ".prime: " + ref)
		'''( '«ref.name»' prime = «ref.type» | 'libraryComponentUID' libraryComponentUID = EString )'''
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

«FOR type:model.userDefinedTypes»«typeRule(type)»«ENDFOR»

«FOR type:model.enumerations»«enumRule(type)»«ENDFOR»

Placement returns _Placement:{_Placement}
	( ('at' x=EInt ',' y=EInt)?
	& ('size' width=EInt ',' height=EInt)? )
;

Decoration returns _Decoration:{_Decoration}
	'decorate' (namehint = EString)? 'at' location = Point
;

Route returns _Route:{_Route}
	'via' (points += Point)+
;

Point returns _Point:{_Point}
	'(' x = EInt ',' y = EInt ')'
;

EString returns ecore::EString:
	STRING;

EInt returns ecore::EInt:
	SIGN? INT
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

terminal ID: '^'?('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'-'|'0'..'9')*;

terminal SIGN : '+' | '-' ;
'''
}