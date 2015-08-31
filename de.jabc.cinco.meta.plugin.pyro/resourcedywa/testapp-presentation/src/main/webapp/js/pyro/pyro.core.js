/**
 * Created by Pyro.
 */

var graph = new joint.dia.Graph;            // The everything
var onCreationState = true;                 // The page is loaded
var isDragging = false;                     // The user is dragging
var draggedNodeType = '';                   // The dragged cinco_type
var scaleFactor = 2;                        // The actual scale factor
var edgeTriggerWidth = 10;                  // CONST width of the border for edge creation
var edgeStyleMode = {connector: 'normal'};  // The actual edge styling mode
var modelingMode = 'move';                  // The actual modeling mode [move,mark]
var cinco_graphModelAttr = {};              // The graph-model attributes
var snapRadius = 20;                        // CONST radius of the snapping circle around the middle of the elements
var isSelection = false;                    // An element is selected
var selectionType = '';                     // The selected element type
var mouseXPos = 0;                          // The actual x-position of the cursor in the document
var mouseYPos = 0;                          // The actual y-position of the cursor in the document
var reminderElement = '';                   // The cinco_type of the last copied or cut element
var paperWidth = 1000;
var paperHeight = 1000;
var gridSize = 1;
var resizeStep = 0.1;
var rotateStep = 5;
var theme = 'flatly';
var graphName = '';
var projectName = '';
var projectId  = 0;
var graphModelId = 0;
var minimizedMenu = false;
var minimizedGraph = true;
var minimizedMap = false;
var graphModelName = '';

displayPropertiesView(false);

/**
 *
 * @type {joint.dia.Paper}
 */
var paper = new joint.dia.Paper({
    el: $('#paper'),
    width: paperWidth,
    height: paperHeight,
    gridSize: gridSize,
    model: graph,
    markAvailable: true,
    snapLinks: { radius: snapRadius },
    embeddingMode: true,
    validateEmbedding: function(childView, parentView) {
        return validateElementEmbadding(childView,parentView);
    },
    validateConnection: function(sourceView, sourceMagnet, targetView, targetMagnet)
    {
        return validateElementConnection(sourceView,targetView);
    }
});

/**
 * Small View of the Graph
 * @type {joint.dia.Paper}
 */
var paperSmall = new joint.dia.Paper({
    el: $('#myholder-small'),
    width: paperWidth/5,
    height: paperHeight/5,
    model: graph,
    gridSize: 1
});

paperSmall.scale(0.2);
paperSmall.$el.css('pointer-events', 'none');

function persistSettings()
{
    $('#theme').attr('href',getAssetRootPath()+'/themes/'+theme+'/bootstrap.'+theme+'.css');
    if(theme === 'default'){
        $('#helperTheme').attr('href',getAssetRootPath()+'/themes/bootstrap.min.css');
    }
    else{
        $('#helperTheme').attr('href',getAssetRootPath()+'/themes/bootswatch.min.css');
    }
    paper.scale(scaleFactor);
    styleElements(false);
    paper.setDimensions(paperWidth,paperHeight);
    paperSmall.setDimensions(paperWidth/5,paperHeight/5);
    //paper.$el.css('background-image', 'url("' + getGridBackgroundImage(this.value * $sx.val(), this.value * $sy.val()) + '")');
    paper.options.gridSize = gridSize;
}

/**
 * Style all edges in the graph in the defined mode
 */
function styleAllEdges()
{

    graph.getLinks().forEach(function(link){
        link.set('connector', { name: edgeStyleMode.connector });
        if(edgeStyleMode.router !== null && edgeStyleMode.router){
            if(edgeStyleMode.router.length > 0){
                link.set('router', { name: edgeStyleMode.router });
            }
            else{
                link.unset('router');
            }
        }
        else{
            link.unset('router');
        }
    });
}

/**
 * Returns the selected and highlighted element
 * @returns {joint.dia.Cell | null}
 */
function getSelectedElement()
{
    var muiId = $('#paper-link-out').attr('muiId');
    return graph.getCell(muiId);
}

/**
 * Resizes the width and height of an element
 * @param cell
 * @param width
 * @param height
 */
