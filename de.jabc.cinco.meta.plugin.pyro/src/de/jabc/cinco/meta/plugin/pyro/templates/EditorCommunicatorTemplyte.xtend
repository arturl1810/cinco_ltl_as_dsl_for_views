package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer

class EditorCommunicatorTemplyte extends Templateable {
	
	override create(TemplateContainer tc)
	'''
	function getMethodURL(method) {
	    if(method === 'edit') {
	        return getEditElementURL();
	    }
	    if(method === 'delete') {
	        return getRemoveElementURL();
	    }
	    if(method === 'create') {
	        return getCreateElementURL();
	    }
	    if(method === 'custom') {
	        return getCustomFeatureURL();
	    }
	}
	
	function getData(data,cincoName,cincoType,muid,id,method,option) {
	
	    var source = null;
	    var target = null;
	    var parent = null;
	    if(method === 'edit' && option === 'move' || method === 'create'){
	        if(data.attributes.parent != muid){
	            parent = graph.getCell(data.attributes.parent);
	        }
	    }
	
	    if(cincoType === 'Edge'){
	        if(data.attributes != null){
	            if(data.attributes.source != null){
	                source = graph.getCell(data.attributes.source.id);
	            }
	            if(data.attributes.target != null){
	                target = graph.getCell(data.attributes.target.id);
	            }
	        }
	    }
	    return {
	        'message':  'default',
	        'project':  projectName,
	        'projectId': projectId,
	        'graphName':graphName,
	        'graphModelId': graphModelId,
	        'dywaId':   id,
	        'type':     cincoType,
	        'name':     cincoName,
	        'muId':     muid,
	        'option':   option,
	        'element': data,
	        'target': target,
	        'source': source,
	        'parent': parent
	    };
	}
	
	function sendDefaultCommand(values,cincoName,cincoType,muid,id,method,option) {
	    var requestData = getData(values,cincoName,cincoType,muid,id,method,option);
	
	    console.log(getMethodURL(method));
	    $.ajax({
	       type: "POST",
	        url: getMethodURL(method),
	        async: false,
	        success: function(data) {
	            console.log($.parseJSON(data));
	            executeResponse(method,$.parseJSON(data));
	        },
	        data: JSON.stringify(requestData)
	    });
	    console.log(requestData);
	}
	
	function executeResponse(method, data) {
	    //Execute Pre-Commands
	    if(method == 'create'){
	
	        var cell = graph.getCell(data.muId);
	        if(data.valid == true){
	            cell.attributes.cinco_id = data.dywaId;
	        }
	        else {
	            graph.removeCell(cell);
	        }
	        location.reload();
	    }
	    if(method === 'custom') {
	        location.reload();
	    }
	}
	
	function sendChangeSettingsCommand() {
	    if(onCreationState){
	        return;
	    }
	    var requestData = {
	        theme:theme,
	        scaleFactor:scaleFactor,
	        edgeTriggerWidth:edgeTriggerWidth,
	        edgeStyleMode: edgeStyleMode,
	        snapRadius:snapRadius,
	        paperWidth:paperWidth,
	        paperHeight:paperHeight,
	        gridSize:gridSize,
	        resizeStep:resizeStep,
	        rotateStep:rotateStep,
	        minimizedMenu:minimizedMenu,
	        minimizedGraph:minimizedGraph,
	        minimizedMap:minimizedMap
	    };
	    $.ajax({
	        type: "POST",
	        url: getChangeSettingsURL(),
	        async: false,
	        success: function(data) {
	            console.log($.parseJSON(data));
	            $('#settingsSaveMessage').fadeIn( "slow" );
	            //executeSettingsResponse(method,$.parseJSON(data));
	        },
	        data: JSON.stringify(requestData)
	    });
	}
	'''
	
}