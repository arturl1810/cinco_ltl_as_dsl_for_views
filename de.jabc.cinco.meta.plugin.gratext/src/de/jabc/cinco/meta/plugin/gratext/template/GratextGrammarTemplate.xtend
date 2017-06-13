package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.GratextGenerator
import java.util.HashMap
import java.util.Map
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.PrimitiveAttribute
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
		Node: 		obj.acronym -> obj.graphModel.nsURI
		Edge:		obj.acronym -> obj.graphModel.nsURI
		EClass:		obj.EPackage.acronym -> obj.EPackage.nsURI
	}
	if (!graphmodel.nsURI.equals(entry.value)) {
		references.put(entry.key, entry.value)
		(ctx as GratextGenerator).addGenPackageReference(entry.value);
	}
}

def String acronym(EObject obj) {
	switch obj {
		GraphModel:	obj.name.toLowerCase
		ENamedElement:	obj.name
	}
}

def modelRule() {
	val containables = model.nonAbstractContainables
	'''
	«model.name» returns «model.name»:{«model.name»}
	'«model.name»' (id = _ID)?
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
	val outEdges = model.resp(node).nonAbstractOutgoingEdges
	val containables = model.resp(node).nonAbstractContainables
	'''
	«node.name» returns «node.name»:{«node.name»}
	'«node.name»' (id = _ID)? ( ('at' x=_EInt ',' y=_EInt)?
			& ('size' width=_EInt ',' height=_EInt)?
			& ('index' index=_EInt)? 
			)
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
	val outEdges = model.resp(node).nonAbstractOutgoingEdges
	'''
	«node.name» returns «node.name»:{«node.name»}
	'«node.name»' (id = _ID)? ( ('at' x=_EInt ',' y=_EInt)?
		& ('size' width=_EInt ',' height=_EInt)?
		& ('index' index=_EInt)? 
		)
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
	'-«edge.name»->' _targetElement = [_graphmodel::InternalNode|_ID]
	('via' (bendpoints += _Point)+)?
	(decorators += _Decoration)*
	('{'
		('id' id = _ID)?
		«attributes(edge)»
	'}')?
	;
	'''
}

def typeRule(UserDefinedType type) {
	'''
	«type.name» returns «type.name»:{«type.name»}
	'«type.name»' (id = _ID)? '{'
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
	switch attr {
		PrimitiveAttribute:
			'''_«attr.type.literal»'''
		ComplexAttribute:
			if (model.containsEnumeration(attr.type.name) || model.containsUserDefinedType(attr.type.name)) {
				attr.type.name
			} else if (model.contains(attr.type.name)) {
				'''[«attr.type.name»|_ID]'''
			}
	}
}

def type(ReferencedType ref) {
	val type = switch ref {
	 	ReferencedModelElement: ref.type
	 	ReferencedEClass: ref.type
	}
	if (type != null) {
		val entry = switch type {
			GraphModel: type.acronym -> type.name
			Node: 		type.graphModel.acronym -> type.name
			Edge: 		type.graphModel.acronym -> type.name
			EClass: 	type.EPackage.acronym -> type.name
		}
		'''[«entry.key»::«entry.value»|_ID]'''
	}
}

def attributes(ModelElement elm) {
	val attrs = model.resp(elm).attributes
	val attrsStr = attrs.map[switch it {
		case (upperBound < 0) || (upperBound > 1): '''( '«it.name»' '[' ( ^«it.name» += «type(it)» ( ',' ^«it.name» += «type(it)» )* )? ']' )?'''
		default: '''( '«it.name»' ^«it.name» = «type(it)» )?'''
	}].join(' &\n')
	val primeStr = switch elm {
		Node: elm.prime
	}
	if (attrs.empty) primeStr
	else if (primeStr != null) "( " + primeStr + ' &\n' + attrsStr + " )"
	else "( " + attrsStr + " )"
}

def prime(Node node) {
	val ref = model.resp(node).primeReference
	if (ref != null) {
		'''( '«ref.name»' prime = «ref.type» | 'libraryComponentUID' libraryComponentUID = _STRING )'''
	}
}

def imports() {
'''
import "«graphmodel.nsURI»/«project.acronym»"
import "«graphmodel.nsURI»" as «model.acronym»
«««import "«graphmodel.nsURI»/internal" as «model.acronym»Internal
«references.entrySet.map['''import "«it.value»" as «it.key»'''].join('\n')»
import "http://www.jabc.de/cinco/gdl/graphmodel/internal" as _graphmodel
import "http://www.eclipse.org/emf/2002/Ecore" as _ecore
'''	
}

override template()
'''	
grammar «project.basePackage».«project.targetName» hidden(_WS, _ML_COMMENT, _SL_COMMENT)

«imports»

«modelRule»

«FOR node:model.nonAbstractContainers»«containerRule(node)»«ENDFOR»

«FOR node:model.nonAbstractNonContainerNodes»«nodeRule(node)»«ENDFOR»

«FOR edge:model.nonAbstractEdges»«edgeRule(edge)»«ENDFOR»

«FOR type:model.userDefinedTypes»«typeRule(type)»«ENDFOR»

«FOR type:model.enumerations»«enumRule(type)»«ENDFOR»

«««_Placement :
«««	( ('at' x=_EInt ',' y=_EInt)?
«««	& ('size' width=_EInt ',' height=_EInt)?
«««	& ('index' index=_EInt)? )
«««;

_Decoration returns _graphmodel::_Decoration:{_graphmodel::_Decoration}
	'decorate' (nameHint = _EString)? 'at' locationShift = _Point
;

«««_Route returns _Route:{_Route}
«««	'via' (points += _Point)+
«««;

_Point returns _graphmodel::_Point:{_graphmodel::_Point}
	'(' x = _EInt ',' y = _EInt ')'
;

_EString returns _ecore::EString:
	_STRING;

_EInt returns _ecore::EInt:
	_SIGN? _INT
;

_ELong returns _ecore::ELong:
	_SIGN? _INT
;

_EFloat returns _ecore::EFloat:
	_SIGN? _INT? '.' _INT
;

_EDouble returns _ecore::EDouble:
	_SIGN? _INT? '.' _INT
;

_EFloat returns _ecore::EFloat:
	_SIGN? _INT? '.' _INT
;

_EBoolean returns _ecore::EBoolean:
	'true' | 'false'
;

terminal _ID : '^'?('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'-'|'0'..'9')* ;

terminal _SIGN : '+' | '-' ;

terminal _INT returns _ecore::EInt: ('0'..'9')+ ;

terminal _STRING	: 
			'"' ( '\\' . /* 'b'|'t'|'n'|'f'|'r'|'u'|'"'|"'"|'\\' */ | !('\\'|'"') )* '"' |
			"'" ( '\\' . /* 'b'|'t'|'n'|'f'|'r'|'u'|'"'|"'"|'\\' */ | !('\\'|"'") )* "'"
		; 
terminal _ML_COMMENT	: '/*' -> '*/' ;
terminal _SL_COMMENT 	: '//' !('\n'|'\r')* ('\r'? '\n')? ;

terminal _WS			: (' '|'\t'|'\r'|'\n')+ ;

terminal _ANY_OTHER: . ;
'''
}