function resizeElement(cell,width,height)
{
    if(!cell.isLink()) {
        var elementScale =  $('g[model-id="'+cell.attributes.id+'"]').find('g.scalable');
        var scaleFactor = (elementScale.attr('transform'));
        var scaleStringSplitt = scaleFactor.substr(6,(scaleFactor.length-1)).split(",");
        elementScale.attr('transform','scale('+(parseFloat(scaleStringSplitt[0])+parseFloat(width))+','+(parseFloat(scaleStringSplitt[1])+parseFloat(height))+')');
        var preWidth = cell.attributes.size.width;
        var preHeight = cell.attributes.size.height;
        cell.attributes.size.width = preWidth*(1+width);
        cell.attributes.size.height = preHeight*(1+height);
        $( "#elementChange" ).trigger( 'cellResize',cell );
    }
}

function resizeElementOnActivate(cell,width,height)
{
    if(!cell.isLink()) {
        var preWidth = cell.attributes.size.width;
        var preHeight = cell.attributes.size.height;
        var scaleX = 0.5 + ((width / preWidth) -1)/2;
        var scaleY = 0.5 + ((height / preHeight) -1)/2;
        var elementScale =  $('g[model-id="'+cell.attributes.id+'"]').find('g.scalable');
        elementScale.attr('transform','scale('+(parseFloat(scaleX))+','+(parseFloat(scaleY))+')');
        cell.attributes.size.width = width;
        cell.attributes.size.height = height;
    }
}

/**
 * Rotates an element relative with the given angular
 * @param cell
 * @param angle
 */
function rotateElement(cell,angle)
{
    if(!cell.isLink()) {
        cell.rotate(angle);
        $( "#elementChange" ).trigger( 'cellRotate',cell );
    }
}

/**
 * Saves the cinco_type of the selected element to the reminder
 */
function saveElementToReminder()
{
    var element = getSelectedElement();
    if(element != null) {
        reminderElement = element;
    }
}

/**
 * Parses an attribute depending on its type to a string representation
 * @param attribute
 * @returns {string | int}
 */
function getAttributeLabel(attributes,attributeName)
{
    for(var i=0; i<attributes.length;i++){
        if(attributes[i].name == attributeName){
            if(attributes[i].type === 'list'){
                var listToString = '';
                for(var j=0;j<attributes[i].values.length;j++){
                    listToString += getAttributeString(attributes[i].values[j].type,attributes[i].values[j].values);
                }
                return listToString;
            }
            else{
                return getAttributeString(attributes[i].type,attributes[i].values);
            }

        }
    }
}

function getAttributeString(type,values)
{
    if(type === 'boolean') {
        return values ? 1 : 0;
    }
    if(type === 'choice') {
        return values.selected;
    }
    else {
        return values;
    }
}

function persistPrimativeAttribute(element,index,cincoAttributes)
{
    if(cincoAttributes[index].type === 'boolean') {
        cincoAttributes[index].values = $(element).prop('checked');
    }
    else if(cincoAttributes[index].type == 'choice') {
        cincoAttributes[index].values.selected = $(element).val();
    }
    else {
        cincoAttributes[index].values = $(element).val();
    }
}

/**
 * Persists the propertie view form to the cell
 * @param cincoAttributes
 */
function persistAttribute(cincoAttributes)
{
    $( "div.properties-view" ).each(function( index ) {
        if(cincoAttributes[index].type == 'list'){
            $(this).find('.properties-entry').each(function(i){
                if(i < cincoAttributes[index].values.length){
                    persistPrimativeAttribute($(this),i,cincoAttributes[index].values);
                }
            });
        }
        else {
            persistPrimativeAttribute($(this).children('.properties-entry'),index,cincoAttributes);
        }
    });

}

/**
 * Hides or shows the Properties view
 * @param show
 */
function displayPropertiesView(show,isLink)
{
    if(isLink) {
        $('#resizeProperties').hide();
        $('#rotateProperties').hide();
    }
    else {
        $('#resizeProperties').show();
        $('#rotateProperties').show();
    }
    if(show===true) {
        $('#properties').show();
    }
    else {
        $('#properties').hide();
    }
}

/**
 * Un-highlights the last selected Element
 */
function unHighlightElement()
{
    var muiId = $('#paper-link-out').attr('muiId');
    if(muiId != null) {
        //Links are Highlighted in a different way
        isSelection = false;
        selectionType = graphModelName;
        var preSelect = $( 'g[model-id="'+muiId+'"]')[0];
        if(preSelect != null) {
            var prelinkClass = $(preSelect).attr('class');
            if(prelinkClass.indexOf('link') > -1){
                var preLink = $(preSelect).find('.connection')[0];
                V(preLink).removeClass('highlight');
            }
            else
            {
                V(preSelect).removeClass('highlighted-parent');
            }
        }
    }
}

