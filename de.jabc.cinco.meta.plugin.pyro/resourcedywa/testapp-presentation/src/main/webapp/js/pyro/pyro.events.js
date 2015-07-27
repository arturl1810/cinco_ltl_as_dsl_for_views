/**
 * Created by Pyro.
 */
/**
 * Event-Listener
 * Del Key Hit
 */
$(document).keypress(function(e) {
    //Delete
    if(e.which === 127 || e.which === 46) {
        $('#removeModelElement').trigger('click');
    }
    //Copy
    if(e.which === 67 || e.which === 99) {
        if(isSelection) {
            saveElementToReminder();
        }
    }
    //Cut
    if(e.which === 88 || e.which === 120) {
        if(isSelection) {
            saveElementToReminder();
            $('#removeModelElement').trigger('click');
            return;
        }
    }
    //paste
    if(e.which === 86 || e.which === 118) {
        if(reminderElement){
            var elementName = reminderElement.attributes.cinco_name;
            var position = getPaperCursorPosition(mouseXPos,mouseYPos);
            createElementInPosition(joint.shapes.devs[elementName+''],(position.x),(position.y),reminderElement);
        }
    }
});

$('.remove-graph').click(function(e){
    e.stopPropagation();
});

$('.propertiesListAdd').on('click',function(){
    console.log('fe');
    var attrIndex = $(this).attr('data-inputfield');
    console.log('yaho'+attrIndex);
    var element = getSelectedElement();
    if(element != null) {
        var subType = element.attributes.cinco_attrs[attrIndex].subtype;
    }
});

/**
 * Event-Listener
 * Share Menu checkbox
 */
$('.share-input').click(function(){
   var user = $(this).attr('data-share-user');
   var isChecked = $(this).prop('checked');
   if($(this).attr('data-share-type') === 'global') {
       $('input[data-share-user='+user+']').each(function(){
           $(this).prop('checked', isChecked);
       });
   }
    else {
       if(!isChecked){
           $('input[data-share-user='+user+'][data-share-type=global]').each(function(){
               $(this).prop('checked', isChecked);
           });
       }
   }
});

/**
 * Event-Listener
 * Settings Menu open
 */
$('#settingsAction').click(function(){
    bindValidators();
    $('#settingsSaveMessage').hide();
    $('#scaleFactor').val(scaleFactor);
    $('#edgeTriggerWidth').val(edgeTriggerWidth);
    $('#paperWidth').val(paperWidth);
    $('#paperHeight').val(paperHeight);
    $('#gridSize').val(gridSize);
    $('#resizeStep').val(resizeStep);
    $('#rotateStep').val(rotateStep);
    $('#editorTheme').val(theme);
});

/**
 * Event-Listener
 * Settings Menu save
 */
$('#settingsSave').click(function(){
    scaleFactor = $('#scaleFactor').val();
    edgeTriggerWidth = $('#edgeTriggerWidth').val();
    paperWidth = $('#paperWidth').val();
    paperHeight = $('#paperHeight').val();
    gridSize = $('#gridSize').val();
    resizeStep = $('#resizeStep').val();
    rotateStep = $('#rotateStep').val();
    theme = $('#editorTheme').find(':selected').val();
    persistSettings();
    sendChangeSettingsCommand();
    $('#settingsSaveMessage').fadeIn( "slow" );

});

/**
 * Event-Listener
 * Change node connector styling
 */
$('.edgeType').on('click', function () {
    $('.edgeType').each(function(){
        $(this).parent('li').removeClass('active');
    });
    $(this).parent('li').addClass('active');
    var router = $(this).data('router');
    var connector = $(this).data('connector');
    edgeStyleMode = {router: router, connector: connector};
    styleAllEdges();
    sendChangeSettingsCommand();
});

/**
 * Event-Listener
 * Resize Cell positive
 */
$('#resizePlusModelElement').click(function(){
    var element = getSelectedElement();
    if(element != null) {
        resizeElement(element,resizeStep,resizeStep);
    }
});

/**
 * Event-Listener
 * Resize Cell positive
 */
