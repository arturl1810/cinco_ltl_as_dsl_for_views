/**
 * Created by zweihoff on 07.04.15.
 */
/*
 ----------------------------------------
 ----------< INITIAL SETUP >-------------
 ----------------------------------------
 */

var s1 = new joint.shapes.devs.Start({
    position: { x: 10, y: 50 },
    cinco_id : '1'

});

var a1 = new joint.shapes.devs.Activity({
    cinco_id : '2',
    position: { x: 80, y: 50 }
});

/*
 Add Elements to the Graph
 */

graph.addCells([s1, a1]);

//c1.embed(a1);

connect(s1,'',a1,'', 'Transition',true);

/*
 ----------------------------------------
 ----------</ INITIAL SETUP >------------
 ----------------------------------------
 */
theme = 'default';
$('#normal').addClass('active');
styleElements(true);
createPalette();
persistSettings();
$('#minimizeProperties').hide();
$('#miniMenu').hide();
$('#minimizeGraph').hide();
onCreationState = false;