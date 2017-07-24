package de.jabc.cinco.meta.plugin.pyro.canvas

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import java.util.HashMap
import java.util.LinkedList
import java.util.List
import java.util.Map
import java.util.regex.Matcher
import java.util.regex.Pattern
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.IncomingEdgeElementConnection
import mgl.Node
import mgl.NodeContainer
import mgl.OutgoingEdgeElementConnection
import org.eclipse.emf.ecore.EObject
import style.MultiText
import style.NodeStyle
import style.Text
import style.Styles
import style.EdgeStyle

class Controller extends Generatable{
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameController() '''controller.js'''

	def contentController(GraphModel g,Styles styles)
	'''
	var $graph_«g.name.lowEscapeDart» = null;
	var $paper_«g.name.lowEscapeDart» = null;
	var $router_«g.name.lowEscapeDart» = 'manhattan';
	var $connector_«g.name.lowEscapeDart» = 'rounded';
	var $graphmodel_id_«g.name.lowEscapeDart» = -1;
	var $_disable_events_«g.name.lowEscapeDart» = true;
	
	
	var $cb_functions_«g.name.lowEscapeDart» = {};
	
	function load_«g.name.lowEscapeDart»(
	    w,
	    h,
	    scale,
	    graphmodelid,
	    router,
	    connector,
	    //callback afert initialization
	    initialized,
	    //message callbacks
	    cb_element_selected,
	    cb_graphmodel_selected,
	    cb_update_bendpoint,
	    cb_can_move_node,
	    «FOR elem:g.nodes + g.edges SEPARATOR ","»
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
	    
	) {
	    $router_«g.name.lowEscapeDart» = router;
	    $graphmodel_id_«g.name.lowEscapeDart» = graphmodelid;
	    $connector_«g.name.lowEscapeDart» = connector;
	
	    $cb_functions_«g.name.lowEscapeDart» = {
		    cb_update_bendpoint:cb_update_bendpoint,
		    cb_can_move_node:cb_can_move_node,
	    	«FOR elem:g.nodes + g.edges SEPARATOR ","»
		    	«IF elem instanceof Node»
		    cb_create_node_«elem.name.lowEscapeDart»:cb_create_node_«elem.name.lowEscapeDart»,
		    cb_remove_node_«elem.name.lowEscapeDart»:cb_remove_node_«elem.name.lowEscapeDart»,
		    cb_move_node_«elem.name.lowEscapeDart»:cb_move_node_«elem.name.lowEscapeDart»,
		    cb_resize_node_«elem.name.lowEscapeDart»:cb_resize_node_«elem.name.lowEscapeDart»,
		    cb_rotate_node_«elem.name.lowEscapeDart»:cb_rotate_node_«elem.name.lowEscapeDart»
		    	«ENDIF»
		    	«IF elem instanceof Edge»
			cb_create_edge_«elem.name.lowEscapeDart»:cb_create_edge_«elem.name.lowEscapeDart»,
			cb_remove_edge_«elem.name.lowEscapeDart»:cb_remove_edge_«elem.name.lowEscapeDart»,
			cb_reconnect_edge_«elem.name.lowEscapeDart»:cb_reconnect_edge_«elem.name.lowEscapeDart»
		    	«ENDIF»
		    «ENDFOR»
	    };
	
	    $graph_«g.name.lowEscapeDart» = new joint.dia.Graph;
	    $paper_«g.name.lowEscapeDart» = new joint.dia.Paper({
	
	        el: document.getElementById('paper_«g.name.lowEscapeDart»'),
	        width: w,
	        height: h,
	        gridSize: 1,
	        model: $graph_«g.name.lowEscapeDart»,
	        snapLinks: false,
	        linkPinning: false,
	        elementView: constraint_element_view(),
	        embeddingMode: true,
	
	        highlighting: {
	            'default': {
	                name: 'stroke',
	                options: {
	                    padding: 6
	                }
	            },
	            'embedding': {
	                name: 'addClass',
	                options: {
	                    className: 'highlighted-parent'
	                }
	            }
	        },
	        validateEmbedding: function(childView, parentView) {
	            return true;
	        },
	
	        validateConnection: function(cellViewS, magnetS, cellViewT, magnetT, end, linkView) {
	            return true;
	        }
	    });
	    $paper_«g.name.lowEscapeDart».options.multiLinks = false;
	    $paper_«g.name.lowEscapeDart».options.markAvailable = true;
	    $paper_«g.name.lowEscapeDart».options.restrictTranslate=false;
	    $paper_«g.name.lowEscapeDart».options.drawGrid= { name: 'mesh', args: { color: 'black' }};
		$paper_«g.name.lowEscapeDart».scale(scale);
		
	    /*
	    Register event listener triggering the callbacks to the NG-App
	     */
	
	    /**
	     * Graphmodel (Canvas) has been clicked
	     */
	    $paper_«g.name.lowEscapeDart».on('blank:pointerclick', function(evt, x, y) {
	    	remove_edge_creation_menu();
	        deselect_all_elements($paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	        cb_graphmodel_selected();
	        console.log("graphmodel clicked");
	    });
	
	    /**
	     * Element has been selected
	     * change selection
	     * show properties
	     */
	    $paper_«g.name.lowEscapeDart».on('cell:pointerclick', function(cellView,evt, x, y) {
	    	remove_edge_creation_menu();
	        update_selection(cellView,$paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	        cb_element_selected(cellView.model.attributes.attrs.dywaId);
	        console.log(cellView);
	        console.log("element clicked");
	    });
	    
	    /**
	     * Element has been selected
	     * change selection
	     * show properties
	     */
	     $paper_«g.name.lowEscapeDart».on('cell:pointerup', function(cellView,evt) {
	     	if(cellView.model.attributes.attrs.isDeleted!==true) {
		        update_selection(cellView,$paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	 	        cb_element_selected(cellView.model.attributes.attrs.dywaId);
	 	        «FOR node:g.nodes»
	 	        if(cellView.model.attributes.type=='«g.name.lowEscapeDart».«node.name.escapeDart»'){
	 	        	//check if container has changed
	 	        	move_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»_hook(cellView);
	 	        	$cb_functions_«g.name.lowEscapeDart».cb_resize_node_«node.name.lowEscapeDart»(cellView.model.attributes.size.width,cellView.model.attributes.size.height,cellView.model.attributes.attrs.dywaId);
	 	        }
	 	        «ENDFOR»
	 	        «FOR edge:g.edges»
	 	        if(cellView.model.attributes.type=='«g.name.lowEscapeDart».«edge.name.escapeDart»'){
	 	        	var source = $graph_«g.name.lowEscapeDart».getCell(cellView.model.attributes.source.id);
	 	        	var target = $graph_«g.name.lowEscapeDart».getCell(cellView.model.attributes.target.id);
	 	        	$cb_functions_«g.name.lowEscapeDart».cb_reconnect_edge_«edge.name.lowEscapeDart»(
	 	        		source.attributes.attrs.dywaId,
	 	        		target.attributes.attrs.dywaId,
	 	        		cellView.model.attributes.attrs.dywaId
	 	        	);
	 	        	$cb_functions_«g.name.lowEscapeDart».cb_update_bendpoint(
	 	        		cellView.model.attributes.vertices,
	 	        		cellView.model.attributes.attrs.dywaId
	 	        	);
	 	        }
	 	        «ENDFOR»
		         console.log(cellView);
		         console.log("element clicked");
	        }
	     });
	
	    /**
	     * Element has been added
	     * change selection
	     * show properties
	     */
	    $graph_«g.name.lowEscapeDart».on('add', function(cellView) {
	    	if(!$_disable_events_«g.name.lowEscapeDart» && cellView.attributes.type!=='pyro.PyroLink'){
	    		update_selection($paper_«g.name.lowEscapeDart».findViewByModel(cellView),$paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
«««		        //for each node
«««		        «FOR node:g.nodes»
«««		        if(cellView.attributes.type==='«g.name.lowEscapeDart».«node.name.escapeDart»') {
«««		        	var node = $graph_«g.name.lowEscapeDart».getCell(cellView.attributes.id);
«««		            var parentId = $graphmodel_id_«g.name.lowEscapeDart»;
«««		            if(node.parent != null){
«««		                parentId = node.parent.model.attrs.dywaId;
«««		            }
«««		            $cb_functions_«g.name.lowEscapeDart».cb_create_node_«node.name.lowEscapeDart»(cellView.attributes.position.x, cellView.attributes.position.y, cellView.attributes.id,parentId);
«««		        }
«««		        «ENDFOR»
		        //for each edge
		        «FOR edge:g.edges»
		        if(cellView.attributes.type==='«g.name.lowEscapeDart».«edge.name.escapeDart»') {
		            var link = $graph_«g.name.lowEscapeDart».getCell(cellView.attributes.id);
		            var source = link.getSourceElement();
		            var target = link.getTargetElement();
		            $cb_functions_«g.name.lowEscapeDart».cb_create_edge_«edge.name.lowEscapeDart»(
		              source.attributes.attrs.dywaId,
		              target.attributes.attrs.dywaId,
		              cellView.attributes.id,
		              cellView.attributes.vertices
		            );
		        }
		        «ENDFOR»
		        console.log(cellView);
		        console.log("element added");
	        }
	    });
	
		function remove_cascade_node_flowgraph(cellView) {
			if(!$_disable_events_«g.name.lowEscapeDart»){
				 deselect_all_elements($paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
				 //trigger callback
				 cb_graphmodel_selected();
				 //foreach node
				 «FOR node:g.nodes»
				        if(cellView.attributes.type==='«g.name.lowEscapeDart».«node.name.escapeDart»'){
				            $cb_functions_«g.name.lowEscapeDart».cb_remove_node_«node.name.lowEscapeDart»(cellView.attributes.attrs.dywaId);
				        }
				 «ENDFOR»
			}
		
		}
	
	    /**
	     * Element has been removed
	     * change selection to the graphmodel
	     * show properties
	     */
	    $graph_«g.name.lowEscapeDart».on('remove', function(cellView) {
	    	if(!$_disable_events_«g.name.lowEscapeDart»){
		        deselect_all_elements($paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
		        //trigger callback
		        cb_graphmodel_selected();
		        //foreach node
«««		        «FOR node:g.nodes»
«««		        if(cellView.attributes.type==='«g.name.lowEscapeDart».«node.name.escapeDart»'){
«««		            $cb_functions_«g.name.lowEscapeDart».cb_remove_node_«node.name.lowEscapeDart»(cellView.attributes.attrs.dywaId);
«««		        }
«««		        «ENDFOR»
		        //foreach edge
		        «FOR edge:g.edges»
		        if(cellView.attributes.type==='«g.name.lowEscapeDart».«edge.name.escapeDart»'){
		        	cellView.attributes.attrs.isDeleted = true;
		            $cb_functions_«g.name.lowEscapeDart».cb_remove_edge_«edge.name.lowEscapeDart»(cellView.attributes.attrs.dywaId);
		        }
		        «ENDFOR»
		        console.log(cellView);
		        console.log("element removed");
	        }
	    });
	    
	    $(document).off('mouseup');
	    $(document).mouseup(function (evt) {
	        $mouse_clicked_menu=false;
	        if($temp_link!==null && !$edge_menu_shown)
	        {
	           var rp = getRelativeScreenPosition(evt.clientX,evt.clientY,$paper_«g.name.lowEscapeDart»);
	           var views = $paper_«g.name.lowEscapeDart».findViewsFromPoint(rp);
	           if(views.length > 0)
	           {
	             «edgecreation(g)»
	           }
	           var pyroLink = $graph_«g.name.lowEscapeDart».getCell($temp_link.model.id);
	           $graph_«g.name.lowEscapeDart».removeCells([pyroLink]);
	           $temp_link=null;
	        }
	    });
	
	    init_event_system($paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»,remove_cascade_node_flowgraph);
	    
	    create_«g.name.lowEscapeDart»_map();
	
	    //callback after initialization
	    initialized();
	}
	
	function start_propagation_«g.name.lowEscapeDart»() {
	    block_user_interaction($paper_«g.name.lowEscapeDart»);
	    $_disable_events_«g.name.lowEscapeDart» = true;
	}
	function end_propagation_«g.name.lowEscapeDart»() {
	    unblock_user_interaction($paper_«g.name.lowEscapeDart»);
	    $_disable_events_«g.name.lowEscapeDart» = false;
	}
	
	function destroy_«g.name.lowEscapeDart»() {
	    block_user_interaction($paper_«g.name.lowEscapeDart»);
	    deselect_all_elements($paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	    $paper_«g.name.lowEscapeDart» = null;
	    $graph_«g.name.lowEscapeDart» = null;
	    $('#paper_«g.name.lowEscapeDart»').empty();
	    $('#paper_map_«g.name.lowEscapeDart»').empty();
	}
	
	
	function create_«g.name.lowEscapeDart»_map() {
		var map = $('#paper_map_«g.name.lowEscapeDart»');
		if(map.length) {
			//create map
			var paperSmall = new joint.dia.Paper({
			    el: map,
			    width: '100%',
			    height: 300,
			    model: $graph_«g.name.lowEscapeDart»,
			    gridSize: 1
			});
			paperSmall.scale(.5);
			paperSmall.$el.css('pointer-events', 'none');
		}
	}
	
	
	/*
	 Settings handling methods to be called from the NG-App
	 */
	
	function update_routing_«g.name.lowEscapeDart»(routing,connector) {
	    update_edeg_routing(routing,connector,$graph_«g.name.lowEscapeDart»);
	}
	
	function update_scale_«g.name.lowEscapeDart»(scale) {
	    $paper_«g.name.lowEscapeDart».scale(scale);
	}
	
	/*
	Element handling methods to be called from the NG-App
	 */
	
	/**
	 *
	 * @param cellId
	 * @param dywaId
	 * @param dywaVersion
	 * @param dywaName
	 * @param styleArgs
	 */
	function update_element_«g.name.lowEscapeDart»(cellId,dywaId,dywaVersion,dywaName,styleArgs) {
		if(styleArgs!==null) {
			var elem = findElementByDywaId(dywaId,$graph_«g.name.lowEscapeDart»);
			if(cellId!=null&&elem==null){
			   elem = $graph_«g.name.lowEscapeDart».getCell(cellId);
			}
			var cell = $paper_«g.name.lowEscapeDart».findViewByModel(elem);
			«FOR node:g.nodes»
			«{
				val styleForNode = new Shapes(gc,g).styling(node,styles) as NodeStyle
				'''
				if(cell.model.attributes.type==='«g.name.lowEscapeDart».«node.name.fuEscapeDart»') {
					«styleForNode.updateStyleArgs(g)»
				}
				'''
			}»
			«ENDFOR»
			«FOR edge:g.edges»
			«{
				val styleForEdge = new Shapes(gc,g).styling(edge,styles) as EdgeStyle
				'''
				if(cell.model.attributes.type==='«g.name.lowEscapeDart».«edge.name.fuEscapeDart»') {
					«styleForEdge.updateStyleArgs»
				}
				'''
			}»
			«ENDFOR»
		}
	    update_element_internal(cellId,dywaId,dywaName,dywaVersion,styleArgs,$graph_«g.name.lowEscapeDart»);
	}
	
	«FOR node:g.nodes»
		/**
		 * creates a «node.name.escapeDart» node in position
		 * this method is called by th NG-App
		 * @param x
		 * @param y
		 * @param dywaId
		 * @param containerId
		 * @param dywaName
		 * @param dywaVersion
		 * @param styleArgs
		 * @returns {*}
		 */
		function create_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(x,y,dywaId,containerId,dywaName,dywaVersion,styleArgs) {
		    var elem = new joint.shapes.«g.name.lowEscapeDart».«node.name.escapeDart»({
		        position: {
		            x: x,
		            y: y
		        },
		        attrs:{
		            dywaId:dywaId,
		            dywaName:dywaName,
		            dywaVersion:dywaVersion
		        }
		    });
		    add_node_internal(elem,$graph_«g.name.lowEscapeDart»,$paper_«g.name.lowEscapeDart»);
		    if(containerId>-1&&containerId!=$graphmodel_id_«g.name.lowEscapeDart»){
		    	findElementByDywaId(containerId,$graph_«g.name.lowEscapeDart»).embed(elem);
			}
			update_element_«g.name.lowEscapeDart»(elem.attributes.id,dywaId,dywaVersion,dywaName,styleArgs);
		    if(!$_disable_events_«g.name.lowEscapeDart»){
		    	$cb_functions_«g.name.lowEscapeDart».cb_create_node_«node.name.lowEscapeDart»(x, y, elem.attributes.id,containerId);
		    }
		    return 'ready';
		}
		
		function move_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»_hook(elem) {
			if(!$_disable_events_«g.name.lowEscapeDart»){
				var parentId = $graphmodel_id_«g.name.lowEscapeDart»;
			    if(elem.model.attributes.parent != null){
			         parentId = $graph_«g.name.lowEscapeDart».getCell(elem.model.attributes.parent).attributes.attrs.dywaId;
			    }
			    //check if the container change was allowed
			    var valid = $cb_functions_«g.name.lowEscapeDart».cb_can_move_node(elem.model.attributes.attrs.dywaId,parentId);
			    if(valid===true) {
			    	//movement has been valid
				    $cb_functions_«g.name.lowEscapeDart».cb_move_node_«node.name.lowEscapeDart»(elem.model.attributes.position.x,elem.model.attributes.position.y,elem.model.attributes.attrs.dywaId,parentId);
			    } else {
			    	//movement is not valid and has to be reseted
			    	var preX = valid.o['_strings']['x'].hashMapCellValue;
			    	var preY = valid.o['_strings']['y'].hashMapCellValue;
			    	var preContainerDywaId = valid.o['_strings']['containerId'].hashMapCellValue;
			    	//remove the containement
				    $graph_«g.name.lowEscapeDart».getCell(elem.model.attributes.parent).unembed($graph_«g.name.lowEscapeDart».getCell(elem.model.id));
			    	//check if the pre container was not the graphmodel
			    	if(preContainerDywaId!==$graphmodel_id_«g.name.lowEscapeDart»)
			    	{
			    		//embed the node in the precontainer
				    	var parentCell = findElementByDywaId(preContainerDywaId,$graph_«g.name.lowEscapeDart»);
				    	parentCell.embed(elem.model);
				    	//move back
				    	elem.model.position(preX,preY,{ parentRealtive: true });
			    	}
			    	else {
				    	//move back
			    		elem.model.position(preX,preY);
			    	}
			    	
			    }
		        console.log("node «g.name.lowEscapeDart» change position");
		    }
		}
		
		/**
		 * moves the «node.name.escapeDart» node to another position, relative to its parent container
		 * if the container id is provided (containerId != -1). the node is
		 * embedded in the given container
		 * this method is called by th NG-App
		 * 
		 * @param x
		 * @param y
		 * @param dywaId
		 * @param containerId
		 */
		function move_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(x,y,dywaId,containerId) {
		    if(containerId==$graphmodel_id_«g.name.lowEscapeDart»){
		        move_node_internal(x,y,dywaId,-1,$graph_«g.name.lowEscapeDart»);
		    } else {
		        move_node_internal(x,y,dywaId,containerId,$graph_«g.name.lowEscapeDart»);
		    }
		    return 'ready';
		}
		
		/**
		 * removes the «node.name.escapeDart» node by id
		 * this method is called by th NG-App
		 * @param dywaId
		 */
		function remove_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(dywaId) {
		    remove_node_internal(dywaId,$graph_«g.name.lowEscapeDart»);
		    return 'ready';
		}
		
		/**
		 * resizes the «node.name.escapeDart» node by id depended on the 
		 * given absolute width and height
		 * this method is called by th NG-App
		 * @param width
		 * @param height
		 * @param dywaId
		 */
		function resize_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(width,height,dywaId) {
		    resize_node_internal(width,height,dywaId,$graph_«g.name.lowEscapeDart»,$paper_«g.name.lowEscapeDart»);
		    return 'ready';
		}
		
		/**
		 * rotates the «node.name.escapeDart» node by id depended on the 
		 * given on the absolute angle
		 * this method is called by th NG-App
		 * @param angle
		 * @param dywaId
		 */
		function rotate_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(angle,dywaId) {
		    rotate_node_internal(angle,dywaId,$graph_«g.name.lowEscapeDart»);
		    return 'ready';
		}
	«ENDFOR»
	
	
		/**
		* removes a edge with the given dywaId from the canvas
		* this method is called by th NG-App
		* @param dywaId
		*/
		function remove_edge__«g.name.lowEscapeDart»(dywaId) {
			remove_edge_internal(dywaId,$graph_«g.name.lowEscapeDart»);
			return 'ready';
		}
	
	«FOR edge:g.edges»
		/**
		 * creates a «edge.name.escapeDart» edge connecting
		 * the nodes specified by the source and target dywaId
		 * registers the listener for reconnnection and bendpoints
		 * this method is called by th NG-App
		 * @param sourceId
		 * @param targetId
		 * @param dywaId
		 * @param dywaName
		 * @param dywaVersion
		 * @param styleArgs
		 */
		function create_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»(sourceId,targetId,dywaId,dywaName,dywaVersion,positions,styleArgs) {
		    var sourceN = findElementByDywaId(sourceId,$graph_«g.name.lowEscapeDart»);
		    var targetN = findElementByDywaId(targetId,$graph_«g.name.lowEscapeDart»);
		
		    var link = new joint.shapes.«g.name.lowEscapeDart».«edge.name.escapeDart»({
		        attrs:{
		            dywaId:dywaId,
		            dywaName:dywaName,
		            dywaVersion:dywaVersion,
		            styleArgs:styleArgs
		        },
		        source: { id: sourceN.id },
		        target: { id: targetN.id }
		    });
		    if(positions!==null){
			    link.set('vertices', positions['o']['_source'].map(function (n) {
			       return {x:n.x,y:n.y};
			    }));
		    }
		    add_edge_internal(link,$graph_«g.name.lowEscapeDart»,$router_«g.name.lowEscapeDart»,$connector_«g.name.lowEscapeDart»);
		    update_element_«g.name.lowEscapeDart»(link.attributes.id,dywaId,dywaVersion,dywaName,styleArgs);
«««		    «"link".addLinkListeners(edge,g)»
		    return 'ready';
		}
		
		/**
		 * removes the «edge.name.escapeDart» edge with the given dywaId from the canvas
		 * this method is called by th NG-App
		 * @param dywaId
		 */
		function remove_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»(dywaId) {
		    remove_edge_internal(dywaId,$graph_«g.name.lowEscapeDart»);
		    return 'ready';
		}
		
		/**
		 * reconnets the «edge.name.escapeDart» edge to a new target and source node
		 * specified by their dywaId
		 * this method is called by th NG-App
		 * @param sourceId
		 * @param targetId
		 * @param dywaId
		 */
		function reconnect_edge_«edge.name.lowEscapeDart»_«g.name.lowEscapeDart»(sourceId,targetId,dywaId) {
		    reconnect_edge_internal(sourceId,targetId,dywaId,$graph_«g.name.lowEscapeDart»);
		    return 'ready';
		}
		
		/**
		 * updates the «edge.name.escapeDart» edge verticles
		 * specified by the edge dywaId and all verticle positions
		 * this method is called by th NG-App
		 * @param point {x,y}
		 * @param dywaId
		 */
		function update_bendpoint_«g.name.lowEscapeDart»(points,dywaId) {
		    update_bendpoint_internal(points, dywaId,$graph_«g.name.lowEscapeDart»);
		    return 'ready';
		}
	«ENDFOR»
	
	/*
	Creation of nodes by drag and dropping from the palette
	 */
	
	
	
	/**
	 *
	 * @param ev
	 */
	function drop_on_canvas_«g.name.lowEscapeDart»(ev) {
	    ev.preventDefault();
	    var rp = getRelativeScreenPosition(ev.clientX,ev.clientY,$paper_«g.name.lowEscapeDart»);
	    var x = rp.x;
	    var y = rp.y;
	    var typeName = ev.dataTransfer.getData("typename");
	    if(typeName != ''){
	        // create node
	        if(is_containement_allowed_«g.name.lowEscapeDart»(rp,typeName)) {
	        
		        var containerDywaId = get_container_id_«g.name.lowEscapeDart»(rp);
		        switch (typeName) {
		            //foreach node
		            «FOR node:g.nodes» 
		            case '«g.name.lowEscapeDart».«node.name.escapeDart»':{
		            	create_node_«node.name.lowEscapeDart»_«g.name.lowEscapeDart»(x,y,-1,containerDywaId,"undefined",-1,null);
			            break;
		            }
		            «ENDFOR»
		        }
	        
	        }
	    }
	    fitContent($paper_«g.name.lowEscapeDart»);
	
	}
	
	function get_container_id_«g.name.lowEscapeDart»(rp) {
		var views = $paper_«g.name.lowEscapeDart».findViewsFromPoint(rp);
		if(views.length<=0){
			return $graphmodel_id_«g.name.lowEscapeDart»;
		}
		return views[views.length-1].model.attributes.attrs.dywaId;
	}
	
	function is_containement_allowed_«g.name.lowEscapeDart»(rp,creatableTypeName) {
	    var views = $paper_«g.name.lowEscapeDart».findViewsFromPoint(rp);
	    if(views.length<=0){
	    	var targetNode = null;
	        //target is graphmodel
	        «g.containmentCheck(g)»
	    }
	    «IF !g.nodes.filter(NodeContainer).empty»
	    else {
	        var targetNode = views[views.length-1];
	        var targetType = targetNode.model.attributes.type;
			//foreach container
			«FOR container:g.nodes.filter(NodeContainer)»
	        if(targetType==='«g.name.lowEscapeDart».«container.name.fuEscapeDart»')
	        {
	        	«container.containmentCheck(g)»
	        }
	        «ENDFOR»
	    }
	    «ENDIF»
	    return false;
	}
	
	function confirm_drop_«g.name.lowEscapeDart»(ev) {
	    ev.preventDefault();
	    ev.stopPropagation();
	    var rp = getRelativeScreenPosition(ev.clientX,ev.clientY,$paper_«g.name.lowEscapeDart»);
	    var x = rp.x;
	    var y = rp.y;
	    var typeName = ev.dataTransfer.getData("typename");
	    if(typeName != ''){
	    	if(!is_containement_allowed_«g.name.lowEscapeDart»(rp,typeName)) {
	       	   		ev.dataTransfer.effectAllowed= 'none';
	       	        ev.dataTransfer.dropEffect= 'none';
	       	 }
	    }
	
	}
	
	'''
	
