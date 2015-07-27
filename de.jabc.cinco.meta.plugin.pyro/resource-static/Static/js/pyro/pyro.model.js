	/**
	 * Created by pyro cinco meta plugin
	 * For Graphmodel FlowGraph
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
	
	/**
 * RECTANGLE Rounded
 * @type {void|*}
 */
joint.shapes.devs.ModelRect = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {

    type_name: 'modelRect',
    markup: '<g class="rotatable"><g class="scalable"><g class="inPorts"/><g class="outPorts"/><rect class="body"/></g><text class="label"/></g>',
    portMarkup: '<g class="port port<%= id %>"><rect class="port-body"/><text class="port-label"/></g>',

    defaults: joint.util.deepSupplement({

        type: 'devs.ModelRect',
        cinco_attrs: {},
        cinco_id: '0',
        cinco_name: 'NoName',
        cinco_type: 'element',

        inPorts: [''],
        outPorts: [],

        attrs: {
            '.scalable' :{
                transform : "scale(0.5,0.5)"
            },
            '.': { magnet: false },
            '.body': {
                stroke: '#ffffff'
            },
            '.port-body': {
                'transform':'translate(-10,-10)',
                magnet: false,
                fill: '#transparent',
                stroke: '#ffffff'
            },
            text: {
                'pointer-events': 'none'
            },
            '.label': { text: 'ModelRect', 'ref-x': .5, 'ref-y': 10, ref: '.body', 'text-anchor': 'middle' },
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
        attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };

        if (selector === '.outPorts') {
            attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };
        }

        return attrs;
    }
}));

/**
 * ELLIPSE
 * @type {void|*}
 */
joint.shapes.devs.ModelEllipse = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {

    type_name: 'modelEllipse',
    markup: '<g class="rotatable"><g class="scalable"><g class="inPorts"/><g class="outPorts"/><ellipse class="body"/></g><text class="label"/></g>',
    portMarkup: '<g class="port port<%= id %>"><ellipse class="port-body"/><text class="port-label"/></g>',

    defaults: joint.util.deepSupplement({

        type: 'devs.ModelEllipse',
        cinco_attrs: {},
        cinco_id: '0',
        cinco_name: 'NoName',
        cinco_type: 'element',

        inPorts: [''],
        outPorts: [],

        attrs: {
            '.scalable' :{
                transform : "scale(1,1)"
            },
            '.': { magnet: false },
            '.body': {
                stroke: '#ffffff',
                cx: 0,
                cy: 0,
                rx: 0,
                ry: 0
            },
            '.port-body': {
                magnet: false,
                fill: '#transparent',
                stroke: '#ffffff',
                cx: 0,
                cy: 0,
                rx: 0,
                ry: 0
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
        attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };

        if (selector === '.outPorts') {
            attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };
        }

        return attrs;
    }
}));

/**
 * POLYGON
 * @type {void|*}
 */
