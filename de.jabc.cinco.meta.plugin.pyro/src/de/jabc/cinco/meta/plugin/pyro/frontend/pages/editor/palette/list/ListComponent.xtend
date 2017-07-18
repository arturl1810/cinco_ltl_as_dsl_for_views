package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.palette.list

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class ListComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameListComponent()'''list_component.dart'''
	
	def contentListComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'list_view.dart';
	
	
	@Component(
	    selector: 'list',
	    templateUrl: 'list_component.html',
	    directives: const [],
	    styleUrls: const ['package:«gc.projectName.escapeDart»/pages/editor/editor_component.css']
	)
	class ListComponent implements OnInit {
	
	  @Input()
	  List<MapList> map;
	
	  @Output()
	  EventEmitter dragged;
	
	  ListComponent()
	  {
	    dragged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  void openEntry(MapList mapList,dynamic e)
	  {
	    e.preventDefault();
	    mapList.open = !mapList.open;
	  }
	
	  void expandAll(dynamic e)
	  {
	    e.preventDefault();
	    map.forEach((n) => n.open=true);
	  }
	
	  void collapseAll(dynamic e)
	  {
	    e.preventDefault();
	    map.forEach((n) => n.open=false);
	  }
	
	  void startDragging(MapListValue value,dynamic e)
	  {
	    dragged.emit(value);
	  }
	
	}
	
	'''
}