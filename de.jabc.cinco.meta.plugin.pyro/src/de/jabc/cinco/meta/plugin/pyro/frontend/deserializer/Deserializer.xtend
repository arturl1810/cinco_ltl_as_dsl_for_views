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
	    «FOR elem:g.elements+#[g]»
	    if(jsog['dywaRuntimeType'] == 'info.scce.pyro.«g.name.lowEscapeJava».rest.«elem.name.fuEscapeJava»'){
	      return «elem.name.fuEscapeDart».fromJSOG(jsog,new Map());
	    }
	    «ENDFOR»
	    throw new Exception("Unknown element type: ${jsog['dywaRuntimeType']}");
	  }
	}
	'''
	
	def fileNamePropertyDeserializer()
	'''property_deserializer.dart'''
	
	def contentPropertyDeserializer()
	'''
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	«FOR g:gc.graphMopdels»
	import '«g.name.lowEscapeDart»_property_deserializer.dart';
	«ENDFOR»
	class PropertyDeserializer
	{
	  static IdentifiableElement deserialize(dynamic jsog,String graphModelType)
	  {
	    //for each graphmodel
	    «FOR g:gc.graphMopdels»
	    if(graphModelType == '«g.name.fuEscapeDart»'){
	      return «g.name.fuEscapeDart»PropertyDeserializer.deserialize(jsog);
	    }
	    «ENDFOR»
	    return null;
	  }
	}
	'''
}