$('#resizeMinusModelElement').click(function(){
    var element = getSelectedElement();
    if(element != null) {
        resizeElement(element,(-1*resizeStep),(-1*resizeStep));
    }
});

/**
 * Event-Listener
 * Rotate Cell positive
 */
$('#rotatePlusModelElement').click(function(){
    var element = getSelectedElement();
    if(element != null) {
        rotateElement(element,rotateStep);
    }
});

/**
 * Event-Listener
 * Rotate Cell positive
 */
$('#rotateMinusModelElement').click(function(){
    var element = getSelectedElement();
    if(element != null) {
        rotateElement(element,-1*rotateStep);
    }
});


/**
 * Event-Listener
 * Move Mode Button
 */
$('#moveMode').click(function(){
    modelingMode = 'move';
});

/**
 * Event-Listener
 * Rotate Mode Button
 */
/**
jQuery(function($){
    $(document).drag("start",function( ev, dd ){
        return $('<div class="selection" />')
            .css('opacity', .65 )
            .appendTo( document.body );
    })
        .drag(function( ev, dd ){
            $( dd.proxy ).css({
                top: Math.min( ev.pageY, dd.startY ),
                left: Math.min( ev.pageX, dd.startX ),
                height: Math.abs( ev.pageY - dd.startY ),
                width: Math.abs( ev.pageX - dd.startX )
            });
        })
        .drag("end",function( ev, dd ){
            $( dd.proxy ).remove();
        });
    $('.drop')
        .drop("start",function(){
            console.log($(this));
            $( this ).addClass('highlighted-parent');
        })
        .drop(function( ev, dd ){
            console.log($(this));
            $( this ).toggleClass("dropped");
        })
        .drop("end",function(){
            console.log($(this));
            $( this ).removeClass("active");
        });
    $.drop({ multi: true });
});
*/

/**
 * Event-Listener
 * Resize Mode Button
 */
$('#resizeMode').click(function(){
    modelingMode = 'resize';
});

/**
 * Event-Listener
 * Zoom In Button
 */
$('#zoomInAction').click(function(){
    scaleFactor = scaleFactor * 1.2;
    paper.scale(scaleFactor);
    paperSmall.scale(scaleFactor * 0.2);
    sendChangeSettingsCommand();
});

/**
 * Event-Listener
 * Zoom Out Button
 */
$('#zoomOutAction').click(function(){
    scaleFactor = scaleFactor * 0.8;
    paper.scale(scaleFactor);
    paperSmall.scale(scaleFactor * 0.2);
    sendChangeSettingsCommand();
});

/**
 * Event-Listener
 * Save as SVG Button
 */
$('#saveAsSVGAction').click(function(){
    var svg      = $('svg').parent().html(),
        b64      = Base64.encode(svg);
    saveAs(new Blob([svg], {type:"application/svg+xml"}), graphName+".svg");
});

/**
 * Default Context-Menu
 * Quick-Add Elements
 * Copy, Paste, Cut
 * Remove
 * Custome Actions
 */
$(function(){
    $.contextMenu({
        selector: '#muiCanvas',
        build: function($trigger, e){
            return {
                callback: function(key, options) {
                    var tmp_y = $('.context-menu-list').css('top');
                    var y = tmp_y.substring(0,tmp_y.length-2);
                    var tmp_x = $('.context-menu-list').css('left');
                    var x = tmp_x.substring(0,tmp_x.length-2);
                    var position = getPaperCursorPosition(x,y);
                    var elementName = key;
                    //System Actions
                    if(key === 'remove') {
                        $('#removeModelElement').trigger('click');
                        return;
                    }
                    if(key === 'cut') {
                        saveElementToReminder();
                        $('#removeModelElement').trigger('click');
                        return;
                    }
                    if(key === 'paste') {
                        if(reminderElement){
                            if(reminderElement.attributes.cinco_type !== 'Edge'){
                                elementName = reminderElement.attributes.cinco_name;
                                createElementInPosition(joint.shapes.devs[elementName+''],position.x,position.y,reminderElement);
                                return;
                            }
                        }
                        else{
                            return;
                        }
                    }
                    if(key === 'copy') {
                        saveElementToReminder();
                        return;
                    }
                    //CustomeActions
                    if(isCustomAction(key)){
                        customActionCall(key);
                        return;
                    }
                    createElementInPosition(joint.shapes.devs[elementName+''],position.x,position.y);

                },
                items: getContextMenuActions()
            };
        }

    });

});

