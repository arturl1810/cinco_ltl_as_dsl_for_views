/*
-----
Global Scope Variables
-----
 */
//Stores the current element corresponding to the hover menu
var $menu_cell = null;
//Stores if the cursor is positioned on the hover menu
var $mouse_over_menu = false;
//Stores if the mouse has been pressed down over the menu
var $mouse_clicked_menu = false;
//Stores if the cursor is positioned over a node
var $mouse_over_cell = false;
//stores the link which is used for creation
var $temp_link = null;
//stores the link if multiple links can be created
var $temp_link_multi = null;
//stores if the possible edge menu is displayed
var $edge_menu_shown = false;
//stores if the possible edge menu is displayed
var $edge_to_create = null;

var $node_resize_last_direction = null;

joint.shapes.pyro = {};
joint.shapes.pyro.PyroLink = joint.dia.Link.extend({

    markup: '<path class="connection"/>'+
    '<path class="marker-source"/>'+
    '<path class="marker-target"/>'+
    '<path class="connection-wrap"/>'+
    '<g class="labels" />'+
    '<g class="marker-vertices"/>'+
    '<g class="marker-arrowheads"/>'+
    '<g class="link-tools" />',

    defaults: {
        type: 'pyro.PyroLink',
        attrs: {
            '.connection': {
                'stroke-width': 2,
                'stroke': '#000'
            }
        }
    }
});


/*
-----
Utils
-----
 */

/**
 * Resizes the paper to fit the content.
 * @param paper
 */
function fitContent(paper) {
    paper.fitToContent(1,1,{ top: 50, right: 50, bottom: 50, left: 50 },{allowNewOrigin:'any',minWidth:1000,minHeight:200,fitNegative: true});
}

/**
 * Returns a number which is always greater or equals 1
 * @param i
 * @returns {number}
 */
function geq1(i) {
    return i<1?1:i
}

function getOutgoing(node,graph) {
    return graph.getCells()
    .filter(function (element) {
        return element.isLink();
    })
    .filter(function (link) {
        return link.attributes.source.id==node.attributes.id&&link.attributes.type!=='pyro.PyroLink';
    });
}

function getIncoming(node,graph) {
    return graph.getCells()
        .filter(function (element) {
            return element.isLink();
        })
        .filter(function (link) {
            return link.attributes.target.id==node.attributes.id&&link.attributes.type!=='pyro.PyroLink';
        });
}

function filterEdgesByType(edges,type) {
    return edges
        .filter(function (element) {
            return element.attributes.type == type;
        });
}

function getContainedByType(target,type,graph) {
    if(target==null) {
        return graph.getCells().filter(function (element) {
            return element.attributes.parent==null && element.attributes.type===type;
        });
    }
    return graph.getCells().filter(function (element) {
        return element.attributes.parent===target.model.attributes.id && element.attributes.type===type;
    });
}

/**
 *
 * @param x
 * @param y
 * @param paper
 * @returns {*}
 */
function getRelativeScreenPosition(x,y,paper) {
    return paper.clientToLocalPoint({x:x,y:y});
}

/**
 *
 * @param x
 * @param y
 * @param paper
 * @param paper
 * @returns {*}
 */
function getPaperToScreenPosition(x,y,paper) {
    return paper.localToClientPoint({x:x,y:y});
}

/**
 *
 * @param graph
 * @param dywaId
 * @returns {*}
 */
function findElementByDywaId(dywaId,graph) {
    var results = graph.getCells().filter(function (element) {
        return element.attributes.attrs.dywaId===dywaId;
    });
    if(results.length<1){
        return null;
    }
    return results[0];
}

/*
-----
Highlighter
-----
 */

function select_element(cellView,graph) {
    highlight_cell(cellView,graph);
}

/**
 * Deselects all elements
 * @param paper
 * @param graph
 */
function deselect_all_elements(paper,graph) {
    graph.getCells().forEach(function(e){
        unhighlight_cell(paper.findViewByModel(e),graph);
    });

}

/**
 * Sets a new selected elemenet and enables
 * the highlighting
 * @param cellView
 * @param paper
 * @param graph
 */
function update_selection(cellView,paper,graph) {
    deselect_all_elements(paper,graph);
    select_element(cellView,graph);
}

/**
 * Highlights a give node or edge
 * @param cellView
 * @param graph
 */