	def containmentCheck(ContainingElement ce,GraphModel g)
	'''
		«IF ce.containableElements.empty»
		return true;
		«ELSE»
			«FOR group:ce.containableElements.get(0).containingElement.containableElements.indexed»
			//check if type can be contained in group
			if(
				«FOR containableTypeName:group.value.types.map[name].map[selfAndSubTypeNames(g)].flatten.toSet SEPARATOR "||"»
				creatableTypeName === '«g.name.lowEscapeDart».«containableTypeName»'
				«ENDFOR»
			) {
				«IF group.value.upperBound>-1»
				var group«group.key»Size = 0;
				«FOR containableTypeName:group.value.types.map[name].map[selfAndSubTypeNames(g)].flatten.toSet»
				group«group.key»Size += getContainedByType(targetNode,'«g.name.lowEscapeDart».«containableTypeName»',$graph_«g.name.lowEscapeDart»).length;
				«ENDFOR»
				if(«IF group.value.upperBound>-1»group«group.key»Size<«group.value.upperBound»«ELSE»true«ENDIF»){
					return true;
				}
				«ELSE»
				return true;
				«ENDIF»
			}
			«ENDFOR»
			return false;
		«ENDIF»

	'''
	
	def edgecreation(GraphModel g)
	'''
	var sourceNode = $graph_«g.name.lowEscapeDart».getCell($temp_link.model.attributes.source.id);
	var sourceType = sourceNode.attributes.type;
	var targetNode = views[views.length-1];
	var targetType = targetNode.model.attributes.type;
	var outgoing = getOutgoing(sourceNode,$graph_«g.name.lowEscapeDart»);
	var incoming = getIncoming(targetNode,$graph_«g.name.lowEscapeDart»);
	//create the correct link
	var possibleEdges = {};
	//get possible edges
	//depends on cardinallity
	«FOR source:g.nodes»
	if(sourceType == '«g.name.lowEscapeDart».«source.name.fuEscapeDart»')
	{
		«FOR group:source.outgoingEdgeConnections.indexed»
		//check bound group condition
		var groupSize«group.key» = 0;
			«FOR outgoingEdge:group.value.connectingEdges»
			groupSize«group.key» += filterEdgesByType(outgoing,'«g.name.lowEscapeDart».«outgoingEdge.name.fuEscapeDart»').length;
			«ENDFOR»
			«IF group.value.connectingEdges.empty»
		groupSize«group.key» += outgoing.length;
			«ENDIF»
		//check cardinality
		if(«IF group.value.upperBound < 0»true«ELSE»groupSize«group.key»<«group.value.upperBound»«ENDIF»)
		{
		   «g.targetCheck(group.value)»
		}
		«ENDFOR»
	}
	«ENDFOR»
	var possibleEdgeSize = Object.keys(possibleEdges).length;
	if(possibleEdgeSize==1)
	{
		//only one edge can be created
		//so, create it
		$temp_link_multi = $temp_link;
		create_edge(targetNode,possibleEdges[Object.keys(possibleEdges)[0]].type,$paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	}
	else if(possibleEdgeSize>1)
	{
		//multiple edge types possible
		//show menu
		create_edge_menu(targetNode,possibleEdges,evt.clientX,evt.clientY+$(document).scrollTop(),$paper_«g.name.lowEscapeDart»,$graph_«g.name.lowEscapeDart»);
	}
	'''
	
