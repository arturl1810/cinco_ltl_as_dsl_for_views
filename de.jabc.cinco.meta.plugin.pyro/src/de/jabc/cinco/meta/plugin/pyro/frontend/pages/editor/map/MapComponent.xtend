package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.map

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class MapComponent extends Generatable {

	new(GeneratorCompound gc) {
		super(gc)
	}

	def fileNameMapComponent() '''map_component.dart'''

	def contentMapComponent() '''
		import 'package:angular2/core.dart';
		
		import 'package:«gc.projectName.escapeDart»/model/core.dart';
		
		«FOR g:gc.graphMopdels»
		import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
		«ENDFOR»
		
		import 'dart:js' as js;
		
		@Component(
		    selector: 'map',
		    templateUrl: 'map_component.html',
		    directives: const [],
		    styleUrls: const ['package:«gc.projectName.escapeDart»/pages/editor/editor_component.css']
		)
		class MapComponent implements OnInit, OnChanges {
		
		  @Input()
		  GraphModel currentGraphModel;
		
		
		  @override
		     void ngOnInit()
		     {
		       if(currentGraphModel!=null){
		         triggerMap(currentGraphModel);
		       }
		     }
		 
		     @override
		     ngOnChanges(Map<String, SimpleChange> changes) {
		       if(changes.containsKey("currentGraphModel")){
		         var value = changes["currentGraphModel"].currentValue;
		         if(value!=null){
		          triggerMap(value);
		       }
		     }
		   }
		   
		   void triggerMap(GraphModel g) {
		   	«FOR g : gc.graphMopdels»
		       if(g is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
		         js.context.callMethod('create_«g.name.lowEscapeDart»_map',[]);
		       }
	       «ENDFOR»
		     }
		   
		  «FOR g : gc.graphMopdels»
		  	bool check«g.name.escapeDart»() {
		  		if(currentGraphModel==null){
		  		   return false;
		  		}
		  	  	return currentGraphModel is «g.name.lowEscapeDart».«g.name.fuEscapeDart»;
		  	}
		 «ENDFOR»
		
		}
		
	'''

	def fileNameMapComponentTemplate() '''map_component.html'''

	def contentMapComponentTemplate() '''
		<div class="panel panel-default pyro-panel" *ngIf="currentGraphModel!=null">
		    <div class="panel-heading pyro-panel-heading">
		        <strong>Minature View</strong>
		    </div>
		    <div class="panel-body pyro-panel-body">
				<template [ngIf]="currentGraphModel!=null">
				«FOR g : gc.graphMopdels»
					<div *ngIf="check«g.name.escapeDart»()" id="paper_map_«g.name.lowEscapeDart»"></div>
				«ENDFOR»
				</template>
				  </div>
		</div>
	'''

}
