package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.Node

class PaletteBuilder extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNamePaletteBuilder() '''palette_builder.dart'''
	
	def contentPaletteBuilder(mgl.GraphModel g) '''
	
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/list/list_view.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
	
	
	class «g.name.fuEscapeDart»PaletteBuilder {
	
	  static List<MapList> build(«g.name.fuEscapeDart» graph)
	  {
	    List<MapList> paletteMap = new List();
	    «FOR group:g.elements.filter(Node).filter[creatabel].groupBy[paletteGroup].entrySet»
	    paletteMap.add(new MapList('«group.key»',values: [
	    	«FOR entry:group.value SEPARATOR ","»
	    	new MapListValue('«entry.name.fuEscapeDart»',identifier: "«g.name.lowEscapeDart».«entry.name.fuEscapeDart»",«IF entry.hasIcon»imgPath:'asset/«entry.iconPath(g.name.lowEscapeDart)»'«ENDIF»)
	      	«ENDFOR»
	    ]));
	    «ENDFOR»
	    return paletteMap;
	  }
	
	}
	
	'''
	
}
