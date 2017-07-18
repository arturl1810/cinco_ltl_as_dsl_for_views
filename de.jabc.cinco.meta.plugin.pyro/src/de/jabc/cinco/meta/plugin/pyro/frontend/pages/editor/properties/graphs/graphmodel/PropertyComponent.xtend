package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel

class PropertyComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNamePropertyComponent()'''property_component.dart'''
	
	def contentPropertyComponent(GraphModel g)
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
	
	// the «g.name.lowEscapeDart» itself
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_property_component.dart';
	// all elements of the «g.name.lowEscapeDart»
	«FOR elem:g.elementsAndTypes»
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/graphs/«g.name.lowEscapeDart»/«elem.name.lowEscapeDart»_property_component.dart';
	«ENDFOR»
	
	@Component(
	    selector: '«g.name.lowEscapeDart»',
	    templateUrl: 'property_component.html',
	    directives: const [
	      «g.name.fuEscapeDart»PropertyComponent
	      «FOR elem:g.elementsAndTypes BEFORE "," SEPARATOR ","»
	      «elem.name.fuEscapeDart»PropertyComponent
	      «ENDFOR»
	      ]
	)
	class PropertyComponent implements OnInit {
	
	  @Input()
	  PyroElement currentElement;
	
	  @Output()
	  EventEmitter hasChanged;
	
	  PropertyComponent()
	  {
	    print("property");
	    hasChanged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	
	  /// checks if the given element is a «g.name.fuEscapeDart»
	  /// instance.
	  bool check«g.name.fuEscapeDart»(PyroElement element)
	  {
	    return element is «g.name.fuEscapeDart»;
	  }
	«FOR elem:g.elementsAndTypes»
	  /// checks if the given element is a Start
	  /// instance.
	  bool check«elem.name.fuEscapeDart»(PyroElement element)
	  {
	    return element is «elem.name.fuEscapeDart»;
	  }
	«ENDFOR»
	}
	
	'''
	
	def fileNamePropertyComponentTemplate()'''property_component.html'''
	
	def contentPropertyComponentTemplate(GraphModel g)
	'''
	<«g.name.lowEscapeDart»-property
	    *ngIf="check«g.name.fuEscapeDart»(currentElement)"
	    [currentElement]="currentElement"
	    (hasChanged)="hasChanged.emit($event)"
	>
	</«g.name.lowEscapeDart»-property>
	«FOR elem:g.elementsAndTypes»
	<«elem.name.lowEscapeDart»-property
	    *ngIf="check«elem.name.fuEscapeDart»(currentElement)"
	    [currentElement]="currentElement"
	    (hasChanged)="hasChanged.emit($event)"
	></«elem.name.lowEscapeDart»-property>
	«ENDFOR»
	'''
}