function highlight_cell(cellView,graph) {
    var model = graph.getCell(cellView.model.id);
    if (typeof model !== "undefined") {
        if(model.isLink()){
            cellView.highlight(null, {
                highlighter: {
                    name: 'addClass',
                    options: {
                        className: 'pyro_edge_highlight'
                    }
                }
            });
        } else {
            cellView.highlight();
        }
    }
}

/**
 * Unhighlights a given node or edge
 * @param cellView
 * @param graph
 */
function unhighlight_cell(cellView,graph) {
    var model = graph.getCell(cellView.model.id);
    if(model.isLink()){
        cellView.unhighlight(null, {
            highlighter: {
                name: 'addClass',
                options: {
                    className: 'pyro_edge_highlight'
                }
            }
        });
    } else {
        cellView.unhighlight();
    }
}

function init_highlighter_eventsystem(paper,graph) {
    paper.on('cell:pointerdown', function(cellView) {
        highlight_cell(cellView,graph);
    });
}

/*
-----
Hover Menu Control
-----
 */

/**
 *
 * @param x
 * @param y
 * @param width
 * @param height
 * @param cellView
 * @param {joint.dia.Paper} paper
 */
function show_menu(x,y,width,height,cellView,paper) {
    $menu_cell = cellView;
    //position of top left corner
    //var cpos = getPaperToScreenPosition(x,y,paper);
    var px = x+width;
    var py = y-40;
    $('#hover-menu').offset({ top: py, left: px });
}

function hide_menu(opt_direct) {
    var direct = opt_direct || false;
    if(direct) {
        $('#hover-menu').offset({ top: -50, left: -50 });
    }
    setTimeout(function () {
        if(!$mouse_over_menu && !$mouse_clicked_menu && !$mouse_over_cell){
            $('#hover-menu').offset({ top: -50, left: -50 });
            $menu_cell = null;
        }
    }, 500);


}

function control_pointer(cellView,borderWidth,evt,paper,centerAnchorPoint) {
    var rp = getRelativeScreenPosition(evt.clientX,evt.clientY,paper);
    var border = false;
    if(centerAnchorPoint){
        border = isBorderClicked(
            cellView.model.attributes.position.x-(cellView.model.attributes.size.width/2),
            cellView.model.attributes.position.x+(cellView.model.attributes.size.width/2),
            cellView.model.attributes.position.y-(cellView.model.attributes.size.height/2),
            cellView.model.attributes.position.y+(cellView.model.attributes.size.height/2),
            rp.x,
            rp.y,
            borderWidth
        );
    } else {
        border = isBorderClicked(
            cellView.model.attributes.position.x,
            cellView.model.attributes.position.x+cellView.model.attributes.size.width,
            cellView.model.attributes.position.y,
            cellView.model.attributes.position.y+cellView.model.attributes.size.height,
            rp.x,
            rp.y,
            borderWidth
        );
    }
    $node_resize_last_direction = border;
    if(border!==false){
        switch(border){
            case 'top-right':cellView.el.style.cursor = 'ne-resize';break;
            case 'top-left':cellView.el.style.cursor = 'nw-resize';break;
            case 'bottom-right':cellView.el.style.cursor = 'se-resize';break;
            case 'bottom-left':cellView.el.style.cursor = 'sw-resize';break;
            case 'top':cellView.el.style.cursor = 'ns-resize';break;
            case 'bottom':cellView.el.style.cursor = 'ns-resize';break;
            case 'left':cellView.el.style.cursor = 'ew-resize';break;
            case 'right':cellView.el.style.cursor = 'ew-resize';break;
        }
    } else {
        cellView.el.style.cursor = 'auto';
    }
}