joint.shapes.devs.ModelPolygon = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {

    type_name: 'modelPolygon',
    markup: '<g class="rotatable"><g class="scalable"><g class="inPorts"/><g class="outPorts"/><polygon class="body"/></g><text class="label"/></g>',
    portMarkup: '<g class="port port<%= id %>"><polygon class="port-body"/><text class="port-label"/></g>',

    defaults: joint.util.deepSupplement({

        type: 'devs.ModelPolygon',
        cinco_attrs: {},
        cinco_id: '0',
        cinco_name: 'NoName',
        cinco_type: 'element',

        inPorts: [''],
        outPorts: [],

        attrs: {
            '.scalable' :{
                transform : "scale(0.5,0.5)"
            },
            '.': { magnet: false },
            '.body': {
                points: '0,0 50,50 100,0', //Polygon Points
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
        attrs[portSelector] = { ref: '.body', 'ref-y':0, 'ref-x' :0 };

        if (selector === '.outPorts') {
            attrs[portSelector] = { ref: '.body', 'ref-y': (0), 'ref-x' : (0) };
        }

        return attrs;
    }
}));
	
	/**
	 * GraphModel Attributes
	 * @type {{GraphModel: string[]}}
	 */
	cinco_graphModelAttr = [
	    {
	    	name: 'modelName',
	    	type: 'text',
	    	values: ''
	    }, 
	    
	    {
	    	name: 'trigger',
	    	type: 'boolean',
	    	values: false
	    }, 
	    
	    {
	    	name: 'decimal',
	    	type: 'double',
	    	values: 0.00
	    }
	    
	];
	
	/*
	 -------------------------------------------------------
	 -------------Define Nodes and Containers---------------
	 -------------------------------------------------------
	 */
	 
		/**
	 * Start
	 * @type {void|*}
	 */
	joint.shapes.devs.Start = joint.shapes.devs.ModelEllipse
	.extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.Start',
	        cinco_name: 'Start',
	        cinco_type: 'Node',
	        cinco_attrs: [
	        {
	        	name: 'fooList',
	        	type: 'list',
	        	subtype: {
	        		name: 'fooList',
	        		type: 'number',
	        		values: 0
	        	}
	        	,
	        	upper: -1,
	        	lower: 0,
	        	values:
	        	[
	        	]
	        }, 
	        
	        {
	        	name: 'foo',
	        	type: 'text',
	        	values: ''
	        }
	        
	                ]
	        ,
	        size: { 
	        	width: 36,
	        	height: 36
	        },
	        attrs: {
	            '.body': {
	            	cx: 0,
	            	cy: 0,
	            	rx: 9,
	            	ry: 9,
	                fill: '#ffffff',
	                stroke: '#519c58',
	                'stroke-width': 2
	            },
	            '.label': {
		        	'ref-y': 2
	            },
	            '.port-body': {
	                cx: 9,
	                cy: 9,
	                rx: 14,
	                ry: 14,
	                //'x-ref':
	                width: (14),
	                height: (14)
	            }
	        }
	    }, joint.shapes.devs.ModelEllipse
	    .prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: '',
	        	'ref-y': 2
				
	        });
	    }
	});
		/**
	 * End
	 * @type {void|*}
	 */
	joint.shapes.devs.End = joint.shapes.devs.ModelEllipse
	.extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.End',
	        cinco_name: 'End',
	        cinco_type: 'Node',
	        cinco_attrs: [
	        {
	        	name: 'enabled',
	        	type: 'choice',
	        	values: {
	        		selected: 'A',
	        		choices : [
	        	'A',
	        	'B',
	        	'C'
	        		]
	        	}
	        }
	        
	                ]
	        ,
	        size: { 
	        	width: 36,
	        	height: 36
	        },
	        attrs: {
	            '.body': {
	            	cx: 0,
	            	cy: 0,
	            	rx: 9,
	            	ry: 9,
	                fill: '#ffffff',
	                stroke: '#a41d1d',
	                'stroke-width': 2
	            },
	            '.label': {
		        	'ref-y': 2
	            },
	            '.port-body': {
	                cx: 9,
	                cy: 9,
	                rx: 14,
	                ry: 14,
	                //'x-ref':
	                width: (14),
	                height: (14)
	            }
	        }
	    }, joint.shapes.devs.ModelEllipse
	    .prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: '',
	        	'ref-y': 2
				
	        });
	    }
	});
		/**
	 * Activity
	 * @type {void|*}
	 */
	joint.shapes.devs.Activity = joint.shapes.devs.ModelRect
	.extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.Activity',
	        cinco_name: 'Activity',
	        cinco_type: 'Node',
	        cinco_attrs: [
	        {
	        	name: 'name',
	        	type: 'text',
	        	values: ''
	        }, 
	        
	        {
	        	name: 'description',
	        	type: 'text',
	        	values: ''
	        }
	        
	                ]
	        ,
	        size: { 
	        	width: 96,
	        	height: 32
	        },
	        attrs: {
	            '.body': {
	            	rx:8,
	            	ry:8,
	            	width: 96,
	            	height: 32,
	                fill: '#90cfee',
	                stroke: '#000000',
	                'stroke-width': 2
	            },
	            '.label': {
	fill: '#000000',
	'font-size': 6,
	'font-family': 'Arial',
	'font-weight': 'NORMAL',
	'text-anchor': 'center',
	'x-alignment': 'middle',
	'ref-x': .5,
		        	'ref-y': 2
	            },
	            '.port-body': {
	                rx:8,
	                ry:8,
	                width: 116,
	                height: 52
	            }
	        }
	    }, joint.shapes.devs.ModelRect
	    .prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: ''+ getAttributeLabel(attributes,'name') +'',
	        	fill: '#000000',
	        	'font-size': 6,
	        	'font-family': 'Arial',
	        	'font-weight': 'NORMAL',
	        	'text-anchor': 'center',
	        	'x-alignment': 'middle',
	        	'ref-x': .5,
	        	'ref-y': 2
				
	        });
	    }
	});
		/**
	 * Swimlane
	 * @type {void|*}
	 */
	joint.shapes.devs.Swimlane = joint.shapes.devs.ModelRect
	.extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.Swimlane',
	        cinco_name: 'Swimlane',
	        cinco_type: 'Container',
	        cinco_attrs: [
	        {
	        	name: 'actor',
	        	type: 'text',
	        	values: ''
	        }, 
	        
	        {
	        	name: 'boolList',
	        	type: 'list',
	        	subtype: {
	        		name: 'boolList',
	        		type: 'boolean',
	        		values: false
	        	}
	        	,
	        	upper: 5,
	        	lower: 2,
	        	values:
	        	[
	        	{
	        		name: 'boolList',
	        		type: 'boolean',
	        		values: false
	        	},
	        	{
	        		name: 'boolList',
	        		type: 'boolean',
	        		values: false
	        	}
	        	]
	        }, 
	        
	        {
	        	name: 'enumList',
	        	type: 'list',
	        	subtype: {
	        		name: 'enumList',
	        		type: 'choice',
	        		values: {
	        			selected: 'A',
	        			choices : [
	        		'A',
	        		'B',
	        		'C'
	        			]
	        		}
	        	}
	        	,
	        	upper: 2,
	        	lower: 0,
	        	values:
	        	[
	        	]
	        }, 
	        
	        {
	        	name: 'textList',
	        	type: 'list',
	        	subtype: {
	        		name: 'textList',
	        		type: 'text',
	        		values: ''
	        	}
	        	,
	        	upper: -1,
	        	lower: 1,
	        	values:
	        	[
	        	{
	        		name: 'textList',
	        		type: 'text',
	        		values: ''
	        	}
	        	]
	        }
	        
	                ]
	        ,
	        size: { 
	        	width: 400,
	        	height: 100
	        },
	        attrs: {
	            '.body': {
	            	width: 400,
	            	height: 100,
	                fill: '#ffecca',
	                stroke: '#000000',
	                'stroke-width': 1
	            },
	            '.label': {
	fill: '#000000',
	'font-size': 6,
	'font-family': 'Arial',
	'font-weight': 'NORMAL',
	'text-anchor': 'center',
	'x-alignment': 'middle',
	'ref-x': .5,
		        	'ref-y': 1
	            },
	            '.port-body': {
	                width: 420,
	                height: 120
	            }
	        }
	    }, joint.shapes.devs.ModelRect
	    .prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: ''+ getAttributeLabel(attributes,'actor') +'',
	        	fill: '#000000',
	        	'font-size': 6,
	        	'font-family': 'Arial',
	        	'font-weight': 'NORMAL',
	        	'text-anchor': 'center',
	        	'x-alignment': 'middle',
	        	'ref-x': .5,
	        	'ref-y': 1
				
	        });
	    }
	});
	/*
	 -------------------------------------------------------
	 ---------------------Define Edges----------------------
	 -------------------------------------------------------
	 */
	 
	/**
	 * Transition
	 * @type {void|*}
	 */
	joint.shapes.devs.Transition = joint.dia.Link.extend({
	
	    defaults: {
	        type: 'devs.Link',
	        cinco_name: 'Transition',
	        cinco_type: 'Edge',
	        cinco_attrs: [
	                ]
	        ,
	        attrs: {
	            '.connection': { 
	            	stroke: '#000000',
	            	'stroke-width': 1
	            },
	            '.marker-source': {
	            	fill: '#ffffff',
	            	stroke: '#000000',
	            	"stroke-width": 2.0, 
	            	d: 'M 0 0 L 0 0 L 0 0 z'
	            },
	            '.marker-target': {
	            	fill: '#90cfee',
	            	stroke: '#000000',
	            	"stroke-width": 1.0, 
	            	d: 'M 0 0 L 2.0 2.0 0 0 L 2.0 -2.0 0 0 2.0 0 z'
	            }
	        }
	
	    },
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.set('labels', [
	        	{
	        		position: 0.0
	        	}
	        ]);
	    }
	});
	/**
	 * LabeledTransition
	 * @type {void|*}
	 */
	joint.shapes.devs.LabeledTransition = joint.dia.Link.extend({
	
	    defaults: {
	        type: 'devs.Link',
	        cinco_name: 'LabeledTransition',
	        cinco_type: 'Edge',
	        cinco_attrs: [
	        {
	        	name: 'label',
	        	type: 'text',
	        	values: ''
	        }
	        
	                ]
	        ,
	        attrs: {
	            '.connection': { 
	            	stroke: '#000000',
	            	'stroke-width': 1
	            },
	            '.marker-source': {
	            	fill: '#ffffff',
	            	stroke: '#000000',
	            	"stroke-width": 2.0, 
	            	d: 'M 0 0 L 0 0 L 0 0 z'
	            },
	            '.marker-target': {
	            	fill: '#90cfee',
	            	stroke: '#000000',
	            	"stroke-width": 1.0, 
	            	d: 'M 0 0 L 2.0 2.0 0 0 L 2.0 -2.0 0 0 2.0 0 z'
	            }
	        }
	
	    },
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.set('labels', [
	        	{
		        		position: 0.3,
							attrs: {
	text: {
		text: ''+ getAttributeLabel(attributes,'label') +'',
	fill: '#000000',
	'font-size': 6,
	'font-family': 'Arial',
	'font-weight': 'NORMAL',
	'text-anchor': 'center',
	'x-alignment': 'middle',
	'ref-x': .5,
		dy: -10
		}
	}
	        	}
	        ]);
	    }
	});
	
	joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);
	joint.shapes.devs.StartView = joint.shapes.devs.ModelView;
	joint.shapes.devs.EndView = joint.shapes.devs.ModelView;
	joint.shapes.devs.ActivityView = joint.shapes.devs.ModelView;
	joint.shapes.devs.SwimlaneView = joint.shapes.devs.ModelView;
	
	if (typeof exports === 'object') {
	
	    module.exports = joint.shapes.devs;
	}
