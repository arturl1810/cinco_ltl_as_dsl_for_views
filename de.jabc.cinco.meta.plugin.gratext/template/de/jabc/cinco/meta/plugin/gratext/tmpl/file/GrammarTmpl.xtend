package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate
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
import mgl.ReferencedType
import mgl.UserDefinedType
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EClassifier

class GrammarTmpl extends FileTemplate {
	
	val Map<String, String> importMappings = newHashMap
	
	override getTargetFileName() '''«model.name»Gratext.xtext'''
	
	override init() {
		model.primeReferences.map[switch it:type {
			GraphModel: name.toLowerCase -> nsURI
			ModelElement: graphModel.name.toLowerCase -> graphModel.nsURI
			EClassifier: EPackage.name -> EPackage.nsURI
		}].filter[key != null]
			.filter[value != model.nsURI && key != "ecore"]
			.forEach[importMappings.add(it)]
	}
	
	def modelRule() {
		val containables = model.containables.drop[isAbstract]
		'''
			«model.name» returns GratextInternal«model.name»:{GratextInternal«model.name»}
			'«model.name»' (id = _ID)?
			('{'
				«attributes(model)»
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
		val outEdges = node.outgoingEdges.drop[isAbstract]
		val containables = node.containables.drop[isAbstract]
		'''
			«node.name» returns GratextInternal«node.name»:{GratextInternal«node.name»}
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
		val outEdges = node.outgoingEdges.drop[isAbstract]
		'''
			«node.name» returns GratextInternal«node.name»:{GratextInternal«node.name»}
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

	def edgeRule(Edge edge) '''
		«edge.name» returns GratextInternal«edge.name»:{GratextInternal«edge.name»}
		'-«edge.name»->' _targetElement = [_graphmodel::InternalNode|_ID]
		('via' (bendpoints += _Point)+)?
		(decorators += _Decoration)*
		('{'
			('id' id = _ID)?
			«attributes(edge)»
		'}')?
		;
	'''

	def typeRule(UserDefinedType type) '''
		«type.name» returns GratextInternal«type.name»:{GratextInternal«type.name»}
		'«type.name»' (id = _ID)? '{'
			«attributes(type)»
		'}'
		;
	'''

	def enumRule(Enumeration type) '''
		enum «type.name» returns «model.name.toLowerCase»::«type.name»: 
			«type.literals.map(literal | '''^«literal»''').join(' | ')»
		;
	'''

	def typeReference(Attribute attr) {
		switch attr {
			PrimitiveAttribute: '''_«attr.type.literal»'''
			ComplexAttribute:
				if (model.containsEnumeration(attr.type.name) || model.containsUserDefinedType(attr.type.name)) {
					attr.type.name
				} else if (model.containsModelElement(attr.type.name)) {
					'''[«model.name.toLowerCase»::«attr.type.name»|_ID]'''
				}
		}
	}

	def typeReference(ReferencedType ref) {
		val type = ref.type
		if (type != null) {
			val entry = switch it:type {
				GraphModel: name.toLowerCase -> name
				ModelElement: graphModel.name.toLowerCase -> name
				EClass:{
					if (EPackage.name == "ecore")
						"_ecore" -> name
					else EPackage.name -> name
				}
			}
			'''[«entry.key»::«entry.value»|_ID]'''
		}
	}

	def gratextName(Attribute attr) {
		switch attr {
			ComplexAttribute:
				switch attr.type {
					UserDefinedType: '''gratext_«attr.name»'''
					default:
						attr.name
				}
			default:
				attr.name
		}
	}

	def attributes(ModelElement elm) {
		val sorted = cpd?.annotations?.exists[name == "sortGratext"]
		val attrs = if (sorted) elm.allAttributes.sortBy[name] else elm.allAttributes
		val attrSeparator = if (sorted) ' \n' else ' &\n'
		val attrsStr = attrs.map [
			switch it {
				case (upperBound < 0) || (upperBound > 1): '''( '«it.name»' '[' ( ^«gratextName» += «typeReference» ( ',' ^«gratextName» += «typeReference» )* )? ']' )?'''
				default: '''( '«name»' ^«gratextName» = «typeReference» )?'''
			}
		].join(attrSeparator)
		val primeStr = switch elm {
			Node: elm.prime
		}
		if (attrs.empty)
			primeStr
		else if (primeStr !== null)
			"( " + primeStr + attrSeparator + attrsStr + " )"
		else "( " + attrsStr + " )"
	}

	def prime(Node node) {
		val ref = node.anyPrimeReference
		if (ref != null)
			'''( '«ref.name»' prime = «ref.typeReference» | 'libraryComponentUID' libraryComponentUID = _STRING )'''
	}

	def imports() '''
		import "«model.nsURI»/gratext"
		import "«model.nsURI»" as «model.name.toLowerCase»
		«importMappings.entrySet.map['''import "«it.value»" as «it.key»'''].join('\n')»
		import "http://www.jabc.de/cinco/gdl/graphmodel/internal" as _graphmodel
		import "http://www.eclipse.org/emf/2002/Ecore" as _ecore
	'''

	override template() '''
		grammar «package».«model.name»Gratext hidden(_WS, _ML_COMMENT, _SL_COMMENT)
		
		«imports»
		
		«modelRule»
		
		«FOR node : model.containers.drop[isAbstract]»«containerRule(node)»«ENDFOR»
		
		«FOR node : model.nonContainerNodes.drop[isAbstract]»«nodeRule(node)»«ENDFOR»
		
		«FOR edge : model.edges.drop[isAbstract]»«edgeRule(edge)»«ENDFOR»
		
		«FOR type : model.userDefinedTypes»«typeRule(type)»«ENDFOR»
		
		«FOR type : model.enumerations»«enumRule(type)»«ENDFOR»
		
		_Decoration returns _graphmodel::_Decoration:{_graphmodel::_Decoration}
			'decorate' (nameHint = _EString)? 'at' locationShift = _Point
		;
		
		_Point returns _graphmodel::_Point:{_graphmodel::_Point}
			'(' x = _EInt ',' y = _EInt ')'
		;
		
		_EString returns _ecore::EString:
			_STRING
		;
		
		_EInt returns _ecore::EInt:
			_SIGN? _INT
		;
		
		_ELong returns _ecore::ELong:
			_SIGN? _INT
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
		
		_EDate returns _ecore::EDate:
			_STRING
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