package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class EditorComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameEditorComponent()'''editor_component.dart'''
	
	def contentEditorComponent()
	'''
	import 'package:«gc.projectName.escapeDart»/model/message.dart';
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/menu/menu_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/explorer/explorer_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/canvas_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/properties_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/list/list_view.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/palette/palette_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/map/map_component.dart';
	import 'package:«gc.projectName.escapeDart»/pages/editor/notification/notification_component.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_command_graph.dart';
	«ENDFOR»
	import 'package:«gc.projectName.escapeDart»/service/graph_service.dart';
	import 'package:«gc.projectName.escapeDart»/service/project_service.dart';
	
	@Component(
	    selector: 'editor',
	    templateUrl: 'editor_component.html',
	    styleUrls: const ['editor_component.css'],
	    providers: const [GraphService,ProjectService],
	    directives: const [
	      MenuComponent,
	      ExplorerComponent,
	      CanvasComponent,
	      PropertiesComponent,
	      PaletteComponent,
	      MapComponent,
	      NotificationComponent
	    ]
	)
	class EditorComponent implements OnInit, OnChanges {
	
	  @ViewChild('notification')
	  NotificationComponent notificationComponent;
	  
	  @ViewChild('canvas')
	  CanvasComponent canvasComponent;
	
	  @Output()
	  EventEmitter openProject;
	
	  @Output()
	  EventEmitter back;
	
	  @Output()
	  EventEmitter logout;
	
	
	  @Input()
	  PyroUser user;
	  @Input()
	  PyroProject project;
	
	  GraphModel currentGraphModel = null;
	
	  IdentifiableElement selectedElement = null;
	
	  LocalGraphModelSettings currentLocalSettings;
	  
	  final GraphService graphService;
	
	  EditorComponent(GraphService this.graphService)
	  {
	    print("editor");
	    currentLocalSettings = new LocalGraphModelSettings();
	
	    openProject = new EventEmitter();
	    back = new EventEmitter();
	    logout = new EventEmitter();
	
	  }
	
	  @override
	  void ngOnInit()
	  {
	    notificationComponent.displayMessage("Hello ${user.username}",AlertType.INFO);
	  }
	  
	   void changedTabbing(dynamic e) {
	    if(!currentLocalSettings.openedGraphModels.contains(currentGraphModel)){
	      currentGraphModel = null;
	    } else {
	      currentGraphModel = e;
	      selectedElement = e;
		}
	  }
	
	  void changeLayout(String s)
	  {
	    if(currentGraphModel != null) {
	      canvasComponent.updateRouting();
	      sendProjectStructureUpdate();
	    } else {
	      notificationComponent.displayMessage("No graphmodel present to scale",AlertType.WARNING);
	    }
	  }
	
	  void changeScale(bool positive)
	  {
	  	if(currentGraphModel != null) {
		    if(positive){
		      currentGraphModel.scale*=1.1;
		    }
		    else{
		      currentGraphModel.scale*=0.9;
		    }
		    canvasComponent.updateScale();
			sendProjectStructureUpdate();
	    } else {
	    	notificationComponent.displayMessage("No graphmodel present to scale",AlertType.WARNING);
	    }
	
	  }
	
	  void hasDeletedGraph(GraphModel g)
	  {
	    if(currentGraphModel==g){
	      currentGraphModel==null;
	    }
	    if(currentLocalSettings.openedGraphModels.contains(g)){
	      currentLocalSettings.openedGraphModels.remove(g);
	    }
	  }
	
	  void hasDeletedFolder(PyroFolder f)
	  {
	    f.innerFolders.forEach((n) => hasDeletedFolder(n));
	    f.graphModels.forEach((n) => hasDeletedGraph(n));
	  }
	
	  void hasDeleted(dynamic e)
	  {
	    if(e is PyroFolder){
	      hasDeletedFolder(e);
	    }
	    if(e is GraphModel){
	      hasDeletedGraph(e);
	    }
	    sendProjectStructureUpdate();
	  }
	
	  void changeStructure(dynamic e)
	  {
	    sendProjectStructureUpdate();
	  }
	
	  void changedGraph(CompoundCommandMessage ccm)
	  {
	    sendMessage(ccm);
	  }
	
	  void changedProperties(PropertyMessage pm)
	  {
	  	canvasComponent.updateProperties(pm.delegate);
	    sendMessage(pm);
	  }
	
	  void addAndOpenGraphModel(GraphModel graphModel)
	  {
	    if(!currentLocalSettings.openedGraphModels.contains(graphModel))
	    {
	      currentLocalSettings.openedGraphModels.add(graphModel);
	    }
	    currentGraphModel = graphModel;
	    selectedElement = currentGraphModel;
	  }
	
	  void selectionChanged(IdentifiableElement element)
	  {
	    selectedElement = element;
	  }
	
	  void currentDragging(MapListValue value)
	  {
	    print(value.name);
	  }
	
	  void receiveMessage(String json)
	  {
	    Message message = Message.fromJSON(json);
	    notificationComponent.displayMessage("Update",AlertType.INFO);
	    if(message is CompoundCommandMessage) {
	      receiveGraphModelUpdate(message);
	    }
	    if(message is ProjectMessage) {
	      receiveProjectStructureUpdate(message);
	    }
	    if(message is PropertyMessage) {
	      receivePropertyUpdate(message);
	    }
	  }
	
	  void sendMessage(Message message)
	  {
	    graphService.sendMessage(message);
	  }
	
	  void sendProjectStructureUpdate()
	  {
	    ProjectMessage pm = new ProjectMessage();
	    pm.project = project;
	    sendMessage(pm);
	  }
	
	  void receiveProjectStructureUpdate(ProjectMessage message)
	  {
	    project.merge(message.project);
	  }
	
	  void receiveGraphModelUpdate(CompoundCommandMessage message)
	  {
	    GraphModel gm = project.allGraphModels().where((g) => g.dywaId==message.graphModelId).first;
	    if(gm != null) {
	      // for each graph model
	      «FOR g:gc.graphMopdels»
	      if(gm.runtimeType.toString() == '«g.name.fuEscapeDart»') {
	        «g.name.fuEscapeDart»CommandGraph cg = new «g.name.fuEscapeDart»CommandGraph(gm);
	        cg.receiveCommand(message);
	      }
	      «ENDFOR»
	    }
	
	  }
	
	  void receivePropertyUpdate(PropertyMessage message)
	  {
	    GraphModel gm = project.allGraphModels().where((g) => g.dywaId==message.graphModelId).first;
	    if(gm != null) {
	        IdentifiableElement ie = gm.allElements().where((n)=>n.dywaId==message.delegate.dywaId).first;
	        if(ie != null) {
	          ie.merge(message.delegate);
	        }
	    }
	  }
	  
	    @override
	    ngOnChanges(Map<String, SimpleChange> changes) {
	      if(changes.containsKey("project")){
	        notificationComponent.displayMessage("Opend project ${project.name}",AlertType.SUCCESS);
	      }
	    }
	
	}
	
	'''
	
}