package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import mgl.Node
import mgl.Edge
import de.jabc.cinco.meta.plugin.papyrus.StyledModelElement
import mgl.GraphicalModelElement

class EditorModelTemplate implements Templateable{
	override create(GraphModel graphModel,ArrayList<StyledModelElement> nodes,ArrayList<StyledModelElement> edges) '''
	/**
 * Created by zweihoff on 07.04.15.
 */


if (typeof exports === 'object') {

    var joint = {
        util: require('../src/core').util,
        shapes: {
            basic: require('./joint.shapes.basic')
        },
        dia: {
            ElementView: require('../src/joint.dia.element').ElementView,
            Link: require('../src/joint.dia.link').Link
        }
    };
    var _ = require('lodash');
}

joint.shapes.devs = {};

joint.shapes.devs.Model = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {

    type_name: 'model',
    markup: '<g class="rotatable"><g class="scalable"><g class="inPorts"/><g class="outPorts"/><rect class="body"/></g><text class="label"/></g>',
    portMarkup: '<g class="port port<%= id %>"><rect class="port-body"/><text class="port-label"/></g>',

    defaults: joint.util.deepSupplement({

        type: 'devs.Model',
        cinco_attrs: {},
        cinco_id: '0',
        cinco_name: 'NoName',
        cinco_type: 'element',

        inPorts: [''],
        outPorts: [],

        attrs: {
            '.': { magnet: false },
            '.body': {
                stroke: '#ffffff'
            },
            '.port-body': {
                magnet: false,
                fill: '#transparent',
                stroke: '#ffffff'
            },
            text: {
                'pointer-events': 'none'
            },
            '.label': { text: 'Model', 'ref-x': .5, 'ref-y': 10, ref: '.body', 'text-anchor': 'middle' },
            '.inPorts .port-label': { x:0, dy: 0, 'text-anchor': 'end', fill: '#ffffff'},
            '.outPorts .port-label':{ x: 0, dy: 0, fill: '#ffffff' }
        }

    }, joint.shapes.basic.Generic.prototype.defaults),

    setLabel: function() {

    },

    getPortAttrs: function(portName, index, total, selector, type) {

        var attrs = {};

        var portClass = 'port' + index;
        var portSelector = selector + '>.' + portClass;
        var portLabelSelector = portSelector + '>.port-label';
        var portBodySelector = portSelector + '>.port-body';

        attrs[portLabelSelector] = { text: portName };
        attrs[portBodySelector] = { port: { id: portName || _.uniqueId(type) , type: type } };
        attrs[portSelector] = { ref: '.body', 'ref-y': (-0.9 * edgeTriggerWidth), 'ref-x' : (-0.9 * edgeTriggerWidth) };

        if (selector === '.outPorts') {
            attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };
        }

        return attrs;
    }
}));
/*
 -------------------------------------------------------
 -------------Define Nodes Containers---------------
 -------------------------------------------------------
 */


/**
 * GraphModel Attributes
 * @type {{GraphModel: string[]}}
 */
cinco_graphModelAttr = {
    GraphModel: [' ','text']
};

joint.shapes.devs.BigAtomic = joint.shapes.devs.Model.extend({

    defaults: joint.util.deepSupplement({
        type: 'devs.BigAtomic',
        cinco_name: 'BigAtomic',    //Cinco Name
        cinco_type: 'Node',
        cinco_attrs: {              //Cinco Attributes
            ionising: [{ selected: 'one', choices : ['one','two','three'] }, 'map']
        },
        size: { width: 120, height: 120 }, //Cinco Style Size
        attrs: {
            '.body': {
                width: 120,
                height: 120,
                fill: '#ffffff', //Background
                stroke: '#ffb176',//Foreground
                'stroke-width' : 2 //linewidth
            },
            '.label': {
                'font-size': 14,
                'font-family': 'Arial'
            }, //Defined text in STYLE
            '.port-body': {
                width: (120 + (edgeTriggerWidth*2) ), height: (120 + (edgeTriggerWidth*2) )
            }
        }
        //inPorts: ['']

    }, joint.shapes.devs.Model.prototype.defaults),
    setLabel: function() {
        var attributes = this.attributes.cinco_attrs;
        this.attr('.label',{ text: 'L: '+getAttributeLabel(attributes.ionising),fill: '#ffb176'}); //How the label is rendered
    }

});
/**
 * SmallAtomic
 * @type {void|*}
 */
joint.shapes.devs.SmallAtomic = joint.shapes.devs.Model.extend({

    defaults: joint.util.deepSupplement({
        type: 'devs.SmallAtomic',
        cinco_name: 'SmallAtomic',
        cinco_type: 'Node',
        cinco_attrs: {
            radiation: [0.00, 'double']
        },
        size: { width: 80, height: 80 },
        attrs: {
            '.body': {
                width: 80,
                height: 80,
                fill: '#ffffff',
                stroke: '#ffb176',
                'stroke-width': 3
            },
            '.label': {
                'font-size': 10
            }, //Cinco Label
            '.port-body': {
                width: (80 + (edgeTriggerWidth*2)), height: (80 + (edgeTriggerWidth*2))
            }
        }
    }, joint.shapes.devs.Model.prototype.defaults),
    setLabel: function() {
        var attributes = this.attributes.cinco_attrs;
        this.attr('.label',{ text: 'L: '+getAttributeLabel(attributes.radiation),fill: '#ffb176'});
    }

});

/**
 * BigAtmoic
 * @type {void|*}
 */
joint.shapes.devs.Coupled = joint.shapes.devs.Model.extend({

    defaults: joint.util.deepSupplement({
        type: 'devs.Coupled',
        cinco_name: 'Coupled',
        cinco_type: 'Container',
        cinco_attrs: {
            name: [' ', 'text'],
            value: [0, 'number'],
            valid: [true, 'boolean']
        },
        size: { width: 200, height: 300 },
        attrs: {
            '.body': {
                width: 200,
                height: 300,
                fill: '#ffffff',
                stroke: '#7c68fc',
                'stroke-width': 3
            },
            '.label': {
                'font-size': 18
            }, //Cinco Label
            '.port-body': {
                width: (200+ edgeTriggerWidth*2), height: (300 + edgeTriggerWidth*2)
            }
        }

    }, joint.shapes.devs.Model.prototype.defaults),
    setLabel: function() {
        /**
         * Get the needed Attributes for the label
         */
        var attributes = this.attributes.cinco_attrs;
        this.attr('.label',{ text: 'L: '+getAttributeLabel(attributes.name),fill: 'blue'});
    }

});

/*
 -------------------------------------------------------
 ---------------------Define Edges----------------------
 -------------------------------------------------------
 */
/**
 * AtomToCoupled
 * @type {void|*}
 */
joint.shapes.devs.AtomToCoupledYellow = joint.dia.Link.extend({

    defaults: {
        type: 'devs.Link',
        cinco_name: 'AtomToCoupledYellow',
        cinco_type: 'Edge',
        cinco_attrs: {
            atom : [' ','text']
        },
        attrs: {
            '.connection': { stroke: 'yellow' },
            '.marker-source': { fill: 'white',stroke: 'white', d: 'M 0 0 L 0 0 L 0 0 z' },
            '.marker-target': { fill: 'white',stroke: 'yellow', d: 'M 10 0 L 0 5 L 10 10 z' }
        }

    },
    setLabel: function() {
        /**
         * Get the needed Attributes for the label
         */
        var attributes = this.attributes.cinco_attrs;
        //EDGE STYLE
        //Position: 1(target), 0(source)
        //fill: text-color
        //font-size
        this.set('labels', [{ position: 0.5, attrs: { text: { dy: -10, text: 'L: '+getAttributeLabel(attributes.atom), fill: 'yellow', 'font-size': 16 }}}]);
    }
});

/**
 * AtomToCoupled
 * @type {void|*}
 */
joint.shapes.devs.AtomToCoupledBlue = joint.dia.Link.extend({

    defaults: {
        type: 'devs.Link',
        cinco_name: 'AtomToCoupledBlue',
        cinco_type: 'Edge',
        cinco_attrs: {
            atom : [' ','text']
        },
        attrs: {
            '.connection': { stroke: 'blue' },
            '.marker-source': { fill: 'white',stroke: 'white', d: 'M 0 0 L 0 0 L 0 0 z' },
            '.marker-target': { fill: 'white',stroke: 'blue', d: 'M 10 0 L 0 5 L 10 10 z' }
        }

    },
    setLabel: function() {
        /**
         * Get the needed Attributes for the label
         */
        var attributes = this.attributes.cinco_attrs;
        //EDGE STYLE
        //Position: 1(target), 0(source)
        //fill: text-color
        //font-size
        this.set('labels', [{ position: 0.5, attrs: { text: { dy: -10, text: 'L: '+getAttributeLabel(attributes.atom), fill: 'blue', 'font-size': 16 }}}]);
    }
});

/**
 * CoupledToAtom
 * @type {void|*}
 */
joint.shapes.devs.CoupledToAtom = joint.dia.Link.extend({

    defaults: {
        type: 'devs.Link',
        cinco_name: 'CoupledToAtom',
        cinco_type: 'Edge',
        cinco_attrs: {
            coupled : [' ','text']
        },
        attrs: {
            '.connection': { stroke: 'red' },
            //fill: backgroundColor, stroke: foreGroundColor
            //d: M 0 0 L 0 0 L 0 0 z NO ARROW
            //d: M 10 0 L 0 5 L 10 10 z DEFAULT ARROW
            '.marker-source': { fill: 'white',stroke: 'white', d: 'M 0 0 L 0 0 L 0 0 z' },
            '.marker-target': { fill: 'white',stroke: 'red', d: 'M 10 0 L 0 5 L 10 10 z' }
        }

    },
    setLabel: function() {
        /**
         * Get the needed Attributes for the label
         */
        var attributes = this.attributes.cinco_attrs;
        //EDGE STYLE
        //Position: 1(target), 0(source)
        //fill: text-color
        //font-size
        this.set('labels', [{
            position: 0.5,
            attrs: {text: {dy: -10, text: 'L: ' + getAttributeLabel(attributes.coupled), fill: 'red', 'font-size': 16}}
        }]);
    }
});

joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);
joint.shapes.devs.BigAtomicView = joint.shapes.devs.ModelView;
joint.shapes.devs.SmallAtomicView = joint.shapes.devs.ModelView;
joint.shapes.devs.CoupledView = joint.shapes.devs.ModelView;


if (typeof exports === 'object') {

    module.exports = joint.shapes.devs;
}
	
	'''
	
