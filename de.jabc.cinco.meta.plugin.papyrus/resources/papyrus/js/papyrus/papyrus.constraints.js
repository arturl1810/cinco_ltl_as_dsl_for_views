/**
 * Validates two Nodes, whether they can be embedded
 * @param childView
 * @param parentView
 * @returns {boolean}
 */
function validateElementEmbadding(childView, parentView)
{
	var embeddingName = childView.model.attributes.cinco_name;
	var containerName = parentView.model.attributes.cinco_name;
	var containerElement = graph.getCell(parentView.model.id);
	var embeddedElements = containerElement.getEmbeddedCells();
    if(embeddingName == 'Activity' && containerName == 'Swimlane'){
    	var count = 0;
    	for(var i=0;i<embeddedElements.length;i++) {
    		if(embeddedElements[i].attributes.cinco_name === 'Activity') {
    			count++;
    		}
    	}
    	if(count < 3){
    		return true;
    	}
    }
    
    if(embeddingName == 'Start' && containerName == 'Swimlane'){
    	var count = 0;
    	for(var i=0;i<embeddedElements.length;i++) {
    		if(embeddedElements[i].attributes.cinco_name === 'Start') {
    			count++;
    		}
    	}
    	if(count < 1){
    		return true;
    	}
    }
    
    return false;
}

/**
 * Validates two Nodes, whether they can be connected
 * @returns {boolean}
 * @param sourceNode
 * @param targetNode
 */
function validateElementConnection(sourceNode,targetNode)
{
	var sourceNodeType = sourceNode.options.model.attributes.cinco_name;
	var targetNodeType = targetNode.options.model.attributes.cinco_name;
	var sourceNodeElement = graph.getCell(sourceNode.model.id);
	var targetNodeElement = graph.getCell(targetNode.model.id);
	var sourceOpt ={outbound: true};
	var targetOpt = {inbound:true};
	var sourceLinks = graph.getConnectedLinks(sourceNodeElement,sourceOpt);
	var targetLinks = graph.getConnectedLinks(targetNodeElement,targetOpt);
if(sourceNodeType == 'Start' && targetNodeType == 'Start'){
	var countSource = 0;
	for(var i = 0;i<sourceLinks.length;i++) {
		if(sourceLinks[i].attributes.cinco_name === 'Transition'){
			countSource++;
		}
	}
	if(countSource < 1 ){
		return true;
	}
}
if(sourceNodeType == 'Start' && targetNodeType == 'End'){
	var countSource = 0;
	for(var i = 0;i<sourceLinks.length;i++) {
		if(sourceLinks[i].attributes.cinco_name === 'Transition'){
			countSource++;
		}
	}
	var countTarget = 0;
	for(var i = 0;i<targetLinks.length;i++) {
		if(targetLinks[i].attributes.cinco_name === 'Transition'){
			countTarget++;
		}
	}
	if(countSource < 1 && countTarget < 2 ){
		return true;
	}
}
if(sourceNodeType == 'Start' && targetNodeType == 'Activity'){
	var countSource = 0;
	for(var i = 0;i<sourceLinks.length;i++) {
		if(sourceLinks[i].attributes.cinco_name === 'Transition'){
			countSource++;
		}
	}
	if(countSource < 1 ){
		return true;
	}
}
if(sourceNodeType == 'Activity' && targetNodeType == 'End'){
	var countTarget = 0;
	for(var i = 0;i<targetLinks.length;i++) {
		if(targetLinks[i].attributes.cinco_name === 'LabeledTransition'){
			countTarget++;
		}
	}
	if(countTarget < 2 ){
		return true;
	}
}
if(sourceNodeType == 'Activity' && targetNodeType == 'Activity'){
	return true;
}
    return false;
}

/**
 * Returns all approved edges to connect the given two node-types
 * @param sourceNodeType
 * @param sourceSelector
 * @param targetNodeType
 * @param targetSelector
 * @returns {Array}
 */
function getConnectingEdge(sourceNodeType,sourceSelector,targetNodeType,targetSelector,edgeType)
{
    var links = [];

    if(edgeType != null) {

        var link = new joint.shapes.devs[edgeType+'']({
            source: sourceSelector, target: targetSelector
        });
        links.push({edge: link, name: edgeType});
        return links;
    }
    //Determine which connection should be created
if(sourceNodeType == 'Start' && targetNodeType == 'Start'){
	var link = new joint.shapes.devs.Transition({
	    source: sourceSelector, target: targetSelector
	});
	links.push({edge: link, name: 'Transition'});
}
if(sourceNodeType == 'Start' && targetNodeType == 'End'){
	var link = new joint.shapes.devs.Transition({
	    source: sourceSelector, target: targetSelector
	});
	links.push({edge: link, name: 'Transition'});
}
if(sourceNodeType == 'Start' && targetNodeType == 'Activity'){
	var link = new joint.shapes.devs.Transition({
	    source: sourceSelector, target: targetSelector
	});
	links.push({edge: link, name: 'Transition'});
}
if(sourceNodeType == 'Activity' && targetNodeType == 'End'){
	var link = new joint.shapes.devs.LabeledTransition({
	    source: sourceSelector, target: targetSelector
	});
	links.push({edge: link, name: 'LabeledTransition'});
}
if(sourceNodeType == 'Activity' && targetNodeType == 'Activity'){
	var link = new joint.shapes.devs.LabeledTransition({
	    source: sourceSelector, target: targetSelector
	});
	links.push({edge: link, name: 'LabeledTransition'});
}

    return links;
}

/**
 *
 * @returns {string[]}
 */
function getAllNodeTypes()
{
	return [
{
	group:'Containers',
	nodes:[
	'Swimlane'
	]
},
{
	group:'Nodes',
	nodes:[
	'Start',
	'End',
	'Activity'
	]
}
    ];
}

function styleElements(onInitiate) {
/*	_.each(grap.getElements(), function(element){
		var cinco_name = element.attributes.cinco_name;
		if(cinco_name === 'Activity') {
			element.attr({'.body': {'rx':8, }})
		}
	});*/
}

/**
 *
 * @returns {{edge: Array, node: string[], container: Array, graphmodel: Array}}
 */
function getCustomeActions()
{
    return{
        //TODO
    };
}

graphName = 'FlowGraph';