	def reachable(List<Node> sources, GraphModel g, OutgoingEdgeElementConnection connection){
		val result = new HashMap<Node,List<IncomingEdgeElementConnection>>();
		for(node:sources) {
			val possibleEdgeConnections = new LinkedList
			
			val possibleOutgoingEdges = new LinkedList
			if(connection.connectingEdges.empty) {
				possibleOutgoingEdges += g.edges		
			}
			possibleOutgoingEdges+=connection.connectingEdges
			
			for(incomingEdge:possibleOutgoingEdges){
				possibleEdgeConnections += node.incomingEdgeConnections.filter[connectingEdges.contains(incomingEdge)]
				
				possibleEdgeConnections	+= node.incomingEdgeConnections.filter[connectingEdges.empty]
			}
			if(!possibleEdgeConnections.empty){
				result.put(node,possibleEdgeConnections)
			}
		}
		result
	}
	
	def addLinkListeners(String link,Edge edge,GraphModel g)
	'''
	«link».on('change:source', function() {
		if(!$_disable_events_«g.name.lowEscapeDart»){
			var source = «link».getSourceElement();
			var target = «link».getTargetElement();
			$cb_functions_«g.name.lowEscapeDart».cb_reconnect_edge_«edge.name.lowEscapeDart»(source.attrs.dywaId,target.attrs.dywaId,«link».attrs.dywaId);
			console.log("change link source");
		}
	});
    «link».on('change:target', function() {
    	if(!$_disable_events_«g.name.lowEscapeDart»){
	        var source = «link».getSourceElement();
	        var target = «link».getTargetElement();
	        $cb_functions_«g.name.lowEscapeDart».cb_reconnect_edge_«edge.name.lowEscapeDart»(source.attrs.dywaId,target.attrs.dywaId,«link».attrs.dywaId);
	        console.log("change link target");
        }
    });
    «link».on('change:vertices', function() {
		if(!$_disable_events_«g.name.lowEscapeDart»){
	        $cb_functions_«g.name.lowEscapeDart».cb_update_bendpoint_«edge.name.lowEscapeDart»(«link».get('verticles'),«link».attrs.dywaId);
		        console.log("change link target");
        }
    });
	'''
	