$('#minimizeMenu').on('click',function(){
    $('#menuPanel').hide();
    $('#miniMenu').show();
    $('#graphTabs').removeClass('col-md-10').addClass('col-md-8');
    minimizedMenu = true;
    sendChangeSettingsCommand();
});

$('#maximizeMenu').on('click',function(){
    $('#menuPanel').show();
    $('#miniMenu').hide();
    $('#graphTabs').removeClass('col-md-8').addClass('col-md-10');
    minimizedMenu = false;
    sendChangeSettingsCommand();
});

$('#minimizeGraph').on('click',function(){
    $('#maximizeGraph').show();
    $('#minimizeGraph').hide();
    $('#palette').show();
    $('#graphModel').removeClass('col-md-12').addClass('col-md-9');
    $('#paper').addClass('scroll-auto');
    minimizedGraph = true;
    sendChangeSettingsCommand();
});

$('#maximizeGraph').on('click',function(){
    $('#minimizeGraph').show();
    $('#maximizeGraph').hide();
    $('#palette').hide();
    $('#graphModel').removeClass('col-md-9').addClass('col-md-12');
    $('#paper').removeClass('scroll-auto');
    minimizedGraph = false;
    sendChangeSettingsCommand();
});

$('#minimizeMap, #maximizeProperties').on('click',function(){
    $('#graphMapPanel').hide();
    $('#minimizeProperties').show();
    $('#maximizeProperties').hide();
    $('#graphMapCol').removeClass('col-md-3').addClass('col-md-1');
    $('#propertiesCol').removeClass('col-md-9').addClass('col-md-12');
    minimizedMap = true;
    sendChangeSettingsCommand();
});



$('#minimizeProperties').on('click',function(){
    $('#graphMapPanel').show();
    $('#minimizeProperties').hide();
    $('#maximizeProperties').show();
    $('#graphMapCol').removeClass('col-md-1').addClass('col-md-3');
    $('#propertiesCol').removeClass('col-md-12').addClass('col-md-9');
    minimizedMap = false;
    sendChangeSettingsCommand();
});

/**
 * Event-Listener
 * Triggered when attributes of an Model-Element has changed
 * Saves the modified data in the Model of the Cell
 * And send a AjaX-Request with the changed Attributes to the server
 */
$( "#paper-link-out" ).focusout(function() {
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
    persistAttribute(cincoAttributes);
    if(muiId !== 'CincoGraphModel') {
        cell.setLabel();
        var persitedCincoAttributes = cell.attributes.cinco_attrs;
    }
    else{
        var persitedCincoAttributes = cinco_graphModelAttr;
    }
    //Update The Values of the Field in the MUI
    //Send Ajax-Request with the form
    sendChangeAction(persitedCincoAttributes,cincoName,cincoType,muiId,cincoId,'edit','attribute');
});


/**
 * Event-Listener
 * Creates the new Edges depending on source and target
 */
graph.on('change:source change:target', function(link) {
    if(link.attributes.type != 'link'){ return; }
    var source = graph.getCell(link.get('source').id);
    //TODO Remove if source is null
    var targetId = link.get('target').id;
    if(targetId != null) {
        var target = graph.getCell(targetId);
        graph.getCell(link.id).remove();
        connect(source,'',target,'',link.attributes.cinco_name,false);
    }
});

/**
 * Event-Listener
 * Triggert when a Modeling-Element is clicked.
 * The clicked element is highlighted and its properties are shown in the
 * properties view
 *
 */
paper.on('cell:pointerup', function(cellView, evt, x, y) {
    if(cellView.model.attributes.type == 'link'){
        var link = graph.getCell(cellView.model.id);
        if(link != null) {
            link.remove();
        }
        return;
    }
    //De-Select the previous Element
    unHighlightElement();
    //Highlight clicked Element
    highlightElement(cellView);
});

