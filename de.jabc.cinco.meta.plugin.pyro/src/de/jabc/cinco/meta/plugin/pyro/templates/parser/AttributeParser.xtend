package de.jabc.cinco.meta.plugin.pyro.templates.parser

import mgl.Attribute
import java.util.ArrayList
import mgl.Type
import mgl.Enumeration
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class AttributeParser {
	static def createAttribute(mgl.Attribute attribute,String modelName,ArrayList<Type> enums)
	'''
	«IF !ModelParser.isUserDefinedType(attribute,enums)»
	«IF attribute.upperBound == 1 && (attribute.lowerBound == 0 || attribute.lowerBound == 1) »
	«createPrimativeAttribute(attribute,modelName,enums)»
	«ELSE»
	«createListAttribute(attribute,modelName,enums)»
	«ENDIF»
	«ENDIF»
	'''
	
	static def createListAttribute(Attribute attribute, String name,ArrayList<Type> enums)
	'''
	// «attribute.name.toFirstUpper»
	JSONObject «attribute.name.toFirstLower» = new JSONObject();
	«attribute.name.toFirstLower».put("name","«attribute.name.toFirstLower»");
	«attribute.name.toFirstLower».put("type","list");
	«attribute.name.toFirstLower».put("upper",new Integer(«attribute.upperBound»));
	«attribute.name.toFirstLower».put("lower",new Integer(«attribute.lowerBound»));
	
	JSONObject «attribute.name.toFirstLower»SubType = new JSONObject();
	«attribute.name.toFirstLower»SubType.put("name","«attribute.name.toFirstLower»");
	«attribute.name.toFirstLower»SubType.put("type","«getAttributeType(attribute.type)»");
	«createPrimativeAttributeValuesDefault(attribute,attribute.name+"SubType",name,enums)»
	
	«attribute.name.toFirstLower».put("subtype",«attribute.name.toFirstLower»SubType);
	
	JSONArray «attribute.name.toFirstLower»Values = new JSONArray();
	for(String listEntry:«name.toFirstLower».get«attribute.name.toFirstLower»()){
	    JSONObject «attribute.name.toFirstLower»Value = new JSONObject();
	    «attribute.name.toFirstLower»Value.put("name","«attribute.name.toFirstLower»");
	    «attribute.name.toFirstLower»Value.put("type","«getAttributeType(attribute.type)»");
	    «createPrimativeAttributeValuesList(attribute,attribute.name+"Value",name,enums)»
	    «attribute.name.toFirstLower»Values.add(«attribute.name.toFirstLower»Value);
	}
	«attribute.name.toFirstLower».put("values",«attribute.name.toFirstLower»Values);
	
	«name.toFirstLower»Attributes.add(«attribute.name.toFirstLower»);
	'''
	
	static def createPrimativeAttribute(Attribute attribute, String string, ArrayList<Type> enums)
	'''
	// «attribute.name.toFirstUpper»
	JSONObject «attribute.name.toFirstLower» = new JSONObject();
	«attribute.name.toFirstLower».put("name","«attribute.name.toFirstLower»");
	«attribute.name.toFirstLower».put("type","«getAttributeType(attribute.type)»");
	«createPrimativeAttributeValues(attribute,attribute.name,string,enums)»
	
	«string.toFirstLower»Attributes.add(«attribute.name.toFirstLower»);
	'''
	
	static def createPrimativeAttributeValues(Attribute attribute,String attrName, String string, ArrayList<Type> enums)
	'''
	«IF attribute.type.equals("EString")»
	«attrName.toFirstLower».put("values",new String(«string.toFirstLower».get«attribute.name.toFirstLower»()==null?"":«string.toFirstLower».get«attribute.name.toFirstLower»()));
	«ELSEIF attribute.type.equals("EInt")»
	«attrName.toFirstLower».put("values",new Long(«string.toFirstLower».get«attribute.name.toFirstLower»()==null?0:«string.toFirstLower».get«attribute.name.toFirstLower»()));
	«ELSEIF attribute.type.equals("EDouble")»
	«attrName.toFirstLower».put("values",new Double(«string.toFirstLower».get«attribute.name.toFirstLower»()==null?0.00:«string.toFirstLower».get«attribute.name.toFirstLower»()));
	«ELSEIF attribute.type.equals("EBoolean")»
	«attrName.toFirstLower».put("values",new Boolean(«string.toFirstLower».get«attribute.name.toFirstLower»()==null?false:«string.toFirstLower».get«attribute.name.toFirstLower»()));
	«ELSEIF ModelParser.isUserDefinedType(attribute,enums)»
	«ELSE»
	JSONObject «attribute.name.toFirstLower»Values = new JSONObject();
	«attrName.toFirstLower»Values.put("selected",new String(«string.toFirstLower».get«attribute.name.toFirstLower»()==null?"":«string.toFirstLower».get«attribute.name.toFirstLower»()));
	JSONArray «attribute.name.toFirstLower»Choices = new JSONArray();
	«var type = getEnumByName(attribute,enums) as Enumeration»
	«FOR String literal : type.literals»
	«attrName.toFirstLower»Choices.add(new String("«literal.toFirstUpper»"));
	«ENDFOR»
	«attrName.toFirstLower»Values.put("choices",«attrName.toFirstLower»Choices);
	
	«attrName.toFirstLower».put("values", «attrName.toFirstLower»Values);
	«ENDIF»
	'''
	
	static def createPrimativeAttributeValuesList(Attribute attribute,String attrName, String string, ArrayList<Type> enums)
	'''
	«IF attribute.type.equals("EString")»
	«createPrimativeAttributeValuesListIterated(attrName)»
	«ELSEIF attribute.type.equals("EInt")»
	«createPrimativeAttributeValuesListIterated(attrName)»
	«ELSEIF attribute.type.equals("EDouble")»
	«createPrimativeAttributeValuesListIterated(attrName)»
	«ELSEIF attribute.type.equals("EBoolean")»
	«createPrimativeAttributeValuesListIterated(attrName)»
	«ELSEIF ModelParser.isUserDefinedType(attribute,enums)»
	
	«ELSE»
	JSONObject «attrName.toFirstLower»Values = new JSONObject();
	«attrName.toFirstLower»Values.put("selected",new String(""+listEntry==null?"":listEntry));
	JSONArray «attrName.toFirstLower»Choices = new JSONArray();
	«var type = getEnumByName(attribute,enums) as Enumeration»
	«FOR String literal : type.literals»
	«attrName.toFirstLower»Choices.add(new String("«literal.toFirstUpper»"));
	«ENDFOR»
	«attrName.toFirstLower»Values.put("choices",«attrName.toFirstLower»Choices);
	
	«attrName.toFirstLower».put("values", «attrName.toFirstLower»Values);
	«ENDIF»
	'''
	
	static def createPrimativeAttributeValuesListIterated(String attrName)
	'''
	«attrName.toFirstLower».put("values",new String(""+listEntry==null?"":listEntry));
	'''
	
	static def createPrimativeAttributeValuesDefault(Attribute attribute,String attrName, String string, ArrayList<Type> enums)
	'''
	«IF attribute.type.equals("EString")»
	«attrName.toFirstLower».put("values",new String(""));
	«ELSEIF attribute.type.equals("EInt")»
	«attrName.toFirstLower».put("values",new Integer(0));
	«ELSEIF attribute.type.equals("EDouble")»
	«attrName.toFirstLower».put("values",new Double(0.00));
	«ELSEIF attribute.type.equals("EBoolean")»
	«attrName.toFirstLower».put("values",new Boolean(false));
	«ELSEIF ModelParser.isUserDefinedType(attribute,enums)»
	
	«ELSE»
	JSONObject «attrName.toFirstLower»Values = new JSONObject();
	«var type = getEnumByName(attribute,enums) as Enumeration»
	«attrName.toFirstLower»Values.put("selected",new String("«type.literals.get(0).toFirstUpper»"));
	JSONArray «attrName.toFirstLower»Choices = new JSONArray();
	«FOR String literal : type.literals»
	«attrName.toFirstLower»Choices.add(new String("«literal.toFirstUpper»"));
	«ENDFOR»
	«attrName.toFirstLower»Values.put("choices",«attrName.toFirstLower»Choices);
	
	«attrName.toFirstLower».put("values", «attrName.toFirstLower»Values);
	«ENDIF»
	'''
	static def getAttributeType(String type) {
		if(type.equals("EString")) return "text";
		if(type.equals("EInt")) return "number";
		if(type.equals("EDouble")) return "double";
		if(type.equals("EBoolean")) return "boolean";
		//ENUM
		return "choice";
	}
	
	
	static def Type getEnumByName(Attribute attr, ArrayList<Type> enums) {
		var typeName = attr.type;
		for(Type type : enums) {
			if(type.name.equals(typeName)){
				return type;
			}
		}
		return null;
		
	}

	
}