	def targetCheck(GraphModel g, OutgoingEdgeElementConnection group)
	'''
	«FOR possibleTarget:g.nodes.reachable(g,group).entrySet»
	if(targetType == '«g.name.lowEscapeDart».«possibleTarget.key.name.fuEscapeDart»')
	{
		«FOR incomingGroup:possibleTarget.value.indexed»
		
			var incommingGroupSize«incomingGroup.key» = 0;
			«FOR incomingEdge:incomingGroup.value.connectingEdges»
			incommingGroupSize«incomingGroup.key» += filterEdgesByType(incoming,'«g.name.lowEscapeDart».«incomingEdge.name.fuEscapeDart»').length;
			«ENDFOR»
			«IF incomingGroup.value.connectingEdges.empty»
			incommingGroupSize«incomingGroup.key» += incoming.length;
    		«ENDIF»
			if(«IF incomingGroup.value.upperBound < 0»true«ELSE»incommingGroupSize«incomingGroup.key»<«incomingGroup.value.upperBound»«ENDIF»)
			{
				
				if(sourceNode.attributes.id===targetNode.model.id)
				{
					var pos = sourceNode.attributes.position;
					var size = sourceNode.attributes.size;
					«g.possibleEdges(group,incomingGroup.value).indexed.map[n|
				'''
					var link«n.key» = new joint.shapes.«g.name.lowEscapeDart».«n.value.name.fuEscapeDart»({
					source: { id: sourceNode.attributes.id }, target: { id: targetNode.model.id },
					vertices: [
						{ x: pos.x-size.width, y: pos.y-size.height },
						{ x: pos.x-size.width, y: pos.y }
						]
					});
					possibleEdges['«n.value.name.fuEscapeDart»'] = {
					    name: '«n.value.name.fuEscapeDart»',
					    type: link«n.key»
					};
				'''].join»
				}
				else
				{
					«g.possibleEdges(group,incomingGroup.value).indexed.map[n|'''
					var link«n.key» = new joint.shapes.«g.name.lowEscapeDart».«n.value.name.fuEscapeDart»({
					    source: { id: sourceNode.attributes.id }, target: { id: targetNode.model.id }
					});
					possibleEdges['«n.value.name.fuEscapeDart»'] = {
						name: '«n.value.name.fuEscapeDart»',
						type: link«n.key»
					};
				'''].join»
				}
			}
		«ENDFOR»
	}
	«ENDFOR»
	'''
	