/**
 * Highlights the selected element
 * @param cellView
 */
function highlightElement(cellView)
{
    var cellId;
    var cellAttributes;
    if(cellView.model == null){
        cellId = cellView.id;
        cellAttributes = cellView.attributes;
    }
    else{
        cellId = cellView.model.id;
        cellAttributes = cellView.model.attributes;
    }
    var target = $( 'g[model-id="'+cellId+'"]')[0];
    if(target != null) {
        var targetLinkClass = $(target).attr('class');
        if(targetLinkClass.indexOf('link') > -1){
            var targetLink = $(target).find('.connection')[0];
            V(targetLink).addClass('highlight');
        }
        else
        {
            V(target).addClass('highlighted-parent');
        }
    }
    var element = graph.getCell(cellId);
    if(element != null){
        isSelection = true;
        selectionType = cellAttributes.cinco_name;
        showPropertiesView(cellAttributes.cinco_name,cellAttributes.cinco_attrs,cellId);
        sendChangeAction(element,cellAttributes.cinco_name,cellAttributes.cinco_type,cellId,cellAttributes.cinco_id,'edit','move');
    }
}

/**
 * Sends an AjaX-Request to the Server
 * Depending on the operation and the Model-Element
 * @param cell
 * @param cellType
 * @param operation
 */
function sendChangeAction(data,cincoName,cincoType,muid,id,method,option)
{
    if(onCreationState){ return; }
    console.log('[AJAX] Send '+cincoType+': '+cincoName+' '+method+' '+option);
    sendDefaultCommand(data,cincoName,cincoType,muid,id,method,option);
}

/**
 * Creates the Form-Elements for the properties view
 * @param elementName
 * @param cincoAttributes
 * @param muiId
 */
function showPropertiesView(elementName,cincoAttributes,muiId)
{
    var m = '';
    var index = 2;
    for(var attr in cincoAttributes) {
        if(index % 2 === 0) {
            m += '<div class="row">';
        }
        m += '<div class="col-sm-6">';
        m += '<div class="form-group properties-form-entry">';
        m += '<label for="'+cincoAttributes[attr].name;
        if(cincoAttributes[attr].type === 'boolean') {
            m += ' ';
        }
        m += '" class="col-sm-6 control-label">'+cincoAttributes[attr].name+'</label>';
        m += '<div class="col-sm-6  properties-view">';
        m += getAttributeInput(cincoAttributes[attr].type,cincoAttributes[attr].name,(index-2),cincoAttributes[attr].values,cincoAttributes[attr].lower,cincoAttributes[attr].upper,cincoAttributes[attr].option);
        m += '</div></div></div>';
        index++;
        if(index % 2 === 0) {
            m += '</div>';
        }
    }

    $('#paper-link-out').html(m).attr('muiId', muiId);
    $('#model-name').html(elementName);
    //Register Buttons

    var addButtons = document.getElementsByClassName('propertiesListAdd');
    if(addButtons != null) {
        for(var i=0;i<addButtons.length;i++) {
            addButtons[i].addEventListener("click", addListEntry, false);
        }
    }
    var removeButtons = document.getElementsByClassName('propertiesListRemove');
    if(removeButtons != null) {
        for(var i=0;i<removeButtons.length;i++) {
            removeButtons[i].addEventListener("click", removeListEntry, false);
        }
    }

    displayPropertiesView(true,(graph.getCell(muiId)==null ||graph.getCell(muiId).isLink()));
    if(elementName === graphName){
        $(removeModelElement).hide();
    }
    else{
        $(removeModelElement).show();
    }
    bindValidators();
}

/**
 * Binds number and decimal validators to the input fields
 */
function bindValidators() {
    $("input.decimal-2-places").numeric({ decimalPlaces: 2 });
    $("input.numeric").numeric(false, function() { this.value = ""; this.focus(); });
    $("input.positive").numeric({ negative: false }, function() { this.value = ""; this.focus(); });
}
/**
 * Creates an input field for an attribute of an element
 * @param type
 * @param name
 * @param id
 * @param value
 * @returns {string}
 */
