package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.property

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class PropertyComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNamePropertyComponent()'''property_component.dart'''
	
	def contentPropertyComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/graphs/«g.name.lowEscapeDart»/property_component.dart' as «g.name.lowEscapeDart»Property;
	«ENDFOR»
	
	@Component(
	    selector: 'property',
	    templateUrl: 'property_component.html',
	    directives: const [
	    «FOR g:gc.graphMopdels SEPARATOR ","»
	      «g.name.lowEscapeDart»Property.PropertyComponent
	    «ENDFOR»
	      ]
	)
	class PropertyComponent implements OnInit {
	
	  @Input()
	  PyroElement currentElement;
	
	  @Input()
	  GraphModel currentGraph;
	
	  @Output()
	  EventEmitter hasChanged;
	
	  PropertyComponent()
	  {
	    hasChanged = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	
	  }
	«FOR g:gc.graphMopdels»
	  /// checks if the given element belongs to
	  /// the «g.name.fuEscapeDart»
	  bool check«g.name.fuEscapeDart»(GraphModel element)
	  {
	    return element is «g.name.lowEscapeDart».«g.name.fuEscapeDart»;
	  }
	«ENDFOR»
	
	}
	'''
	
	def fileNamePropertyComponentTemplate()'''property_component.html'''
	
	def contentPropertyComponentTemplate()
	'''
	«FOR g:gc.graphMopdels»
	<«g.name.lowEscapeDart»
	    *ngIf="check«g.name.fuEscapeDart»(currentGraph)"
	    [currentElement]="currentElement"
	    (hasChanged)="hasChanged.emit($event)"
	></«g.name.lowEscapeDart»>
	«ENDFOR»
	'''
}