	def Map<Integer,Edge> indexed(List<Edge> edges) {
		val result = new HashMap
		edges.forEach[e,i|result.put(i,e)]
		result
	}
	
	def possibleEdges(GraphModel g,OutgoingEdgeElementConnection outgoing, IncomingEdgeElementConnection incoming) {
		if(outgoing.connectingEdges.empty && incoming.connectingEdges.empty) {
			return g.edges
		}
		if(outgoing.connectingEdges.empty && !incoming.connectingEdges.empty) {
			return incoming.connectingEdges
		}
		if(!outgoing.connectingEdges.empty && incoming.connectingEdges.empty) {
			return outgoing.connectingEdges
		}
		return incoming.connectingEdges.filter[e|outgoing.connectingEdges.contains(e)]
	}
	
	def updateStyleArgs(NodeStyle ns,GraphModel g)
	'''
		«FOR textShape:new Shapes(gc,g).collectSelectorTags(ns.mainShape,"x",0).entrySet.filter[n|new Shapes(gc,g).getIsTextual(n.key)]»
	    cell.model.attr('«textShape.value»/text',"«textShape.key.value.parsePlaceholder»");
	    «ENDFOR»
	'''
	
	def updateStyleArgs(EdgeStyle es)
	'''
		cell.model.attributes.labels.forEach(function (label) {
	    «FOR decorator:es.decorator.filter[n|n.decoratorShape instanceof Text ||n.decoratorShape instanceof MultiText].indexed»
			if(label.attrs.hasOwnProperty('text.pyro«decorator.key»link')){
				label.attrs['text.pyro«decorator.key»link'].text = "«decorator.value.decoratorShape.value.parsePlaceholder»";
			}
	    «ENDFOR»
		});
		cell.renderLabels();
	'''
	
