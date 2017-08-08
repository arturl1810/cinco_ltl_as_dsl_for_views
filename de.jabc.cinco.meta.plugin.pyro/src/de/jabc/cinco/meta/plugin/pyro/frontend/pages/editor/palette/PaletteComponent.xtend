package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class PaletteComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNamePaletteComponent()'''palette_component.dart'''
	
	def contentPaletteComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/graphs/«g.name.lowEscapeDart»/palette_builder.dart';
	«ENDFOR»
	
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/list/list_view.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/list/list_component.dart';
	
	
	@Component(
	    selector: 'palette',
	    templateUrl: 'palette_component.html',
	    directives: const [ListComponent],
	    styleUrls: const ['package:«gc.projectName.escapeDart»/pages/editor/editor_component.css']
	)
	class PaletteComponent implements OnInit, OnChanges {
	
	  @Input()
	  GraphModel currentGraphModel;
	
	  @Output()
	  EventEmitter dragged;
	
	  List<MapList> map;
	
	
	  PaletteComponent()
	  {
	    print("palette");
	    dragged = new EventEmitter();
	    map = new List<MapList>();
	  }
	
	  @override
	  void ngOnInit()
	  {
	    buildList();
	
	  }
	
	  void buildList()
	  {
	    if(currentGraphModel!=null)
	    {
    	«FOR g:gc.graphMopdels»
if(is«g.name.fuEscapeDart»(currentGraphModel))
{
	map = «g.name.fuEscapeDart»PaletteBuilder.build(currentGraphModel);
}
	    «ENDFOR»
	    } else {
	       map = null;
	    }
	  }
	«FOR g:gc.graphMopdels»
	  /// check graph model type
	  bool is«g.name.fuEscapeDart»(GraphModel graph)
	  {
	    return graph is «g.name.fuEscapeDart»;
	  }
    «ENDFOR»
	
	
	  @override
	  ngOnChanges(Map<String, SimpleChange> changes) {
	    buildList();
	  }
	}
	
	'''
	
}