function getInputField(type,name,id,value,option) {

    var optionalParameter = '';
    if(option !== null){
        optionalParameter = option;
    }
    if(type==='number') {
        return '<input type="number" class="form-control numeric properties-entry" step="1" data-bind="value:replyNumber" name="'+name+'" id="'+id+'" value="'+value+'" '+optionalParameter+'>';
    }
    if(type === 'double') {
        return '<input type="number" step="0.01" class="form-control decimal-2-places properties-entry" name="'+name+'" id="'+id+'" value="'+value+'" '+optionalParameter+'>';
    }
    if(type === 'choice') {
        var selected = value.selected;
        var m = '<select class="form-control properties-entry" name="'+name+'" id="'+id+'" '+optionalParameter+'>';
        for(var choice in value.choices)
        {
            if(selected === value.choices[choice]){
                m += '<option value="'+value.choices[choice]+'" selected>'+value.choices[choice]+'</option>';
            }
            else
            {
                m += '<option value="'+value.choices[choice]+'">'+value.choices[choice]+'</option>';
            }

        }
        m += '</select>';
        return m;
    }
    if(type === 'boolean') {
        if(value === true || value === 'true'){
            return '<input type="checkbox" class="form-control properties-entry" name="'+name+'" id="'+name+id+'" checked '+optionalParameter+'>';
        }
        else {
            return '<input type="checkbox" class="form-control properties-entry" name="'+name+'" id="'+id+'" '+optionalParameter+'>';
        }
    }
    else {
        return '<input type="'+type+'" class="form-control properties-entry" name="'+name+'" id="'+id+'" value="'+value+'" '+optionalParameter+'>';
    }
}

function getAttributeInput(type,name,id,value,lower,upper,option)
{
    var optionalParameter = '';
    if(option !== null){
        optionalParameter = option;
    }
    if(type === 'list') {
        var m = '';
        for(var i in value){
            m += '<div class="row"><div class="col-sm-10">';
            m += getInputField(value[i].type,value[i].name,i,value[i].values,option);
            m += '</div><div class="col-sm-2">';
            if(value.length > lower){
                m += '<button type="button" class="btn btn-xs btn-danger propertiesListRemove properties-view" data-entryId="'+i+'" data-cinco-attr="'+id+' '+optionalParameter+'"><span class="glyphicon glyphicon-remove"></span></button>';
            }
            m += '</div></div>';
        }
        if(value.length < upper || upper < 0) {
            m += '<div class="row"><div class="col-sm-10"></div><div class="col-sm-2">';
            m += '<button type="button" class="btn btn-xs btn-success propertiesListAdd" data-cinco-attr="'+id+'" '+optionalParameter+'><span class="glyphicon glyphicon-plus"></span></button>';
            m += '</div></div>';
        }
        return m;
    }
    else {
        return getInputField(type,name,id,value,option)
    }
}

/**
 * Adds an entry to the List in the attributes
 */
function addListEntry(){
    var cinco_attributes;
    var cinco_name;
    var cellId;
    if($('paper-link-out').attr('muiid') == 'CincoGraphModel') {
        cinco_attributes = cinco_graphModelAttr;
        cinco_name = graphName;
        cellId = 'CincoGraphModel';
    }
    else{
        cinco_attributes = getSelectedElement().attributes.cinco_attrs;
        cinco_name = getSelectedElement().attributes.cinco_name;
        cellId = getSelectedElement().id;
    }
    var index = $(this).attr('data-cinco-attr');
    var list = cinco_attributes[index];
    var prototype = list.subtype;
    list.values.push(clone(prototype));
    persistAttribute(cinco_attributes);
    showPropertiesView(cinco_name,cinco_attributes,cellId);
}
/**
 * Removes an entry of the List in the attributes
 */
function removeListEntry()
{
    var cinco_attributes;
    var cinco_name;
    var cellId;
    var cincoType = "GraphModel";
    var cincoId = null;
    if($('paper-link-out').attr('muiid') == 'CincoGraphModel') {
        cinco_attributes = cinco_graphModelAttr;
        cinco_name = graphName;
        cellId = 'CincoGraphModel';
    }
    else{
        cinco_attributes = getSelectedElement().attributes.cinco_attrs;
        cinco_name = getSelectedElement().attributes.cinco_name;
        cincoType = getSelectedElement().attributes.cinco_type;
        cincoId = getSelectedElement().attributes.cinco_id;
        cellId = getSelectedElement().id;
    }
    var index = $(this).attr('data-cinco-attr');
    var entryIndex = $(this).attr('data-entryid');
    var list = cinco_attributes[index];
    list.values.splice(entryIndex,1);
    $(this).parent().parent().remove();
    persistAttribute(cinco_attributes);
    showPropertiesView(cinco_name,cinco_attributes,cellId);
    //sendChangeAction(cinco_attributes,cinco_name,cincoType,cellId,cincoId,'edit','attribute');
}

