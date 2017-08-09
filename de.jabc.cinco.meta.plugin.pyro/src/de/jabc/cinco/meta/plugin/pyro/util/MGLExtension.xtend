package de.jabc.cinco.meta.plugin.pyro.util

import java.util.Collections
import java.util.LinkedList
import java.util.List
import mgl.Attribute
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.UserDefinedType

class MGLExtension {
	
	protected extension Escaper = new Escaper
	
	static def String[] primitiveETypes() {
		return #["EString","EBoolean","EInt","EDouble"]
	} 
	
	def elements(GraphModel g){
		return g.nodes + g.edges
	}
	
	def htmlType(Attribute attr){
		switch(attr.type){
			case "EBoolean": return '''checkbox'''
			case "EInt": return '''number'''
			case "EDouble": return '''number'''
			default: return '''text'''
		}
	}
	
	def creatabel(GraphicalModelElement gme){
		(!gme.annotations.exists[name.equals("disable")&&value.contains("create")]) && (gme instanceof Node)
	}
	
	def hasIcon(GraphicalModelElement gme){
		(gme.annotations.exists[name.equals("icon")&&!value.empty]) && (gme instanceof Node)
	}
	
	def eclipseIconPath(GraphicalModelElement gme){
		gme.annotations.findFirst[name.equals("icon")].value.get(0)
	}
	
	def iconPath(GraphicalModelElement gme,String g){
		return gme.iconPath(g,true)
	}
	
	def iconPath(GraphicalModelElement gme,String g,boolean includeFile){
		val path = gme.eclipseIconPath
		'''img/«g»«IF includeFile»«path.substring(path.lastIndexOf("/"),path.length)»«ENDIF»'''
	}
	
	def paletteGroup(GraphicalModelElement gme){
		val groupId = gme.annotations.findFirst[name.equals("palette")]
		if(groupId == null){
			switch(gme){
				NodeContainer:return "Container"
			}
			return "Node"
		} else{
			if(groupId.value.empty)return "Node"
			return groupId.value.get(0)
		}
		
	}
	
	def elementsAndTypes(GraphModel g){
		return g.elements + g.types.filter(UserDefinedType)
	}
	
	def elementsAndTypesAndEnums(GraphModel g){
		return g.elements + g.types.filter(UserDefinedType) +g.enumerations
	}
	
	def boolean getIsType(ModelElement element){
		element instanceof UserDefinedType
	}
	
	def enumerations(GraphModel g){
		return g.types.filter(Enumeration)
	}
	
	def isPrimitive(Attribute attr,GraphModel g){
		primitiveETypes.contains(attr.type) || attr.type.getEnum(g)!=null
	}
	
	def getEnum(String type,GraphModel g) {
		g.types.filter(Enumeration).findFirst[name.equals(type)]
	}
	
	def init(Attribute it,GraphModel g){
		if(isPrimitive(g)){
			if(type.getEnum(g)!=null){
				return '''«type».«type.getEnum(g).literals.get(0)»'''
			}
			if(!defaultValue.nullOrEmpty) {
				return '''«primitiveBolster»«defaultValue»«primitiveBolster»'''
			}
			return '''«primitiveBolster»«initValue»«primitiveBolster»'''
		}
		'''null'''
	}
	
	def initValue(Attribute attr){
		switch(attr.type){
			case "EBoolean": return '''false'''
			case "EInt": return '''0'''
			case "EDouble": return '''0.0'''
			default: return ''''''
			
		}
	}
	
	def canContain(ModelElement element){
		element instanceof GraphModel || element instanceof NodeContainer
	}
	
	def isExtending(ModelElement element){
		switch element {
			NodeContainer: {
				return element.extends != null
			}
			Node: {
				return element.extends != null
			}
			Edge: {
				return element.extends != null
			}
			UserDefinedType: {
				return element.extends != null
			}
		}
		return false
	}
	
	def extending(ModelElement element){
		switch element {
			GraphModel: return "GraphModel"
			NodeContainer: {
				if (element.extends == null) return "Container"
				return element.extends.name
			}
			Node: {
				if (element.extends == null) return "Node"
				return element.extends.name
			}
			Edge: {
				if (element.extends == null) return "Edge"
				return element.extends.name
			}
			UserDefinedType: {
				if (element.extends == null) return "PyroElement"
				return element.extends.name
			}
			Enumeration: {
				return ""
			}
		}
		return ""
	}
	
	def primitiveDartType(Attribute attr,GraphModel g){
		if(attr.type.getEnum(g)!=null){
			return attr.type.getEnum(g).name.fuEscapeDart
		}
		switch(attr.type){
			case "EBoolean": return '''bool'''
			case "EInt": return '''int'''
			case "EDouble": return '''double'''
			default: return '''String'''
			
		}
	}
	
	def serialize(Attribute it,GraphModel g,String s){
		if(isPrimitive(g)){
			if(type.getEnum(g)!=null){
				return '''«type.fuEscapeDart»Parser.toJSOG(«s»)'''
			}
			switch(type){
				case "EBoolean": return '''«s»?"true":"false"'''
				case "EInt": return '''«s»'''
				case "EDouble": return '''«s»'''
				default: return '''«s»'''
				
			}
		}
		return '''«s».toJSOG(cache)'''
	}
	
	def deserialize(Attribute it,GraphModel g) {
		if(isPrimitive(g)){
			if(type.getEnum(g)!=null)return ""
			switch(type){
				case "EBoolean": return '''=="true"'''
				case "EInt": return ''''''
				case "EDouble": return ''''''
				default: return '''.toString()'''
				
			}
		}
		return ".toString()"
	}
	
	def complexDartType(Attribute attr){
		attr.type
	}
	
	def List<String> selfAndSubTypeNames(String typeName,GraphModel g){
		val l = new LinkedList
		l.add(typeName)
		l.addAll(typeName.subTypes(g).map[name])
		l
	}
	
	def Iterable<GraphicalModelElement> subTypes(String typeName,GraphModel g){
		if(typeName == null){
			return Collections.EMPTY_LIST
		}
		val all = g.nodes + g.edges
		val subType = all.findFirst[name.equals(typeName)]
		if(subType != null) {
			if(subType instanceof Node){
				val l = new LinkedList
				l.add(subType)
				if(subType.extends!=null){
					l.addAll(subType.extends.name.subTypes(g))					
				}
				return l
			}
			if(subType instanceof Edge){
				val l = new LinkedList
				l.add(subType)
				if(subType.extends !=null){
					l.addAll(subType.extends.name.subTypes(g))					
				}
				return l
			}
		}
		return Collections.EMPTY_LIST
	}
	
	def primitiveBolster(Attribute attr){
		switch(attr.type){
			case "EString": return '''"'''
			default: return ""
			
		}
	}
	
	def isList(Attribute attr){
		attr.upperBound>1 || attr.upperBound<0
	}
	
	def connectionContraints(GraphModel g){
		
	}
}