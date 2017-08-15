package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.canvas.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.Edge
import mgl.Node
import mgl.NodeContainer
import mgl.ContainingElement
import mgl.IncomingEdgeElementConnection
import mgl.EdgeElementConnection
import mgl.ReferencedModelElement
import mgl.ModelElement

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
		
		
		  @override
		  Node execCreateNodeType(String type,IdentifiableElement primeElement)
		  {
		    // for each node type
		    «FOR elem : g.nodes»
		    	if(type == '«g.name.lowEscapeDart».«elem.name.fuEscapeDart»'){
		    	  var newNode = new «elem.name.fuEscapeDart»();
		    	  «IF elem.prime»
		    	  newNode.«elem.primeReference.name.escapeDart» = primeElement;
		    	  «ENDIF»
		    	  return newNode;
		    	}
		    «ENDFOR»
		    throw new Exception("Unkown node type ${type}");
		  }
		
		  @override
		  Edge execCreateEdgeType(String type)
		  {
		    Edge edge;
		     «FOR elem : g.edges»
		     	if(type == '«g.name.lowEscapeDart».«elem.name.fuEscapeDart»')
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
		      	    cmd.sourceId,cmd.targetId,cmd.delegateId,cmd.dywaName,cmd.dywaVersion,cmd.positions,e.styleArgs()
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
		      	    cmd.x,cmd.y,cmd.width,cmd.height,cmd.delegateId,cmd.containerId,cmd.dywaName,cmd.dywaVersion,e.styleArgs()«IF node.prime»,cmd.primeId«ENDIF»
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
		  	    	    cmd.width,cmd.height,cmd.direction,cmd.delegateId
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
		import 'dart:html' as html;
		import 'dart:convert' as convert;
		import 'package:angular2/core.dart';
		
		import 'package:«gc.projectName.escapeDart»/model/core.dart';
		import 'package:«gc.projectName.escapeDart»/model/message.dart';
		import 'package:«gc.projectName.escapeDart»/model/command.dart';
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
		  @Output()
		  EventEmitter close;
		
		  @Input()
		  «g.name.fuEscapeDart» currentGraphModel;
		  
		  @Input()
		  PyroUser user;
		  
		  @Input()
		  LocalGraphModelSettings currentLocalSettings;
		
		  «g.name.fuEscapeDart»CommandGraph commandGraph;
		  
		  html.WebSocket webSocketGraphModel;
		
		  final GraphService graphService;
		
		  «g.name.fuEscapeDart»CanvasComponent(GraphService this.graphService)
		  {
		    selectionChanged = new EventEmitter();
		    hasChanged = new EventEmitter();
		    close = new EventEmitter();
		  }
		
		  @override
		  void ngOnInit()
		  {
		  	initCanvas();
		  	activateWebSocket();
		  }
		  
		  void closeWebSocket() {
		  		if(this.webSocketGraphModel != null && this.webSocketGraphModel.readyState == html.WebSocket.OPEN) {
		  			html.window.console.debug("Closing Websocket webSocketCurrentUser");
		  			this.webSocketGraphModel.close();
		  			this.webSocketGraphModel = null;
		  		}
		  	}
		  
		  void activateWebSocket() {
		  		if(this.currentGraphModel != null && user != null && this.webSocketGraphModel == null) {
		  			this.webSocketGraphModel = new html.WebSocket('ws://${html.window.location.hostname}:8080/app/ws/graphmodel/${currentGraphModel.dywaId}/private');
		  
		  			// Callbacks for currentUser
		  			this.webSocketGraphModel.onOpen.listen((e) {
		  				html.window.console.debug("[PYRO] onOpen GraphModel Websocket");
		  			});
		  			this.webSocketGraphModel.onMessage.listen((html.MessageEvent e) {
		  				html.window.console.debug("[PYRO] onMessage GraphModel Websocket");
		  				if(e.data != null) {
		  					var jsog = convert.JSON.decode(e.data);
		  					if(jsog['senderId'].toString()!=user.dywaId.toString()){
		  						if(jsog['content']['messageType']=='graphmodel'){
		  							startPropagation().then((_) {
		  								currentGraphModel.merge(«g.name.fuEscapeDart».fromJSOG(jsog['content'],new Map()),structureOnly:true);
		  								js.context.callMethod('update_routing_«g.name.lowEscapeDart»',[currentGraphModel.router,currentGraphModel.connector]);
		  								js.context.callMethod('update_scale_«g.name.lowEscapeDart»',[currentGraphModel.scale]);
		  							}).then((_) => endPropagation());
		  						} else {
		  							var m = Message.fromJSOG(jsog['content']);
		  							startPropagation().then((_) {
		  								if (m is CompoundCommandMessage) {
		  									commandGraph.receiveCommand(m,forceExecute: true);
		  								}
		  								if (m is PropertyMessage) {
  											var elem = currentGraphModel.allElements().firstWhere((n) =>
	  										n.dywaId == m.delegate.dywaId);
											elem.merge(m.delegate, structureOnly:true);
											updateProperties(elem);
		  								}
		  							}).then((_) => endPropagation());
		  						}
		  					}
		  				}
		  			});
		  			this.webSocketGraphModel.onClose.listen((html.CloseEvent e) {
		  				if(e.code == 4001) {
		  					//graphmodel has been deleted or access denied
		  					close.emit({});
		  				}
		  				html.window.console.debug("[PYRO] onClose GraphModel Websocket");
		  			});
		  			this.webSocketGraphModel.onError.listen((e) {
		  				html.window.console.debug("[PYRO] Error on GraphModel Websocket: ${e.toString()}");
		  			});
		  		}
		  	}
		  
		  void initCanvas() {
		  	graphService.loadCommandGraph«g.name.fuEscapeDart»(currentGraphModel).then((cg){
		  	  	commandGraph = cg;
		  	  	currentGraphModel.merge(cg.currentGraphModel);
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
		  	 	      cb_update_bendpoint,
		  	 	      cb_can_move_node,
		  	 	      cb_can_connect_edge,
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
		  	 	      		cb_reconnect_edge_«elem.name.lowEscapeDart»
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
		         closeWebSocket();
		         //rebuild
		         initCanvas();
		         activateWebSocket();
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
		   	graphService.updateGraphModel(currentGraphModel).then((_){
		   		js.context.callMethod('update_scale_«g.name.lowEscapeDart»',[currentGraphModel.scale]);
		   	});
		   }
		   
		   void updateRouting() {
		   	graphService.updateGraphModel(currentGraphModel).then((_){
		   		js.context.callMethod('update_routing_«g.name.lowEscapeDart»',[currentGraphModel.router,currentGraphModel.connector]);
		   	});
		   }
		
		   void updateProperties(IdentifiableElement ie) {
		   	if(ie is! GraphModel){
				updateElement(ie);
			} else {
				if(ie is «g.name.fuEscapeDart»){
					currentGraphModel.merge(ie,structureOnly:false);
				}
			}
			//check for prime referencable element in same graph and update
			«FOR pr:g.primeRefs.filter[referencedElement.graphModel.equals(g)]»
				if(ie is «pr.referencedElement.name.fuEscapeDart») {
					//update all prime nodes for this element
					
					currentGraphModel.allElements()
						.where((n)=>n is «(pr.eContainer as ModelElement).name.fuEscapeDart»)
						.forEach((n)=>updateElement(n));
				}
			«ENDFOR»
		   }
		   
		  void undo() {
		  	var ccm = commandGraph.undo(user);
		  	if(ccm!=null) {
		  	  graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m) {
		  	«'''
		  	    «'''
		  	      commandGraph.receiveCommand(ccm);
		  	    '''.checkCommand("undo_valid_answer",false)»
		  	'''.propagation»
		  	  });
		  	}
		  }
		  
		  void redo() {
		  var ccm = commandGraph.redo(user);
		    if(ccm!=null) {
		      graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m) {
		 	«'''
		      	«'''
		        commandGraph.receiveCommand(ccm);
		      	'''.checkCommand("redo_valid_answer",false)»
		  	'''.propagation»
		      });
		    }
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
			 
		 	 IdentifiableElement findElement(int dywaId) {
		 		 if(dywaId==currentGraphModel.dywaId){
		 			 return currentGraphModel;
		 		 }
		 		 return currentGraphModel.allElements().firstWhere((n)=>n.dywaId==dywaId);
		 	 }
			 
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
		 	
		 	dynamic cb_can_move_node(int dywaId,int containerId) {
		 		var node = findElement(dywaId) as Node;
		 		var container = findElement(containerId) as ModelElementContainer;
		 		if(node.container.dywaId!=container.dywaId)
		 		{
		 		  if(container is «g.name.fuEscapeDart»)
		 		  {
		 			«g.containmemntCheck(g)»
		 		  }
		 			«FOR container:g.nodes.filter(NodeContainer)»
		 		  if(container is «container.name.fuEscapeDart»)
		 		  {
		 			  «container.containmemntCheck(g)»
		 		  }
		 			«ENDFOR»
		 		  return {
		 			'x':node.x,
		 			'y':node.y,
		 			'containerId':node.container.dywaId
		 			};
		 		}
		 		return true;
		 	}
		 	
		 	dynamic cb_can_connect_edge(int dywaId,int sourceId,int targetId) {
		 		var edge = findElement(dywaId) as Edge;
		 		var source = findElement(sourceId) as Node;
		 		var target = findElement(targetId) as Node;
		 		if(edge.source.dywaId==sourceId){
		 			//target changed
		 			«FOR n:g.nodes»
		 			if(target is «n.name.fuEscapeDart»){
		 				
		 				«FOR edge:g.edges»
			 				if(edge is «edge.name.fuEscapeDart»)
			 				{
		 					«IF !n.incomingEdgeConnections.filter[cotainesEdge(edge)].empty»
			 				var incoming = target.incoming;
			 				«ENDIF»
			 				«FOR group:n.incomingEdgeConnections.filter[cotainesEdge(edge)].indexed»
					 				int groupSize«group.key» = 0;
			 							«FOR outgoingEdge:group.value.connectingEdges»
					 				groupSize«group.key» += incoming.where((n)=>n is «outgoingEdge.name.fuEscapeDart»).length;
			 							«ENDFOR»
			 							«IF group.value.connectingEdges.nullOrEmpty»
					 				groupSize«group.key» += incoming.length;
			 							«ENDIF»
					 				if(«IF group.value.upperBound < 0»true«ELSE»groupSize«group.key»<«group.value.upperBound»«ENDIF»)
					 				{
					 					return true;
					 				}
			 				«ENDFOR»
			 				}
		 				«ENDFOR»
		 			}
		 			«ENDFOR»
		 			
		 		} else {
		 			//source changed
		 			«FOR n:g.nodes»
			 			if(source is «n.name.fuEscapeDart»){
			 				«FOR edge:g.edges»
			 				if(edge is «edge.name.fuEscapeDart»)
			 				{
				 				«IF !n.outgoingEdgeConnections.filter[cotainesEdge(edge)].empty»
				 					var outgoing = target.outgoing;
				 				«ENDIF»
				 				
				 				«FOR group:n.outgoingEdgeConnections.filter[cotainesEdge(edge)].indexed»
						 				int groupSize«group.key» = 0;
				 							«FOR incomingEdge:group.value.connectingEdges»
						 				groupSize«group.key» += outgoing.where((n)=>n is «incomingEdge.name.fuEscapeDart»).length;
				 							«ENDFOR»
				 							«IF group.value.connectingEdges.empty»
						 				groupSize«group.key» += outgoing.length;
				 							«ENDIF»
						 				if(«IF group.value.upperBound < 0»true«ELSE»groupSize«group.key»<«group.value.upperBound»«ENDIF»)
						 				{
						 					return true;
						 				}
				 				«ENDFOR»
			 				}
			 				«ENDFOR»
			 			}
		 			«ENDFOR»
		 		}
		 		return {
					'target':edge.target.dywaId,
					'source':edge.source.dywaId
				};
		 	}
		 	
		 	void remove_node_cascade(Node node) {
		 		if(node == null){ return; }
		 		«FOR node : g.nodes»
		 		else if(node is «node.name.fuEscapeDart») { remove_node_cascade_«node.name.lowEscapeDart»(node); }
		 		«ENDFOR»
		 	}
			 
			 //for each node
			 «FOR node : g.nodes»
			 	void create_node_«node.name.lowEscapeDart»(«node.name.escapeDart» node) {
			 	    js.context.callMethod('create_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»',
			 	    [ node.x,
			 	    	node.y,
			 	    	node.width,
			 	    	node.height,
			 	    	node.dywaId,
			 	    	node.container.dywaId,
			 	    	node.dywaName,
			 	    	node.dywaVersion,
			 	    	node.styleArgs() ]);
			 	}
			 	
			 	void cb_create_node_«node.name.lowEscapeDart»(int x,int y,int width,int height,String cellId,int containerId«IF node.isPrime»,int primeId«ENDIF») {
			 		var container = findElement(containerId) as ModelElementContainer;
			 	    var ccm = commandGraph.sendCreateNodeCommand("«g.name.lowEscapeDart».«node.name.escapeDart»",x,y,containerId,width,height,user«IF node.isPrime»,primeId:primeId«ENDIF»);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    		«'''
			 		   		var cmd = m.cmd.queue.first;
			 		   		if(cmd is CreateNodeCommand){
			 		   			var node = new «node.name.escapeDart»();
			 		   			node.x = x;
			 		   			node.y = y;
			 		   			node.dywaId = cmd.delegateId;
			 		   			node.dywaName = cmd.dywaName;
			 		   			node.dywaVersion = cmd.dywaVersion;
			 		   			node.container = container;
			 		   			container.modelElements.add(node);
			 		   			«IF node.prime»
									//prime node -> update element properties
									var primeElem = cmd.primeElement;
									var elements = currentGraphModel.allElements().where((n)=>n.dywaId==primeElem.dywaId);
									if(elements.isNotEmpty){
										node.«node.primeReference.name.escapeDart» = elements.first;
									} else {
										node.«node.primeReference.name.escapeDart» = primeElem;
									}
			 		   			«ENDIF»
			 		   			updateElement(node,cellId: cellId);
			 		   			commandGraph.storeCommand(m.cmd);
			 		   			if(container is! GraphModel){
			 		   				updateElement(container as ModelElement);
			 		   			}
			 		   			selectionChanged.emit(node);
			 		   		}
		 	    	  	'''.checkCommand("basic_valid_answer")»
			 	    });
			 	}
			 	
			 	void remove_node_cascade_«node.name.lowEscapeDart»(«node.name.fuEscapeDart» node) {
			 		«IF node instanceof NodeContainer»
			 		node.modelElements.where((n)=>n is Node).forEach((n)=>remove_node_cascade(n));
			 		«ENDIF»
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
			 		js.context.callMethod('remove_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»', [node.dywaId]);
			 	}
			 	
			 	void cb_remove_node_«node.name.lowEscapeDart»(int dywaId) {
			 		var node = findElement(dywaId) as «node.name.fuEscapeDart»;
			 		var container = findElement(node.container.dywaId) as ModelElementContainer;
			 	    var ccm = commandGraph.sendRemoveNodeCommand(dywaId,user);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    		«'''
			 	    		selectionChanged.emit(currentGraphModel);
			 	    		container.modelElements.remove(node);
			 	    		node.container = null;
			 	    			«'''
			 	    			remove_node_cascade_«node.name.lowEscapeDart»(node);
			 	    			commandGraph.storeCommand(m.cmd);
			 	    			if(container is! GraphModel){
			 	    			updateElement(container as ModelElement);
			 	    			}
			 	    			'''.propagation»
		 	    	  	'''.checkCommand("basic_valid_answer")»
			 	    });
			 	}
			 	
			 	void cb_move_node_«node.name.lowEscapeDart»(int x,int y,int dywaId,containerId) {
			 		var container = findElement(containerId) as ModelElementContainer;
			 		var node = findElement(dywaId) as Node;
			 		if(node.x==x&&node.y==y){
			 			return;
			 		}
			 	    var ccm = commandGraph.sendMoveNodeCommand(dywaId,x,y,containerId,user);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    		«'''
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
			 	    		commandGraph.storeCommand(m.cmd);
		 	    	  	'''.checkCommand("basic_valid_answer")»
			 	   });
			 	}
			 	
			 	void cb_resize_node_«node.name.lowEscapeDart»(int width,int height,String direction,int dywaId) {
			 		var node = findElement(dywaId) as Node;
			 		if(node.width!=width||node.height!=height) {
			 	      var ccm = commandGraph.sendResizeNodeCommand(dywaId,width,height,direction,user);
			 	      graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    		«'''
			 	    		node.width = width;
			 	    		node.height = height;
			 	    		updateElement(node);
			 	    		commandGraph.storeCommand(m.cmd);
		 	    	  	'''.checkCommand("basic_valid_answer")»
			 	     });
			 	   }
			 	}
			 	
			 	void cb_rotate_node_«node.name.lowEscapeDart»(int angle,int dywaId) {
			 		var node = findElement(dywaId) as Node;
			 	    var ccm =commandGraph.sendRotateNodeCommand(dywaId,angle,user);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    		«'''
			 	    		node.angle = angle;
			 	    		updateElement(node);
			 	    		commandGraph.storeCommand(m.cmd);
		 	    	  	'''.checkCommand("basic_valid_answer")»
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
			 	    edge.bendingPoints.isEmpty?null:edge.bendingPoints.map((n){
			 	    	return {'x':n.x,'y':n.y};
			 	    }).toList(),
			 	    edge.styleArgs() ]);
			 	}
			 	
			 	void cb_create_edge_«edge.name.lowEscapeDart»(int sourceId,int targetId,String cellId, List positions) {
			 		var source = findElement(sourceId) as Node;
			 		var target = findElement(targetId) as Node;
			 		var currentBendpoints = new List<BendingPoint>();
			 		if(positions!=null){
			 		  positions.forEach((p){
			 			var b = new BendingPoint();
			 			b.x = p['x'];
			 			b.y = p['y'];
			 			currentBendpoints.add(b);
			 		  });
			 		}
			 	    var ccm = commandGraph.sendCreateEdgeCommand("«g.name.lowEscapeDart».«edge.name.escapeDart»",targetId,sourceId,currentBendpoints,user);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
			 			«'''
			 			var cmd = m.cmd.queue.first;
			 			if(cmd is CreateEdgeCommand){
			 				var edge = new «edge.name.escapeDart»();
			 				edge.dywaId = cmd.delegateId;
			 				edge.dywaVersion = cmd.dywaVersion;
			 				edge.dywaName = cmd.dywaName;
			 				edge.container = currentGraphModel;
			 				currentGraphModel.modelElements.add(edge);
			 				edge.source = source;
			 				source.outgoing.add(edge);
			 				edge.target = target;
			 				target.incoming.add(edge);
			 				edge.bendingPoints = new List.from(currentBendpoints);
			 				updateElement(edge,cellId: cellId);
			 				updateElement(source);
			 				updateElement(target);
			 				ccm.cmd.queue.first.delegateId=edge.dywaId;
			 				commandGraph.storeCommand(m.cmd);
			 				selectionChanged.emit(edge);
			 			}
			 			'''.checkCommand("basic_valid_answer")»
			 	    });
			 	}
			 	
			 	void cb_remove_edge_«edge.name.lowEscapeDart»(int dywaId) {
			 		var edge = findElement(dywaId) as Edge;
			 	    var ccm = commandGraph.sendRemoveEdgeCommand(dywaId,edge.source.dywaId,edge.target.dywaId,"«g.name.lowEscapeDart».«edge.name.escapeDart»",user);
			 	    graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
			 	    		«'''
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
			 	    		commandGraph.storeCommand(m.cmd);
			 	    		'''.checkCommand("basic_valid_answer")»
			 		});
			 	}
			 	
			 	void cb_reconnect_edge_«edge.name.lowEscapeDart»(int sourceId,int targetId,int dywaId,) {
			 		var edge = findElement(dywaId) as Edge;
			 		var source = findElement(sourceId) as Node;
			 		var target = findElement(targetId) as Node;
			 		if(edge.source.dywaId!=sourceId||edge.target.dywaId!=targetId) {
			 	    	var ccm = commandGraph.sendReconnectEdgeCommand(dywaId,sourceId,targetId,user);
			 	    	graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
				 	    		«'''
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
			 	    			commandGraph.storeCommand(m.cmd);
				 	    	  	'''.checkCommand("basic_valid_answer")»
			 	    	});
			 	    }
			 	}
			 	
		«ENDFOR»
		 	void cb_update_bendpoint(List positions,int dywaId) {
		 		var edge = findElement(dywaId) as Edge;
		 		//check if update is present
		 		if(check_bendpoint_update(edge,positions)) {
		 		var currentBendpoints = new List<BendingPoint>();
		 		positions.forEach((p){
		 			var b = new BendingPoint();
					b.x = p['x'];
					b.y = p['y'];
					currentBendpoints.add(b);
		 		});
		 	      var ccm = commandGraph.sendUpdateBendPointCommand(dywaId,currentBendpoints,new List.from(edge.bendingPoints),user);
		 	      graphService.sendMessage(ccm,"«g.name.lowEscapeJava»",currentGraphModel.dywaId).then((m){
		 	    	  	«'''
		 	    		edge.bendingPoints = new List();
		 	    		positions.forEach((p){
		 	    			var b = new BendingPoint();
		 	    			b.x = p['x'];
		 	    			b.y = p['y'];
		 	    			edge.bendingPoints.add(b);
		 	    		});
		 	    		commandGraph.storeCommand(m.cmd);
		 	    	  	'''.checkCommand("basic_valid_answer")»
		 	      });
		 		}
		 	}
		
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
	
	def boolean cotainesEdge(EdgeElementConnection c, Edge edge) {
		c.connectingEdges.contains(edge)||c.connectingEdges.nullOrEmpty
	}

	def checkCommand(CharSequence s,String type)
	{
		return checkCommand(s,type,true)
	}

	def checkCommand(CharSequence s,String type,boolean revert)
	'''
	if(m is CompoundCommandMessage){
		if(m.type=='«type»'){
			«s»
		}
		«IF revert»
		else {
			//revert
			commandGraph.revert(m);
		}
		«ENDIF»
	}
	'''

	def fileNameGraphModelComponentTemplate(String graphmodelName) '''«graphmodelName.lowEscapeDart»_component.html'''

	def contentGraphModelComponentTemplate(
		GraphModel g) '''
		<div style="overflow: auto;">
			<div ondragover="confirm_drop_«g.name.lowEscapeDart»(event)" ondrop="drop_on_canvas_«g.name.lowEscapeDart»(event)" id="paper_«g.name.lowEscapeDart»" style="border: gray;
			   	border-width: 5px;
			   border-style: solid;"></div>
		</div>
	'''
	
	def containmemntCheck(ContainingElement container,GraphModel g)
	'''
			 			«IF container.containableElements.empty»
			 				return true;
			 			«ELSE»
			 				«FOR group:container.containableElements.get(0).containingElement.containableElements.indexed»
			 				 	//check if type can be contained in group
			 				 	if(
			 				«FOR containableTypeName:group.value.types.map[name].map[subTypes(g)].flatten.toSet SEPARATOR "||"»
			 				 		node is «containableTypeName.name.fuEscapeDart»
			 				«ENDFOR»
			 				 	) {
			 				«IF group.value.upperBound>-1»
			 					int group«group.key»Size = 0;
			 					«FOR containableType:group.value.types.map[name].map[subTypes(g)].flatten.toSet»
			 					 	group«group.key»Size += container.modelElements.where((n)=>n is «containableType.name.fuEscapeDart»).length;
			 					«ENDFOR»
			 					if(«IF group.value.upperBound>-1»group«group.key»Size<«group.value.upperBound»«ELSE»true«ENDIF»){
			 					 	return true;
			 					}
			 				«ELSE»
			 					return true;
			 				«ENDIF»
			 				}
			 				«ENDFOR»
			 				return {
			 				 	'x':node.x,
			 				 	'y':node.y,
			 				 	'containerId':node.container.dywaId
			 				};
			 			«ENDIF»
	'''
}