	def getValue(EObject shape){
		if(shape instanceof Text){
			return shape.value
		}
		if(shape instanceof MultiText){
			return shape.value
		}
		return ""
	}
	
	
	def parsePlaceholder(String s){
		s.parseIterativePlaceholder.parseIndexedPlaceholder
	}
	
	def parseIterativePlaceholder(String s) {
		var result = ""
		var m = Pattern.compile("%s").matcher(s);
		var parameterIdx = 0;
		var preIdx = 0;
		//var postIdx = 0;
		while (m.find()) {
		    var repString = m.group();
		    //add in between
    		result += s.substring(preIdx,m.start)
    		//set post index
    		preIdx = m.end
    		//replace
    		result += '''"+styleArgs['o'][«parameterIdx»]+"'''
    		parameterIdx++
		}
		//suffix
		result += s.substring(preIdx)
	}
	
	def parseIndexedPlaceholder(String s) {
		var result = ""
		//%1$s
		var m = Pattern.compile("%\\d+\\$s").matcher(s);
		var parameterIdx = 0;
		var preIdx = 0;
		//var postIdx = 0;
		while (m.find()) {
		    var repString = m.group();
		    var start = m.start
		    //add in between
    		result += s.substring(preIdx,start)
    		//set post index
    		preIdx = m.end
    		//replace
    		result += '''"+styleArgs['o'][«(repString.number-1)»]+"'''
    		parameterIdx++
		}
		//suffix
		result += s.substring(preIdx)
	}
	
	def getNumber(String input) {
		var Pattern lastIntPattern = Pattern.compile("\\d");
		var Matcher matcher = lastIntPattern.matcher(input);
		if (matcher.find()) {
		    var String someNumberStr = matcher.group();
		    return Integer.parseInt(someNumberStr);
		}
		return 0
	}

	
}
