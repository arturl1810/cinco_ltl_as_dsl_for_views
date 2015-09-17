$('#normal').addClass('active');
createPalette();
persistSettings();
styleAllEdges();
$('.edgeType').each(function(){
    var router = $(this).data('router');
    var connector = $(this).data('connector');
    if(!edgeStyleMode.router){
        if(connector == edgeStyleMode.connector && !router){
            $(this).parent('li').addClass('active');
        }
        else{
            $(this).parent('li').removeClass('active');
        }
    }
    else{
        if(router == edgeStyleMode.router && connector == edgeStyleMode.connector){
            $(this).parent('li').addClass('active');
        }
        else{
            $(this).parent('li').removeClass('active');
        }
    }

});

styleElements(true);
selectionType = graphModelName;
onCreationState = false;