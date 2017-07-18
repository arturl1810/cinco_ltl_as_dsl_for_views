package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.canvas.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.Edge
import mgl.Node
import mgl.NodeContainer

class GraphmodelComponent extends Generatable {

	new(GeneratorCompound gc) {
		super(gc)
	}

	def fileNameGraphModelCommandGraph(String graphModel) '''«graphModel.lowEscapeDart»_command_graph.dart'''

	def contentGraphModelCommandGraph(GraphModel g) '''
		import 'package:angular2/core.dart';
		
		import 'package:«gc.projectName.escapeDart»/model/core.dart';
		import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
		import 'package:«gc.projectName.escapeDart»/model/command_graph.dart';
		import 'package:«gc.projectName.escapeDart»/model/command.dart';
		
		import 'dart:js' as js;
		
		class «g.name.fuEscapeDart»CommandGraph extends CommandGraph{
		
		  «g.name.fuEscapeDart»CommandGraph(GraphModel currentGraphModel,{Map jsog}) : super(currentGraphModel,jsog:jsog);
		
		  ModelElement findElement(id) => currentGraphModel.allElements().where((e)=>e is ModelElement).firstWhere((e)=>e.dywaId==id);
		
		  @override
		  Node execCreateNodeType(String type)
		  {
		    Node newNode;
		    // for each node type
		    «FOR elem : g.nodes»
		    	if(type == '«elem.name.fuEscapeDart»'){
		    	  newNode = new «elem.name.fuEscapeDart»();
		    	}
		    «ENDFOR»
		    return newNode;
		  }
		
		  @override
		  Edge execCreateEdgeType(String type)
		  {
		    Edge edge;
		     «FOR elem : g.edges»
		     	if(type == '«elem.name.fuEscapeDart»')
		     	{
		     	 edge = new «elem.name.fuEscapeDart»();
		     	}
		    «ENDFOR»
		    return edge;
		
		  }
		  
		  @override
		  void execCreateEdgeCommandCanvas(CreateEdgeCommand cmd) {
		      ModelElement e = findElement(cmd.delegateId);
		      «FOR edge : g.edges»
		      	if(cmd.type=='«g.name.lowEscapeDart».«edge.name.escapeDart»'){
		      	  js.context.callMethod('create_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		      	    cmd.sourceId,cmd.targetId,cmd.delegateId,cmd.dywaName,cmd.dywaVersion,e.styleArgs()
		      	  ]);
		      	  return;
		      	}
		      «ENDFOR»
		  }
		  
		  @override
		  void execRemoveEdgeCommandCanvas(RemoveEdgeCommand cmd) {
		      «FOR edge : g.edges»
		      	if(cmd.type=='«g.name.lowEscapeDart».«edge.name.escapeDart»'){
		      	  js.context.callMethod('remove_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		      	    cmd.delegateId
		      	  ]);
		      	}
		      «ENDFOR»
		  }
		  
		  @override
		  void execReconnectEdgeCommandCanvas(ReconnectEdgeCommand cmd) {
		        «FOR edge : g.edges»
		        	if(cmd.type=='«g.name.lowEscapeDart».«edge.name.escapeDart»'){
		        	  js.context.callMethod('reconnect_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		        	    cmd.sourceId,cmd.targetId,cmd.delegateId
		        	  ]);
		        	}
		        «ENDFOR»
		  }
		  
		  @override
		  void execCreateNodeCommandCanvas(CreateNodeCommand cmd) {
		      ModelElement e = findElement(cmd.delegateId);
		      «FOR node : g.nodes»
		      	if(cmd.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
		      	  js.context.callMethod('create_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		      	    cmd.x,cmd.y,cmd.delegateId,cmd.containerId,cmd.dywaName,cmd.dywaVersion,e.styleArgs()
		      	  ]);
		      	  return;
		      	}
		      «ENDFOR»
		  }
		  
		  @override
		  void execMoveNodeCanvas(MoveNodeCommand cmd) {
		  	«FOR node : g.nodes»
		  		if(cmd.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
		  		  js.context.callMethod('move_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		  		    cmd.x,cmd.y,cmd.delegateId,cmd.containerId
		  		  ]);
		  		  return;
		  		}
		  	«ENDFOR»
		  }
		  
		  @override
		  void execRemoveNodeCommandCanvas(RemoveNodeCommand cmd) {
		      «FOR node : g.nodes»
		  	if(cmd.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
		  		js.context.callMethod('remove_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		  			cmd.delegateId
		  		]);
		  		return;
		  	}
		  	«ENDFOR»
		  	}
		  	
		  	@override
		  	void execResizeNodeCommandCanvas(ResizeNodeCommand cmd) {
		  	    «FOR node : g.nodes»
		  	    	if(cmd.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
		  	    	  js.context.callMethod('resize_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		  	    	    cmd.width,cmd.height,cmd.delegateId
		  	    	  ]);
		  	    	  return;
		  	    	}
		  	    «ENDFOR»
		  	}
		  	
		  	@override
		  	void execRotateNodeCommandCanvas(RotateNodeCommand cmd) {
		  	    «FOR node : g.nodes»
		  	    	if(cmd.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
		  	    	  js.context.callMethod('rotate_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',[
		  	    	    cmd.angle,cmd.delegateId
		  	    	  ]);
		  	    	}
		  	    «ENDFOR»
		  	}
		  	
		  	@override
		  	void execUpdateBendPointCanvas(UpdateBendPointCommand cmd) {
		  	    js.context.callMethod('update_bendpoint_«g.name.lowEscapeDart»',[
		  	      cmd.positions,cmd.delegateId
		  	    ]);
		  	}
			
			}
		'''
		