function init_menu_eventsystem(paper,graph,remove_node) {
    var hover_menu = $('#hover-menu');
    var menu_remove = $('#menu-remove');
    var menu_edge = $('#menu-edge');

    hover_menu.off();
    hover_menu.on('mouseenter',function () {
        $mouse_over_menu = true;
    });
    menu_remove.off();
    menu_remove.on('click',function (evt) {
        if($menu_cell!==null){
            var cell = graph.getCell($menu_cell.model.id);
            remove_node(cell);
            //cell.remove({'disconnectLinks':true});
            $mouse_over_menu=false;
            $menu_cell=null;
            $mouse_clicked_menu = false;
        }
        hide_menu(true);
    });
    menu_edge.on('mousedown',function (evt) {
        hide_menu(true);
        var rp = getRelativeScreenPosition(evt.clientX,evt.clientY,paper);
        $mouse_clicked_menu = true;
        var cell = new joint.shapes.pyro.PyroLink({
            creation_mode : true,
            source: { id: $menu_cell.model.id },
            target: { x: rp.x,y:rp.y}
        });
        graph.addCell(cell);
        $temp_link = paper.findViewByModel(cell);

    });
    hover_menu.on('mouseleave',function () {
        $mouse_over_menu = false;
        hide_menu();
    });
    paper.on('cell:pointermove',function () {
        hide_menu(true);
    });
    paper.on('cell:mouseenter',function(cellView){
        if(cellView.model.isLink()){
            return;
        }
        $mouse_over_cell = true;
        //cursor handling
        var borderWidth = 1;
        var propName = null;
        var centerAnchorPoint = false;
        Object.getOwnPropertyNames(cellView.model.attributes.attrs).forEach(function (n) {
            if(n.indexOf('.pyrox0tag') !== -1){
                propName = n;
                if(n.indexOf('ellipse') !== -1){
                    centerAnchorPoint = true;
                }
            }
        })
        if(propName!==null){
            borderWidth = cellView.model.attributes.attrs[propName] ['stroke-width'] || 1;
        }
        cellView.el.addEventListener("mousemove", function (e) {
            control_pointer(cellView,borderWidth,e,paper,centerAnchorPoint);
        });
        var el = $(cellView.el);
        //show menu
        show_menu(
           el.offset().left,
           el.offset().top,
           el.width(),
           el.height(),
            cellView,
            paper
        );
    });
    paper.on('cell:mouseleave',function(cellView){
        $mouse_over_cell = false;
        //cursor handling
        cellView.el.removeEventListener("mousemove",function () {});
        hide_menu();
    });
}

/*
-----
Edge Control
-----
 */

/**
 * Checks if the position x,y is on the border of
 * the element, specified by xMin, xMax, yMin, yMax
 * and the border width.
 * Returns the border part name or false, if the border
 * is not unter x,y.
 * @param xMin
 * @param xMax
 * @param yMin
 * @param yMax
 * @param x
 * @param y
 * @param strokeWidth
 * @returns String|boolean
 */
function isBorderClicked(xMin,xMax,yMin,yMax,x,y,strokeWidth){
    //top-left-edge
    if(x>=(xMin) && x<=(xMin+strokeWidth) && y>=(yMin) && y<=(yMin+strokeWidth)){
        return "top-left";
    }
    //top-right-edge
    if(x>=(xMax-strokeWidth) && x<=(xMax) && y>=(yMin) && y<=(yMin+strokeWidth)){
        return "top-right";
    }
    //bottom-left-edge
    if(x>=(xMin) && x<=(xMin+strokeWidth) && y>=(yMax-strokeWidth) && y<=(yMax)){
        return "bottom-left";
    }
    //bottom-right-edge
    if(x>=(xMax-strokeWidth) && x<=(xMax+strokeWidth) && y>=(yMax-strokeWidth) && y<=(yMax+strokeWidth)){
        return "bottom-right";
    }
    //top border
    if(x>(xMin+strokeWidth) && x<(xMax-strokeWidth) && y>=(yMin-strokeWidth) && y<=(yMin)){
        return "top";
    }
    //bottom border
    if(x>(xMin+strokeWidth) && x<(xMax-strokeWidth) && y>=(yMax-strokeWidth) && y<=(yMax)){
        return "bottom";
    }
    //left
    if(x>=(xMin-strokeWidth) && x<=(xMin) && y>(yMin+strokeWidth) && y<=(yMax-strokeWidth)){
        return "left";
    }
    //right
    if(x>=(xMax) && x<=(xMax+strokeWidth) && y>(yMin+strokeWidth) && y<=(yMax-strokeWidth)){
        return "right";
    }
    return false;
}

function update_edeg_routing(router,connector,graph) {
    graph.getLinks().forEach(function (link) {
        update_single_edge_routing(link,router,connector);
    });
}

function update_single_edge_routing(link,router,connector) {
    if (router) {
        link.set('router', { name: router });
    } else {
        link.unset('router');
    }
    link.set('connector', { name: connector });
}

function remove_edge_creation_menu() {
    if($edge_menu_shown) {
        $('#pyro_edge_menu').remove();
        $edge_menu_shown = false;
    }
}

