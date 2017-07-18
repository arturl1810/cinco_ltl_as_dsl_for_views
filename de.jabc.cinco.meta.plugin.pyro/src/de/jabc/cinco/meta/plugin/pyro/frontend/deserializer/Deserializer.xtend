package de.jabc.cinco.meta.plugin.pyro.frontend.deserializer

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel

class Deserializer extends Generatable {
	
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def filenameCommandPropertyDeserializer()
	'''command_property_deserializer.dart'''
	
	def contentCommandPropertyDeserializer()
	'''
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/model/command.dart';
	class CommandPropertyDeserializer
	{
	  static Command deserialize(dynamic jsog)
	  {
	    if(jsog['commandType'] == 'CreateNode'){
	      return CreateNodeCommand.fromJSOG(jsog);
	    }
	    return null;
	  }
	}
	'''
	
	def fileNameGraphmodelPropertyDeserializer(String graphModelName)
	'''«graphModelName.lowEscapeDart»_property_deserializer.dart'''
	
	def contentGraphmodelPropertyDeserializer(GraphModel g)
	'''
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
	class «g.name.fuEscapeDart»PropertyDeserializer
	{
	  static IdentifiableElement deserialize(dynamic jsog)
	  {
	    //for each graphmodel element, no types
	    «FOR elem:g.elements»
	    if(jsog['__type'] == '«fqn».«elem.name.fuEscapeDart»Impl'){
	      return «elem.name.fuEscapeDart».fromJSOG(jsog,new Map());
	    }
	    «ENDFOR»
	    return null;
	  }
	}
	'''
	
	def fileNamePropertyDeserializer(String graphModelName)
	'''property_deserializer.dart'''
	
	def contentPropertyDeserializer(GraphModel g)
	'''
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import '«g.name.lowEscapeDart»_property_deserializer.dart';
	class PropertyDeserializer
	{
	  static IdentifiableElement deserialize(dynamic jsog,String graphModelType)
	  {
	    //for each graphmodel
	    if(graphModelType == '«g.name.fuEscapeDart»'){
	      return «g.name.fuEscapeDart»PropertyDeserializer.deserialize(jsog);
	    }
	    return null;
	  }
	}
	'''
}