	def propagation(CharSequence s)
	'''
	startPropagation().then((_){
		«s»
	}).then((_)=>endPropagation());
	'''
	

	def fileNameGraphModelComponent(String graphmodelName) '''«graphmodelName.lowEscapeDart»_component.dart'''

	def contentGraphModelComponent(GraphModel g) '''
		import 'dart:async';
		import 'package:angular2/core.dart';
		
		import 'package:«gc.projectName.escapeDart»/model/core.dart';
		import 'package:«gc.projectName.escapeDart»/model/message.dart';
		import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
		import '«g.name.lowEscapeDart»_command_graph.dart';
		
		import 'package:«gc.projectName.escapeDart»/service/graph_service.dart';
		
		import 'dart:js' as js;
		
		@Component(
		    selector: '«g.name.lowEscapeDart»-canvas',
		    templateUrl: '«g.name.lowEscapeDart»_component.html',
		    styleUrls: const [],
		    directives: const []
		)
		class «g.name.fuEscapeDart»CanvasComponent implements OnInit, OnChanges {
		
		
		  @Output()
		  EventEmitter selectionChanged;
		  @Output()
		  EventEmitter hasChanged;
		
		  @Input()
		  «g.name.fuEscapeDart» currentGraphModel;
		  
		  @Input()
		  PyroUser user;
		  
		  @Input()
		  LocalGraphModelSettings currentLocalSettings;
		
		  «g.name.fuEscapeDart»CommandGraph commandGraph;
		
		final GraphService graphService;
		
		  «g.name.fuEscapeDart»CanvasComponent(GraphService this.graphService)
		  {
		    selectionChanged = new EventEmitter();
		    hasChanged = new EventEmitter();
		
		  }
		
		  @override
		  void ngOnInit()
		  {
		  	initCanvas();
		  }
		  
		  void initCanvas() {
		  	graphService.loadCommandGraph«g.name.fuEscapeDart»(currentGraphModel).then((cg){
		  	  	commandGraph = cg;
			  	 	js.context.callMethod("load_«g.name.lowEscapeDart»",[
		  	 	      currentGraphModel.width,
		  	 	      currentGraphModel.height,
		  	 	      currentGraphModel.scale,
		  	 	      currentGraphModel.dywaId,
		  	 	      currentLocalSettings.router,
		  	 	      currentLocalSettings.connector,
		  	 	      //callback afert initialization
		  	 	      initialized,
		  	 	      //message callbacks
		  	 	      cb_element_selected,
		  	 	      cb_graphmodel_selected,
		  	 	      «FOR elem : g.nodes + g.edges SEPARATOR ","»
		  	 	      	«IF elem instanceof Node»
		  	 	      		cb_create_node_«elem.name.lowEscapeDart»,
		  	 	      		cb_remove_node_«elem.name.lowEscapeDart»,
		  	 	      		cb_move_node_«elem.name.lowEscapeDart»,
		  	 	      		cb_resize_node_«elem.name.lowEscapeDart»,
		  	 	      		cb_rotate_node_«elem.name.lowEscapeDart»
		  	 	      	«ENDIF»
		  	 	      	«IF elem instanceof Edge»
		  	 	      		cb_create_edge_«elem.name.lowEscapeDart»,
		  	 	      		cb_remove_edge_«elem.name.lowEscapeDart»,
		  	 	      		cb_reconnect_edge_«elem.name.lowEscapeDart»,
		  	 	      		cb_update_bendpoint_«elem.name.lowEscapeDart»
		  	 	      	«ENDIF»
		  	 	      «ENDFOR»
				]);
			});
		  }
		  	 
		  @override
		   ngOnChanges(Map<String, SimpleChange> changes) {
		     if(changes.containsKey('currentGraphModel')) {
		       var newGraph = changes['currentGraphModel'].currentValue;
		       var preGraph = changes['currentGraphModel'].previousValue;
		       if(newGraph != null&& newGraph is «g.name.fuEscapeDart» && preGraph != null && preGraph is «g.name.fuEscapeDart» && newGraph!=preGraph) {
		         //desroy
		         js.context.callMethod('destroy_«g.name.lowEscapeDart»',[]);
		         //rebuild
		         initCanvas();
		       }
		     }
		     if(changes.containsKey('currentLocalSettings')) {
		       
		     }
		   }
		   
		   
		   Future<Null> startPropagation(){
		    js.context.callMethod('start_propagation_«g.name.lowEscapeDart»',[]);
		    return new Future.value(null);
		   }
		   
		   void endPropagation(){
		     js.context.callMethod('end_propagation_«g.name.lowEscapeDart»',[]);
		     return;
		   }
		   
		   void updateScale() {
		   	js.context.callMethod('update_scale_«g.name.lowEscapeDart»',[currentGraphModel.scale]);
		   }
		   
		   void updateRouting() {
		   	js.context.callMethod('update_routing_«g.name.lowEscapeDart»',[currentGraphModel.router,currentGraphModel.connector]);
	   	   }
		  
		  /// create the current graphmodel initailly
		  void initialized() {
		  	//add nodes and container bottom up
		  	«'''
			initContainerDeeply(currentGraphModel);
			//connect by edges
			currentGraphModel.modelElements.where((n)=>n is Edge).forEach((e){
				«FOR edge : g.edges»
					if(e is «edge.name.escapeDart»){
						create_edge_«edge.name.lowEscapeDart»(e);
					}
				«ENDFOR»
			});
		  	'''.propagation»
			 }
			 
			 void initContainerDeeply(ModelElementContainer container) {
			     for(var node in container.modelElements) {
			     	«FOR node : g.nodes»
			     		if(node is «node.name.escapeDart»){
			     		  create_node_«node.name.lowEscapeDart»(node);
			     		  «IF node instanceof NodeContainer»
			     		  	initContainerDeeply(node);
			     		  «ENDIF»
			     		}
			     	«ENDFOR»
			     }
			 }
			 
			 IdentifiableElement findElement(int dywaId) => currentGraphModel.allElements().firstWhere((n)=>n.dywaId==dywaId);
			 
			 void cb_element_selected(int dywaId) {
			     if(dywaId<0){
			       selectionChanged.emit(currentGraphModel);
			     } else {
			     	//find element
			     	var newSelection = findElement(dywaId);
			     	selectionChanged.emit(newSelection);
			     }
			 }
			 
			 bool check_bendpoint_update(Edge edge,List positions) {
			 	if(positions==null) {
			 		return edge.bendingPoints.isNotEmpty;
			 	}
			 	 if(positions.length==edge.bendingPoints.length) {
			 		 for(var pos in positions){
			 			 var x = pos['x'];
			 			 var y = pos['y'];
			 			 var found = false;
			 			 for(var b in edge.bendingPoints) {
			 				 if(b.x==x&&b.y==y){
			 					 found = true;
			 					 break;
			 				 }
			 			 }
			 			 if(found==false){
			 				 return true;
			 			 }
			 		 }
			 	 } else {
			 	 return true;
			 	}
			 	return false;
			 }
			 
			 void cb_graphmodel_selected() {
			     selectionChanged.emit(currentGraphModel);
			 }
			 
			 void updateElement(ModelElement elem,{String cellId}) {
		   		js.context.callMethod('update_element_«g.name.lowEscapeDart»',[
					cellId,
		 			elem.dywaId,
		 			elem.dywaVersion,
		 			elem.dywaName,
		 			elem.styleArgs()
		   		]);
		 		
		 	}
			 
			 //for each node
			 «FOR node : g.nodes»
			 	void create_node_«node.name.lowEscapeDart»(«node.name.escapeDart» node) {
			 	    js.context.callMethod('create_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',
			 	    [ node.x,
			 	    	node.y,
			 	    	node.dywaId,
			 	    	node.container.dywaId,
			 	    	node.dywaName,
			 	    	node.dywaVersion,
			 	    	node.styleArgs() ]);
			 	}
			 	
			 	void cb_create_node_«node.name.lowEscapeDart»(int x,int y,String cellId,int containerId) {
			 		var container = findElement(containerId) as ModelElementContainer;
			 	    var m = commandGraph.sendCreateNodeCommand("«g.name.lowEscapeDart».«node.name.escapeDart»",x,y,containerId,user);
			 	    graphService.sendMessage(m).then((m){
			 	    if(m is ValidCreatedMessage){
			 	    	var node = 	new «node.name.fuEscapeDart»();
			 	    	node.x = x;
			 	    	node.y = y;
			 	    	node.dywaId = m.dywaId;
			 	    	node.dywaName = m.dywaName;
			 	    	node.dywaVersion = m.dywaVersion;
			 	    	node.container = container;
			 	    	container.modelElements.add(node);
			 	    	updateElement(node,cellId: cellId);
			 	    	commandGraph.collectElements(container);
			 	    	if(container is! GraphModel){
			 	    		updateElement(container as ModelElement);
			 	    	}
			 	    	selectionChanged.emit(node);
			 	    	}
			 	    });
			 	}
			 	
			 	void cb_remove_node_«node.name.lowEscapeDart»(int dywaId) {
			 		var node = findElement(dywaId) as Node;
			 		var container = findElement(node.container.dywaId) as ModelElementContainer;
			 	    var m = commandGraph.sendRemoveNodeCommand(dywaId,container.dywaId,node.x,node.y,"«g.name.lowEscapeDart».«node.name.escapeDart»",user);
			 	    graphService.sendMessage(m).then((m){
			 	    	if(m is ValidMessage){
			 	    		selectionChanged.emit(currentGraphModel);
			 	    		container.modelElements.remove(node);
			 	    		node.container = null;
			 	    			«'''
								//remove connected edges
								node.outgoing.forEach((e) {
									e.target.incoming.remove(e);
									e.container.modelElements.remove(e);
									e.container = null;
									js.context.callMethod('remove_edge__«g.name.lowEscapeDart»', [e.dywaId]);
								});
								node.outgoing.clear();
								node.incoming.forEach((e) {
									e.source.outgoing.remove(e);
									e.container.modelElements.remove(e);
									e.container = null;
									js.context.callMethod('remove_edge__«g.name.lowEscapeDart»', [e.dywaId]);
								});
								node.incoming.clear();
								commandGraph.collectElements(container);
								if(container is! GraphModel){
									updateElement(container as ModelElement);
								}
			 	    			'''.propagation»
			 	    	}
			 	    });
			 	}
			 	
			 	void cb_move_node_«node.name.lowEscapeDart»(int x,int y,int dywaId,containerId) {
			 		var container = findElement(containerId) as ModelElementContainer;
			 		var node = findElement(dywaId) as Node;
			 		if(node.x==x&&node.y==y){
			 			return;
			 		}
			 	    var m = commandGraph.sendMoveNodeCommand(dywaId,x,y,containerId,user);
			 	    graphService.sendMessage(m).then((m){
			 	    	if(m is ValidMessage){
			 	    		if(!container.modelElements.contains(node)){
			 	    			node.container.modelElements.remove(node);
			 	    			node.container = container;
			 	    			container.modelElements.add(node);
			 	    			if(container is! GraphModel){
			 	    				updateElement(container as ModelElement);
			 	    			}
			 	    		}
			 	    		node.x = x;
			 	    		node.y = y;
			 	    		updateElement(node);
			 	    	}
			 	   });
			 	}
			 	
			 	void cb_resize_node_«node.name.lowEscapeDart»(int width,int height,int dywaId) {
			 		var node = findElement(dywaId) as Node;
			 	    var m = commandGraph.sendResizeNodeCommand(dywaId,width,height,user);
			 	    graphService.sendMessage(m).then((m){
			 	    	if(m is ValidMessage){
			 	    		node.width = width;
			 	    		node.height = height;
			 	    		updateElement(node);
			 	    	}
			 	   });
			 	}
			 	
			 	void cb_rotate_node_«node.name.lowEscapeDart»(int angle,int dywaId) {
			 		var node = findElement(dywaId) as Node;
			 	    var m =commandGraph.sendRotateNodeCommand(dywaId,angle,user);
			 	    graphService.sendMessage(m).then((m){
			 	    	if(m is ValidMessage){
			 	    		node.angle = angle;
			 	    		updateElement(node);
			 	    	}
			 	    });
			 	}
			 «ENDFOR»
			 // for each edge
			 «FOR edge : g.edges»
			 	void create_edge_«edge.name.lowEscapeDart»(«edge.name.escapeDart» edge) {
			 	    js.context.callMethod('create_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»',
			 	    [ edge.source.dywaId,
			 	    edge.target.dywaId,
			 	    edge.dywaId,
			 	    edge.dywaName,
			 	    edge.dywaVersion,
			 	    edge.bendingPoints.map((n){
			 	    	return {'x':n.x,'y':n.y};
			 	    }),
			 	    edge.styleArgs() ]);
			 	}
			 	
			 	void cb_create_edge_«edge.name.lowEscapeDart»(int sourceId,int targetId,String cellId) {
			 		var source = findElement(sourceId) as Node;
			 		var target = findElement(targetId) as Node;
			 	    var m = commandGraph.sendCreateEdgeCommand("«g.name.lowEscapeDart».«edge.name.escapeDart»",targetId,sourceId,user);
			 	    graphService.sendMessage(m).then((m){
			 	     if(m is ValidCreatedMessage){
			 	    	var edge = new Transition();
			 	    	edge.dywaId = m.dywaId;
			 	    	edge.dywaVersion = m.dywaVersion;
			 	    	edge.dywaName = m.dywaName;
			 	    	edge.container = currentGraphModel;
			 	    	currentGraphModel.modelElements.add(edge);
			 	    	edge.source = source;
			 	    	source.outgoing.add(edge);
			 	    	edge.target = target;
			 	    	target.incoming.add(edge);
			 	    	commandGraph.collectElements(currentGraphModel);
			 	    	updateElement(edge,cellId: cellId);
			 	    	updateElement(source);
			 	    	updateElement(target);
			 	    	selectionChanged.emit(edge);
			 	     }
			 	    });
			 	}
			 	
			 	void cb_remove_edge_«edge.name.lowEscapeDart»(int dywaId) {
			 		var edge = findElement(dywaId) as Edge;
			 	    var m = commandGraph.sendRemoveEdgeCommand(dywaId,edge.source.dywaId,edge.target.dywaId,"«g.name.lowEscapeDart».«edge.name.escapeDart»",user);
			 	    graphService.sendMessage(m).then((m){
			 	    	if(m is ValidCreatedMessage){
			 	    		selectionChanged.emit(currentGraphModel);
			 	    		var source = edge.source;
			 	    		source.outgoing.remove(edge);
			 	    		updateElement(source);
			 	    		edge.source = null;
			 	    		var target = edge.target;
			 	    		target.incoming.remove(edge);
			 	    		updateElement(target);
			 	    		edge.target = null;
			 	    		edge.container.modelElements.remove(edge);
			 	    		edge.container = null;
			 	    		commandGraph.collectElements(edge.container);
			 	    		
		 	    		}
					});
			 	}
			 	
			 	void cb_reconnect_edge_«edge.name.lowEscapeDart»(int sourceId,int targetId,int dywaId,) {
			 		var edge = findElement(dywaId) as Edge;
			 		var source = findElement(sourceId) as Node;
			 		var target = findElement(targetId) as Node;
			 		if(edge.source.dywaId!=sourceId||edge.target.dywaId!=targetId) {
			 	    	var m = commandGraph.sendReconnectEdgeCommand(dywaId,sourceId,targetId,user);
			 	    	graphService.sendMessage(m).then((m){
			 	    		if(m is ValidMessage){
			 	    			if(edge.target != target){
			 	    				edge.target.incoming.remove(edge);
			 	    				edge.target = target;
			 	    				target.incoming.add(edge);
			 	    				updateElement(target);
			 	    			}
			 	    			if(edge.source != source){
			 	    				edge.source.outgoing.remove(edge);
			 	    				edge.source = source;
			 	    				source.outgoing.add(edge);
			 	    				updateElement(source);
			 	    			}
			 	    			updateElement(edge);
			 	    		}
			 	    	});
			 	    }
			 	}
			 	
			 	void cb_update_bendpoint_«edge.name.lowEscapeDart»(List positions,int dywaId) {
			 		var edge = findElement(dywaId) as Edge;
			 		//check if update is present
			 		if(check_bendpoint_update(edge,positions)) {
			 	      var m = commandGraph.sendUpdateBendPointCommand(dywaId,positions,user);
			 	      graphService.sendMessage(m).then((m){
			 	    	  if(m is ValidMessage){
			 	    		edge.bendingPoints.clear();
			 	    		positions.forEach((p){
			 	    			var b = new BendingPoint();
			 	    			b.x = p['x'];
			 	    			b.y = p['y'];
			 	    			edge.bendingPoints.add(b);
			 	    		});
			 	    	  }
			 	      });
			 		}
			 	}
		«ENDFOR»
		
		  void prepareCommandGraph()
		  {
		    if(currentGraphModel != null) {
		      commandGraph = new «g.name.fuEscapeDart»CommandGraph(currentGraphModel);
		      //wait for changes and propagate them
		    }
		  }
		
		  /// action triggered by the server
		  /// after a valid command has been propagated
		  /// and the local business models has to be modified
		  /// if propagation is enabled, the canvas is updated as well
		  Node execCreateNodeType(String type)
		  {
		    Node newNode;
		    // for each node type
		    «FOR elem : g.nodes»
		    	if(type == '«elem.name.fuEscapeDart»'){
		    	  newNode = new «elem.name.fuEscapeDart»();
		    	}
		    «ENDFOR»
		    return newNode;
		  }
		
		  Edge execCreateEdgeType(String type)
		  {
		    Edge edge;
		    «FOR elem : g.edges»
		    	if(type == '«elem.name.fuEscapeDart»')
		    	{
		    	  edge = new «elem.name.fuEscapeDart»();
		    	}
		    «ENDFOR»
		    return edge;
		
		  }
		
		  void sendCommand(CompoundCommandMessage ccm) {
		    hasChanged.emit(ccm);
		  }
		}
		
	'''

	def fileNameGraphModelComponentTemplate(String graphmodelName) '''«graphmodelName.lowEscapeDart»_component.html'''

	def contentGraphModelComponentTemplate(
		GraphModel g) '''
		<div style="overflow: auto;">
			<div ondragover="confirm_drop(event)" ondrop="drop_on_canvas_«g.name.lowEscapeDart»(event)" id="paper_«g.name.lowEscapeDart»" style="border: gray;
			   	border-width: 5px;
			   border-style: solid;"></div>
		</div>
	'''
}