function create_edge_menu(target_view,possibleEdges,x,y,paper,graph) {
    $temp_link_multi = $temp_link;
    var btn_group = $('<div id="pyro_edge_menu" class="btn-group-vertical btn-group-xs" style="position: absolute;z-index: 99999;top: '+y+'px;left: '+x+'px;"></div>');
    $('body').append(btn_group);
    $edge_menu_shown = true;
    for(var edgeKey in possibleEdges) {
        if (possibleEdges.hasOwnProperty(edgeKey)) {
            var edge = possibleEdges[edgeKey];
            var button = $('<button type="button" class="btn btn-default">'+edge.name+'</button>');

            btn_group.append(button);

            $(button).on('click',function () {
                var e = possibleEdges[this.innerText];
                create_edge(target_view,e.type,paper,graph);
                $edge_menu_shown = false;
                $('#pyro_edge_menu').remove();
            });
        }
    }
}

function create_edge(target_view,possibleEdge,paper,graph) {
    if($temp_link_multi.model.attributes.source.id===target_view.model.id) {
        graph.addCell(possibleEdge);
        fitContent(paper);
    } else {
        graph.addCell(possibleEdge);
    }
    $temp_link_multi = null;

}

function init_edge_eventsystem(paper) {
    $(document).off('mousemove');
    $(document).mousemove(function (evt) {
        if($temp_link!==null && $mouse_clicked_menu===true){
            var rp = getRelativeScreenPosition(evt.clientX,evt.clientY,paper);
            var target = $temp_link.model.attributes.target;
            target['x']=rp.x;
            target['y']=rp.y;
            $temp_link.render();
            $temp_link.pointermove(evt,rp.x,rp.y);
        }
    });

}

/*
-----
Node Control
-----
 */


/**
 * Creates the constraont view for all nodes.
 * It is used to realize the resizing feature
 * @returns {Object|void|*}
 */
function constraint_element_view() {
    return joint.dia.ElementView.extend({

        selectedBorder: false,


        pointerdown: function(evt, x, y) {
            var borderWidth = 1;
            var propName = null;
            var centerAnchorPoint = false;
            Object.getOwnPropertyNames(this.model.attributes.attrs).forEach(function (n) {
                if(n.indexOf('.pyrox0tag') !== -1){
                    propName = n;
                    if(n.indexOf('ellipse') !== -1){
                        centerAnchorPoint = true;
                    }
                }
            })
            if(propName!==null){
                borderWidth = this.model.attributes.attrs[propName] ['stroke-width'] || 1;
            }
            if(centerAnchorPoint){
                this.selectedBorder = isBorderClicked(
                    this.model.attributes.position.x-(this.model.attributes.size.width/2),
                    this.model.attributes.position.x+(this.model.attributes.size.width/2),
                    this.model.attributes.position.y-(this.model.attributes.size.height/2),
                    this.model.attributes.position.y+(this.model.attributes.size.height/2),
                    x,
                    y,
                    borderWidth
                );
            } else {
                this.selectedBorder = isBorderClicked(
                    this.model.attributes.position.x,
                    this.model.attributes.position.x+this.model.attributes.size.width,
                    this.model.attributes.position.y,
                    this.model.attributes.position.y+this.model.attributes.size.height,
                    x,
                    y,
                    borderWidth
                );
            }
            joint.dia.ElementView.prototype.pointerdown.apply(this, [evt, x, y]);
        },


        pointermove: function(evt, x, y) {
            if(this.selectedBorder===false){
                joint.dia.ElementView.prototype.pointermove.apply(this, [evt, x, y]);
            } else {
                if(this.selectedBorder=='top-left'){
                    var yDif = this.model.attributes.position.y-y;
                    var xDif = this.model.attributes.position.x-x;
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'top-left'});
                }
                else if(this.selectedBorder=='top-right'){
                    var yDif = this.model.attributes.position.y-y;
                    var xDif = x-(this.model.attributes.position.x+this.model.attributes.size.width);
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'top-right'});
                }
                else if(this.selectedBorder=='bottom-left'){
                    var yDif = y-(this.model.attributes.position.y+this.model.attributes.size.height);
                    var xDif = this.model.attributes.position.x-x;
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'bottom-left'});
                }
                else if(this.selectedBorder=='bottom-right'){
                    var yDif = y-(this.model.attributes.position.y+this.model.attributes.size.height);
                    var xDif = x-(this.model.attributes.position.x+this.model.attributes.size.width);
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'bottom-right'});
                }
                else if(this.selectedBorder=='top'){
                    var yDif = this.model.attributes.position.y-y;
                    this.model.resize(
                        geq1(this.model.attributes.size.width),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'top'});
                }
                else if(this.selectedBorder=='bottom'){
                    var yDif = y-(this.model.attributes.position.y+this.model.attributes.size.height);
                    this.model.resize(
                        geq1(this.model.attributes.size.width),
                        geq1(this.model.attributes.size.height+yDif),
                        {'direction':'bottom'});
                }
                else if(this.selectedBorder=='left'){
                    var xDif = this.model.attributes.position.x-x;
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height),
                        {'direction':'left'});
                }
                else if(this.selectedBorder=='right'){
                    var xDif = x-(this.model.attributes.position.x+this.model.attributes.size.width);
                    this.model.resize(
                        geq1(this.model.attributes.size.width+xDif),
                        geq1(this.model.attributes.size.height),
                        {'direction':'right'});
                }
                this.unhighlight();
                this.highlight();
            }

        }
    });
}