/**
 * Clone any object
 * @param obj
 * @returns {*}
 */
function clone(obj) {
    var copy;

    // Handle the 3 simple types, and null or undefined
    if (null == obj || "object" != typeof obj) return obj;

    // Handle Date
    if (obj instanceof Date) {
        copy = new Date();
        copy.setTime(obj.getTime());
        return copy;
    }

    // Handle Array
    if (obj instanceof Array) {
        copy = [];
        for (var i = 0, len = obj.length; i < len; i++) {
            copy[i] = clone(obj[i]);
        }
        return copy;
    }

    // Handle Object
    if (obj instanceof Object) {
        copy = {};
        for (var attr in obj) {
            if (obj.hasOwnProperty(attr)) copy[attr] = clone(obj[attr]);
        }
        return copy;
    }

    throw new Error("Unable to copy obj! Its type isn't supported.");
}

/**
 * Connects two Ports with the specified edge-type for this connection
 * @param source
 * @param sourcePort
 * @param target
 * @param targetPort
 */
function connect(source, sourcePort, target, targetPort, edgeType, init) {
    var sourceNodeType = graph.getCell(source.id).attributes.cinco_name;
    var targetNodeType = graph.getCell(target.id).attributes.cinco_name;
    var sourceSelector = { id: source.id, selector: source.getPortSelector(sourcePort) };
    var targetSelector = { id: target.id, selector: target.getPortSelector(targetPort) };
    var links = getConnectingEdge(sourceNodeType,sourceSelector,targetNodeType,targetSelector,edgeType);
    var link;
    //Multiple edge-types are approved
    if(links.length <= 0) {
        return;
    }
    if(links.length > 1) {
        edgeSelection(links,source,sourcePort,target,targetPort);
        return;
    }
    else {
        link = links[0].edge;
    }

    if(link != null) {
        link.addTo(graph).reparent();
        if(init == false){
            unHighlightElement();
            highlightElement(graph.getCell(link.id));
        }
    }
}

/**
 * Creates the items for the edge-selection context-menu
 * @param edges
 * @param source
 * @param sourcePort
 * @param target
 * @param targetPort
 */
function edgeSelection(edges,source,sourcePort,target,targetPort)
{
    var xPos = mouseXPos,
        yPos = mouseYPos;

    var contextMenu = {
        "header" : {name: "Select an Edge", disabled: true},
        "step1": "---------"
    };
    for(var edge in edges) {
        contextMenu[edges[edge].name] = {name : edges[edge].name};
    }
    $.contextMenu({
        selector: '#edgeContextMenu',
        build: function($trigger, e){
            return {
                callback: function(key, options) {
                    connect(source,sourcePort,target,targetPort,key,false);
                },
                items: contextMenu
            };
        }

    });
    $('#edgeContextMenu').contextMenu({x: xPos, y: yPos});


}

/**
 * Returns an instance of the given modelElementClass
 * @param createdTypeLabel
 * @param x
 * @param y
 * @param cloneElement
 */
function createElementInPosition(createdTypeLabel,x,y,cloneElement)
{
    var type = getNodeTypeByLabel(createdTypeLabel);
    var modelElementClass = joint.shapes.devs[type.name+''];
    if('dywaId' in type){
        var element = new modelElementClass({
            cinco_id : '5',
            cinco_prime_id: type.dywaId,
            position: {x: (x/2), y: (y/2)}
        });
        element.attributes.cinco_attrs[0].values = type.label;
    }
    else{
        var element = new modelElementClass({
            cinco_id : '5',
            position: {x: (x/2), y: (y/2)}
        });
    }
    if(cloneElement) {
        element.attributes.cinco_attrs = cloneElement.attributes.cinco_attrs;
        element.attributes.size = cloneElement.attributes.size;
        element.attributes.angle = cloneElement.attributes.angle;
    }


    graph.addCell(element);
}

/**
 * Creates the items for the default context-menu
 * @returns {{header: {name: string, disabled: boolean}, step1: string}}
 */