	def createNode(StyledModelElement styledModelElement)
	'''
			/**
		 * «styledModelElement.modelElement.name.toFirstUpper»
		 * @type {void|*}
		 */
		joint.shapes.devs.«styledModelElement.modelElement.class.name.toFirstUpper» = joint.shapes.devs.Model.extend({
		    defaults: joint.util.deepSupplement({
		        type: 'devs.«styledModelElement.modelElement.name.toFirstUpper»',
		        cinco_name: '«styledModelElement.modelElement.name.toFirstUpper»',
		        cinco_type: 'Container',
		        «createAttributes(styledModelElement.modelElement)»,
		        size: { width: 200, height: 300 },
		        attrs: {
		            '.body': {
		                width: 200,
		                height: 300,
		                fill: '#ffffff',
		                stroke: '#7c68fc',
		                'stroke-width': 3
		            },
		            '.label': {
		                'font-size': 18
		            }, //Cinco Label
		            '.port-body': {
		                width: (200+ edgeTriggerWidth*2), height: (300 + edgeTriggerWidth*2)
		            }
		        }
		    }, joint.shapes.devs.Model.prototype.defaults),
		    setLabel: function() {
		        /**
		         * Get the needed Attributes for the label
		         */
		        var attributes = this.attributes.cinco_attrs;
		        this.attr('.label',{ text: 'L: '+getAttributeLabel(attributes.name),fill: 'blue'});
		    }
		});
	'''
	
	def createAttributes(GraphicalModelElement modelElement)
	'''
		cinco_attrs: {
		            name: [' ', 'text'],
		            value: [0, 'number'],
		            valid: [true, 'boolean']
		        }
	'''
}