/*
Element Control
Internal actions
 */


function update_element_internal(cellId,dywaId,dywaName,dywaVersion,styleAgs,graph){
    if(cellId!=null){
        var element = graph.getCell(cellId);
        element.attributes.attrs.dywaId = dywaId;
        element.attributes.attrs.dywaName = dywaName;
        element.attributes.attrs.dywaVersion = dywaVersion;
        element.attributes.attrs.styleArgs = styleAgs;
    }
    else {
        var element = findElementByDywaId(dywaId,graph);
        element.attributes.attrs.dywaId = dywaId;
        element.attributes.attrs.dywaName = dywaName;
        element.attributes.attrs.dywaVersion = dywaVersion;
        element.attributes.attrs.styleArgs = styleAgs;
    }

    
}

function add_node_internal(element,graph,paper){
    graph.addCells([ element ]);
    fitContent(paper);
}

function add_edge_internal(element,graph,router,connector){
    update_single_edge_routing(element,router,connector);
    element.addTo(graph).reparent();
}

function move_node_internal(x,y,dywaId,containerId,graph)
{
    var node = findElementByDywaId(dywaId,graph);
    if(node.parent){
        var parent = graph.getCell(node.parent);
        parent.unembed(node);
    }
    if(containerId>0) {
        var container = findElementByDywaId(containerId, graph);
        container.embed(node);
    }
    node.position(x, y,{ parentRealtive: true });
}

function remove_node_internal(dywaId,graph)
{
    var node = findElementByDywaId(dywaId,graph);
    node.remove({disconnectLinks:true});
    
}

function resize_node_internal(width,height,direction,dywaId,graph,paper)
{
    var node = findElementByDywaId(dywaId,graph);
    node.resize(width,height,{direction:direction});
    var cell = paper.findViewByModel(node);
    cell.unhighlight();
    cell.highlight();
}

function rotate_node_internal(angle,dywaId,graph)
{
    var node = findElementByDywaId(dywaId,graph);
    node.rotate(angle,true);
}

function remove_edge_internal(dywaId,graph)
{
    var edge = findElementByDywaId(dywaId,graph);
    edge.remove();
}

function reconnect_edge_internal(sourceId,targetId,dywaId,graph)
{
    var edge = findElementByDywaId(dywaId,graph);
    edge.set('source',findElementByDywaId(sourceId, graph));
    edge.set('target',findElementByDywaId(targetId,graph));
    edge.reparent();
}

function update_bendpoint_internal(positions,dywaId,graph)
{
    var link = findElementByDywaId(dywaId,graph);
    if(positions!==null) {
        link.set('vertices', positions['o'].map(function (n) {
            return {x:n.x,y:n.y};
        }));
    }

}

/*
General Event Mechanism
 */

/**
 * Disbales user interaction on the given paper
 * @param paper
 */
function block_user_interaction(paper) {
    paper.setInteractivity(false);
}

/**
 * Enables the user interaction for the given paper
 * @param paper
 */
function unblock_user_interaction(paper) {
    paper.setInteractivity(true);
}

/**
 * Resets all listeners and register new ones
 */
function init_event_system(paper,graph,remove_cascade)
{
    $menu_cell = null;
    $mouse_over_menu = false;
    $mouse_clicked_menu = false;
    $mouse_over_cell = false;
    $temp_link = null;
    $edge_menu_shown = false;
    init_edge_eventsystem(paper);
    init_highlighter_eventsystem(paper,graph);
    init_menu_eventsystem(paper,graph,remove_cascade);
}


function confirm_drop(ev) {
    ev.preventDefault();
}

/**
 *
 * @param ev
 */
function start_drag_element(ev) {
    $edge_to_create = ev.target.dataset.typename;
	ev.dataTransfer.setData("typename", ev.target.dataset.typename);
}