function getContextMenuActions()
{
    var contextMenu = {
        "header" : {name: "Menu", disabled: true},
        "step1": "---------"
    };
    var modelElements = getAllNodeTypes();
    for(var groups in modelElements) {
        var subGroup = {};
        for(var item in modelElements[groups].nodes) {
            subGroup[modelElements[groups].nodes[item].label] = {
                name: modelElements[groups].nodes[item].label
            };
        }
        contextMenu[modelElements[groups].group] = {name : modelElements[groups].group, items: subGroup};
    }
    //ContextMenu for Nodes,Containers,Edges
    if(isSelection === true) {
        if (getSelectedElement().attributes.cinco_type !== 'Edge') {
            contextMenu['step2'] = "---------";
            contextMenu['remove'] = {name: "remove"};
            contextMenu['copy'] = {name: "copy"};
            contextMenu['cut'] = {name: "cut"};
        }

    }
    if(getCustomeActions()[selectionType] != null){
        contextMenu['step3'] = "---------";
        for(var entry in getCustomeActions()[selectionType]) {
            contextMenu[getCustomeActions()[selectionType][entry]] = {name : getCustomeActions()[selectionType][entry]};
        }
    }
    //ContextMenu for Graphmodel
    else{
        if(reminderElement){
            contextMenu['paste'] = {name: "paste"};
        }
    }
    console.log(contextMenu);
    return contextMenu;
}

/**
 * Checks whether a selected context-menu item is a custom-action link
 * @param key
 * @returns {boolean}
 */
function isCustomAction(key)
{
    console.log(key);
    for(var type in getCustomeActions()) {
        for(var action in getCustomeActions()[type]){
            if(getCustomeActions()[type][action] === key){
                return true;
            }
        }
    }
    return false;
}

/**
 * Calculates the position in the paper depending on the document position
 * @param clientX
 * @param clientY
 * @returns {{x: *, y: *}}
 */
function getPaperCursorPosition(clientX,clientY)
{
    var y = clientY;
    var x = clientX
    y = y - $('#muiCanvas').offset().top -25;
    x = x -  $('#muiCanvas').offset().left -25;
    return {x:x,y:y};
}

/**
 * AjaX call for custome action
 * @param actionName
 */
function customActionCall(actionName)
{
    var muiId = $('#paper-link-out').attr('muiId');
    var cincoAttributes;
    var cincoId = null;
    var cincoType;
    var cincoName;
    var cell;
    if(muiId === 'CincoGraphModel') {
        cincoAttributes = cinco_graphModelAttr;
        cincoType = 'GraphModel';
        cincoName = graphName;
    }
    else {
        cell = graph.getCell(muiId);
        cincoAttributes = cell.attributes.cinco_attrs;
        cincoType = cell.attributes.cinco_type;
        cincoName = cell.attributes.cinco_name;
        cincoId = cell.attributes.cinco_id;
    }
    sendChangeAction(cincoAttributes,cincoName,cincoType,muiId,cincoId,'custom',actionName);
}

/**
 * Creates the palette for all nodes and containers and groups
 */
function createPalette()
{
    var htmlOutput ='';
    var modelElements = getAllNodeTypes();
    htmlOutput += '<div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">';
    for(var groups in modelElements) {
        htmlOutput += '<div class="panel panel-default">'
        htmlOutput += '<div class="panel-heading" role="tab" id="collapseListGroupHeading'+groups+'">';
        htmlOutput += '<h4 class="panel-title" id="-collapsible-list-group-'+groups+'">';
        htmlOutput += '<a data-toggle="collapse" data-parent="#accordion" href="#collapseListGroup'+groups+'" aria-expanded="true" aria-controls="collapseListGroup'+groups+'">';
        htmlOutput += modelElements[groups].group+'</a>';
        htmlOutput += '<a class="anchorjs-link" href="#-collapsible-list-group-'+groups+'"><span class="anchorjs-icon"></span></a>';
        htmlOutput += '</h4>';
        htmlOutput += '</div>';
        htmlOutput += '<div id="collapseListGroup'+groups+'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="collapseListGroupHeading'+groups+'" aria-expanded="true">';
        htmlOutput += '<ul class="list-group">';
        for(var item in modelElements[groups].nodes) {
            htmlOutput += '<li class="list-group-item node-palette">'+modelElements[groups].nodes[item].label+'</li>';
        }
        htmlOutput += '</ul>';
        htmlOutput += '</div>';
        htmlOutput += '</div>';
    }
    htmlOutput += '</div>';
    $('#palette').html(htmlOutput);
}

/**
 * Disables the selection of an element
 * @param element
 */
function disableSelection(element)
{
    element.attr('unselectable', 'on')
        .css('user-select', 'none')
        .on('selectstart', false);
}

function getNodeTypeByLabel(label)
{
    var groups = getAllNodeTypes();
    for(var group in groups) {
        for(var item in groups[group].nodes) {
            if(groups[group].nodes[item].label == label){
                return groups[group].nodes[item];
            }
        }
    }
}