/**
 * Event-Listener
 * Triggered when a cell is clicked and the cursor is moving
 * Depending on the selected mode the element is resized or rotatated
 * TODO Implemntation
 */
paper.on('cell:pointermove', function(cellView, evt, x, y) {
    //TODO Resize
    if(modelingMode === 'resize'){
        cellView.resize(20,20);
        return;
    }
    //TODO Rotate
});

/**
 * Event-Listener
 * Triggered when the Graph-Model is clicked
 * The Graph-Model properties are shown in the properties view
 */
paper.on('blank:pointerdown', function(cell) {
    unHighlightElement();
    showPropertiesView(graphName,cinco_graphModelAttr, 'CincoGraphModel');
});

/**
 * Event-Listener
 * Triggered when an Element is added to the Graph
 */
graph.on('add', function(cell) {
    //Connector-Links will never be added to the Graph
    if(cell.attributes.type == 'link'){
        return;
    }
    cell.setLabel();
    if(!onCreationState){
        styleAllEdges();
    }
    styleElements(false);
    sendChangeAction(cell,cell.attributes.cinco_name,cell.attributes.cinco_type,cell.id,null,'create',null);
});

/**
 * Event-Listener
 * Triggered when an Element is resized or rotated
 */
$('#elementChange')
    .on('cellResize', function(event,cell){
        sendChangeAction(cell,cell.attributes.cinco_name,cell.attributes.cinco_type,cell.id,cell.attributes.cinco_id,'edit','resize');
    })
    .on('cellRotate', function(event,cell){
        sendChangeAction(cell,cell.attributes.cinco_name,cell.attributes.cinco_type,cell.id,cell.attributes.cinco_id,'edit','rotate');
    });

/**
 * Event-Listener
 * Triggered when an Element is removed from the Graph
 */
graph.on('remove', function(cell) {
    //Connector-Links will never be removed from the Graph
    if(cell.attributes.type == 'link'){ return; }
    if(cell.attributes.type == 'devs.Link') {
        displayPropertiesView(false);
    }
    sendChangeAction(cell,cell.attributes.cinco_name,cell.attributes.cinco_type,cell.id,cell.attributes.cinco_id,'delete',null);
});



/**
 * Event-Listner
 * Collecting the mouse-position on the paper
 */
$( "#paper" ).mousemove(function(event) {
    mouseXPos = event.pageX;
    mouseYPos = event.pageY;
});

/**
 * Event-Listener
 * Triggered when the Remove Button  is clicked
 */
$( "#removeModelElement" ).on( "click", function() {
    var muiId = $('#paper-link-out').attr('muiId');
    var cell = graph.getCell(muiId);
    if(cell != null)
    {
        cell.remove();
        displayPropertiesView(false);
    }
});

/**
 * Event-Listener
 * Triggered when a cell is highlighted and un-highlighted
 */
paper.off('cell:highlight cell:unhighlight').on({

    'cell:highlight': function(cellView, el, opt) {
        if (opt.embedding) {
            V(el).addClass('highlighted-parent');
        }

        if (opt.connecting) {
            //Triggered when a connection is created
        }
    },

    'cell:unhighlight': function(cellView, el, opt) {

        if (opt.embedding) {
            V(el).removeClass('highlighted-parent');
        }

        if (opt.connecting) {
            //Triggered after a connection is created
        }
    }
});

/**
 * Event-Listener
 * Triggered when a node is dragged from the palette to the paper
 */
$(function() {
    $( "#accordion").find("li")
        .mousedown(function() {
            isDragging = true;
            $('.pyro-container').css('cursor', 'move');
            disableSelection($('.pyro-container'));
            $(window).unbind("mousemove");
            draggedNodeType = $( this).text();
        });
    $("#paper").mouseup(function(e) {
        if(isDragging){
            isDragging = false;
            $('.pyro-container').css('cursor', 'auto');

            var position = getPaperCursorPosition(e.pageX, e.pageY);
            createElementInPosition(joint.shapes.devs[draggedNodeType+''],(position.x),(position.y));
        }
    });
    $(".pyro-container").mouseup(function(e) {
       if(isDragging){
           isDragging = false;
           $('.pyro-container').css('cursor', 'auto');
       }
    });
});





