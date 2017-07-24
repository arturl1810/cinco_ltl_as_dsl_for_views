package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.canvas

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class CanvasComponent extends Generatable {
	
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameCanvasComponent()'''canvas_component.dart'''
	
	def contentCanvasComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_component.dart' as «g.name.lowEscapeDart»;
		
	«ENDFOR»
	import 'dart:js' as js;
	
	@Component(
	    selector: 'pyro-canvas',
	    templateUrl: 'canvas_component.html',
	    styleUrls: const ['package:«gc.projectName.escapeDart»/pages/editor/editor_component.css'],
	    directives: const [
	    	«FOR g:gc.graphMopdels SEPARATOR ","»
	    		«g.name.lowEscapeDart».«g.name.fuEscapeDart»CanvasComponent
    		«ENDFOR»
	    ]
	)
	class CanvasComponent implements OnInit {
	
	«FOR g:gc.graphMopdels»
	  @ViewChild('«g.name.lowEscapeDart»_canvas_component')
	  «g.name.lowEscapeDart».«g.name.fuEscapeDart»CanvasComponent «g.name.lowEscapeDart»CanvasComponent;
	«ENDFOR»
	
	  @Output()
	  EventEmitter selectionChanged;
	
	  @Output()
	  EventEmitter hasChanged;
	  
	  @Output()
	  EventEmitter tabChanged;
	
	  @Input()
	  PyroUser user;
	  @Input()
	  PyroProject project;
	  @Input()
	  GraphModel currentGraphModel;
	  @Input()
	  LocalGraphModelSettings currentLocalSettings;
	
	  CanvasComponent()
	  {
	    print("canvas");
	    selectionChanged = new EventEmitter();
	    hasChanged = new EventEmitter();
	    tabChanged = new EventEmitter();
	  }
	  
	  void updateProperties(IdentifiableElement element) {
	  	«FOR g:gc.graphMopdels»
	  	if(«g.name.lowEscapeDart»CanvasComponent!=null) {
	   		  «g.name.lowEscapeDart»CanvasComponent.updateProperties(element);
	   		}
	   	«ENDFOR»
	  }
	  
	  void updateScale() {
	  	«FOR g:gc.graphMopdels»
	  	if(«g.name.lowEscapeDart»CanvasComponent!=null) {
  		  «g.name.lowEscapeDart»CanvasComponent.updateScale();
  		}
	  	«ENDFOR»
	  }
	  
	  void updateRouting() {
	  «FOR g:gc.graphMopdels»
	  	  if(«g.name.lowEscapeDart»CanvasComponent!=null) {
    		  «g.name.lowEscapeDart»CanvasComponent.updateRouting();
		  }
	  	«ENDFOR»
	  }
	  
	  void undo() {
	  «FOR g:gc.graphMopdels»
	  	if(«g.name.lowEscapeDart»CanvasComponent!=null) {
	    	«g.name.lowEscapeDart»CanvasComponent.undo();
	  	}
	  «ENDFOR»
	  }
	  	  
	  void redo() {
	  «FOR g:gc.graphMopdels»
		if(«g.name.lowEscapeDart»CanvasComponent!=null) {
    		«g.name.lowEscapeDart»CanvasComponent.redo();
		}
	  «ENDFOR»
		  }
	
	  @override
	  void ngOnInit()
	  {
	  }
	  
	  bool isOpen(){
	    return currentLocalSettings.openedGraphModels.contains(currentGraphModel);
	  }
	  
	  // for each graph model
	  «FOR g:gc.graphMopdels»
	  bool is«g.name.fuEscapeDart»(){
	    if(currentGraphModel!=null){
	      return currentGraphModel is «g.name.lowEscapeDart».«g.name.fuEscapeDart»;
	    }
	    return false;
	  }
	  «ENDFOR»
	
	  String getActiveGraph(GraphModel openedGraph)
	  {
	    if(currentGraphModel == openedGraph)
	    {
	      return "active";
	    }
	    return "";
	  }
	
	  void showGraph(GraphModel openedGraph,dynamic e)
	  {
	    e.preventDefault();
	    currentGraphModel = openedGraph;
	    tabChanged.emit(currentGraphModel);
	  }
	
	  void removeGraphFromActiveList(GraphModel openedGraph,dynamic e)
	  {
	    e.preventDefault();
	    «FOR g:gc.graphMopdels»
	    if(openedGraph is «g.name.lowEscapeDart».«g.name.escapeDart»){
          js.context.callMethod('destroy_«g.name.lowEscapeDart»',[]);
        }
        «ENDFOR»
	    currentLocalSettings.openedGraphModels.remove(openedGraph);
	    if(currentGraphModel == openedGraph)
	    {
	      currentGraphModel = null;
	    }
	    tabChanged.emit({});
	  }
	
	
	}
	'''
	
	def fileNameCanvasComponentTemplate()'''canvas_component.html'''
	
	def contentCanvasComponentTemplate()
	'''
	<ul class="nav nav-tabs nav-tabs-justified" style="margin-left: 1px;">
	    <li
	        *ngFor="let openedGraph of currentLocalSettings.openedGraphModels"
	        role="presentation"
	        [ngClass]="getActiveGraph(openedGraph)"
	    >
	        <a style="cursor: pointer" href (click)="showGraph(openedGraph,$event)">{{ openedGraph.filename }} <span class="glyphicon glyphicon-remove" (click)="removeGraphFromActiveList(openedGraph,$event)"></span></a>
	
	    </li>
	</ul>
	<div *ngIf="currentGraphModel!=null">
	    <div class="panel panel-default pyro-panel">
	        <div class="panel-body pyro-panel-body">
	            <!-- for each graph type -->
	            «FOR g:gc.graphMopdels»
	           <«g.name.lowEscapeDart»-canvas
	           	#«g.name.lowEscapeDart»_canvas_component
	            *ngIf="is«g.name.fuEscapeDart»()&&isOpen()"
	            [user]="user"
	            [currentGraphModel]="currentGraphModel"
	            [currentLocalSettings]="currentLocalSettings"
	            (hasChanged)="hasChanged.emit($event)"
	            (selectionChanged)="selectionChanged.emit($event)"
	           ></«g.name.lowEscapeDart»-canvas>
	           «ENDFOR»
	        </div>
	    </div>
	</div>
	'''
}