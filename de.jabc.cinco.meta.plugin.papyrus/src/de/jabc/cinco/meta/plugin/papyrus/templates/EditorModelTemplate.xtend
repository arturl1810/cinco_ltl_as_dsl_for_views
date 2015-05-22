package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import mgl.GraphicalModelElement
import mgl.Attribute
import de.jabc.cinco.meta.plugin.papyrus.utils.Formatter
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector
import java.util.HashMap
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.papyrus.model.NodeShape
import de.jabc.cinco.meta.plugin.papyrus.model.PolygonPoint
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel
import mgl.Node
import de.jabc.cinco.meta.plugin.papyrus.model.LabelAlignment

class EditorModelTemplate implements Templateable{
	
override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections)
'''
		/**
	 * Created by papyrus cinco meta plugin
	 * For Graphmodel «graphModel.name»
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
	cinco_graphModelAttr = {
	    «FOR Attribute attr : graphModel.attributes  SEPARATOR ', '»
	    	«createAttribute(attr)»
	    «ENDFOR»
	};
	
	/*
	 -------------------------------------------------------
	 -------------Define Nodes and Containers---------------
	 -------------------------------------------------------
	 */
	 
	«FOR StyledNode node: nodes»
		«IF node.modelElement instanceof Node»
			«createNode(node)»
		«ELSE»
			«createContainer(node)»
		«ENDIF»
	«ENDFOR»
	/*
	 -------------------------------------------------------
	 ---------------------Define Edges----------------------
	 -------------------------------------------------------
	 */
	 
	«FOR StyledEdge edge: edges»
		«createEdge(edge)»
	«ENDFOR»
	
	joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);
	«FOR StyledNode node: nodes»
	joint.shapes.devs.«node.modelElement.name»View = joint.shapes.devs.ModelView;
	«ENDFOR»
	
	if (typeof exports === 'object') {
	
	    module.exports = joint.shapes.devs;
	}
'''
	
def createEdge(StyledEdge styledEdge)
'''
	/**
	 * «styledEdge.modelElement.name.toFirstUpper»
	 * @type {void|*}
	 */
	joint.shapes.devs.«styledEdge.modelElement.name.toFirstUpper» = joint.dia.Link.extend({
	
	    defaults: {
	        type: 'devs.Link',
	        cinco_name: '«styledEdge.modelElement.name.toFirstUpper»',
	        cinco_type: 'Edge',
	        «createAttributes(styledEdge.modelElement)»,
	        attrs: {
	            '.connection': { 
	            	stroke: '#«Formatter.toHex(styledEdge.foregroundColor)»',
	            	'stroke-width': «styledEdge.lineWidth»
	            },
	            '.marker-source': {
	            	«createEdgeDecorator(styledEdge.sourceConnector)»
	            },
	            '.marker-target': {
	            	«createEdgeDecorator(styledEdge.targetConnector)»
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
	        		«IF styledEdge.styledLabel != null»
	        		position: «styledEdge.styledLabel.location»,
					attrs: {
						text: {
							text: '«Formatter.getLabelText(styledEdge)»',
							«IF styledEdge.styledLabel != null»
					    	«createLabel(styledEdge.styledLabel)»
					    	«ENDIF»
							dy: -10
						}
					}
	        		«ELSE»
	        		position: 0.0
	        		«ENDIF»
	        	}
	        ]);
	    }
	});
'''

def createEdgeDecorator(StyledConnector styledConnector)
'''
	fill: '#«Formatter.toHex(styledConnector.backgroundColor)»',
	stroke: '#«Formatter.toHex(styledConnector.foregroundColor)»',
	"stroke-width": «styledConnector.lineWidth», 
	«styledConnector.polygonPoints»
'''

def createNodeShape(StyledNode styledNode)
'''
«IF styledNode.nodeShape == NodeShape.ELLIPSE»
	ModelEllipse
«ELSEIF styledNode.nodeShape == NodeShape.POLYGON»
	ModelPolygon
«ELSE»
	ModelRect
«ENDIF»
'''

def createNodeShapeBody(StyledNode styledNode)
'''
«IF styledNode.nodeShape == NodeShape.ELLIPSE»
	cx: 0,
	cy: 0,
	rx: «styledNode.width/2»,
	ry: «styledNode.height/2»,
«ELSEIF styledNode.nodeShape == NodeShape.POLYGON»
	points: '«FOR PolygonPoint p : styledNode.polygonPoints SEPARATOR ' '»«p.toString»«ENDFOR»',
«ELSE»
	width: «styledNode.width»,
	height: «styledNode.height»,
«ENDIF»
'''

def createNodeShapePortBody(StyledNode styledNode)
'''
«IF styledNode.nodeShape == NodeShape.ELLIPSE»
	cx: 8,
	cy: 8,
	rx: «styledNode.width/2 - 6»,
	ry: «styledNode.height/2 - 6»,
	//'x-ref':
	width: («styledNode.width + 5»),
	height: («styledNode.height + 5»)
«ELSEIF styledNode.nodeShape == NodeShape.POLYGON»
	'transform':'translate(-10,-10)',
	points: '
	«FOR PolygonPoint p : styledNode.polygonPoints SEPARATOR ' '»
		«p.x*1.2»,«p.y*1.2»
	«ENDFOR»',
«ELSE»
	width: «styledNode.width + 20»,
	height: «styledNode.height + 20»
«ENDIF»
'''
	
def createNode(StyledNode styledNode)
'''
		/**
	 * «styledNode.modelElement.name.toFirstUpper»
	 * @type {void|*}
	 */
	joint.shapes.devs.«styledNode.modelElement.name.toFirstUpper» = joint.shapes.devs.«createNodeShape(styledNode)».extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.«styledNode.modelElement.name.toFirstUpper»',
	        cinco_name: '«styledNode.modelElement.name.toFirstUpper»',
	        cinco_type: 'Node',
	        «createAttributes(styledNode.modelElement)»,
	        size: { 
	        	width: «styledNode.width»,
	        	height: «styledNode.height»
	        },
	        attrs: {
	            '.body': {
	            	«createNodeShapeBody(styledNode)»
	                fill: '#«Formatter.toHex(styledNode.backgroundColor)»',
	                stroke: '#«Formatter.toHex(styledNode.foregroundColor)»',
	                'stroke-width': «styledNode.lineWidth»
	            },
	            '.label': {
	                «IF styledNode.styledLabel != null»
		        	«createLabel(styledNode.styledLabel)»
		        	«ENDIF»
		        	'ref-y': «styledNode.lineWidth»
	            },
	            '.port-body': {
	                «createNodeShapePortBody(styledNode)»
	            }
	        }
	    }, joint.shapes.devs.«createNodeShape(styledNode)».prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: '«Formatter.getLabelText(styledNode)»',
	        	«IF styledNode.styledLabel != null»
	        	«createLabel(styledNode.styledLabel)»
	        	«ENDIF»
	        	'ref-y': «styledNode.lineWidth»
				
	        });
	    }
	});
'''

def createContainer(StyledNode styledNode)
'''
		/**
	 * «styledNode.modelElement.name.toFirstUpper»
	 * @type {void|*}
	 */
	joint.shapes.devs.«styledNode.modelElement.name.toFirstUpper» = joint.shapes.devs.«createNodeShape(styledNode)».extend({
	    defaults: joint.util.deepSupplement({
	        type: 'devs.«styledNode.modelElement.name.toFirstUpper»',
	        cinco_name: '«styledNode.modelElement.name.toFirstUpper»',
	        cinco_type: 'Container',
	        «createAttributes(styledNode.modelElement)»,
	        size: { 
	        	width: «styledNode.width»,
	        	height: «styledNode.height»
	        },
	        attrs: {
	            '.body': {
	            	«createNodeShapeBody(styledNode)»
	                fill: '#«Formatter.toHex(styledNode.backgroundColor)»',
	                stroke: '#«Formatter.toHex(styledNode.foregroundColor)»',
	                'stroke-width': «styledNode.lineWidth»
	            },
	            '.label': {
	                «IF styledNode.styledLabel != null»
	 				«createLabel(styledNode.styledLabel)»
		        	«ENDIF»
		        	'ref-y': «styledNode.lineWidth»
	            },
	            '.port-body': {
	                «createNodeShapePortBody(styledNode)»
	            }
	        }
	    }, joint.shapes.devs.«createNodeShape(styledNode)».prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: '«Formatter.getLabelText(styledNode)»',
	        	«IF styledNode.styledLabel != null»
	        	«createLabel(styledNode.styledLabel)»
	        	«ENDIF»
	        	'ref-y': «styledNode.lineWidth»
				
	        });
	    }
	});
'''
	
def createAttributes(GraphicalModelElement modelElement)
'''
	cinco_attrs: {
		«IF !modelElement.attributes.empty»
		«FOR Attribute attr : modelElement.attributes  SEPARATOR ', '»
	        «createAttribute(attr)»
	    «ENDFOR»
	    «ENDIF»
	        }
'''
//TODO EList
def createAttribute(Attribute attr)
'''
	«IF attr.type.equals("EString")»
	«attr.name»: [' ', 'text']
	«ELSEIF attr.type.equals("EBoolean")»
	«attr.name»: [false, 'boolean']
	«ELSEIF attr.type.equals("EList")»
	«attr.name»: [
		{ 
		selected: 'one',
		choices : ['one','two','three']
		},
		'map']
	«ELSEIF attr.type.equals("EInt")»
	«attr.name»: [0, 'number']
	«ELSEIF attr.type.equals("EDouble")»
	«attr.name»: [0.00, 'double']
	«ENDIF»
	
'''

def createLabel(StyledLabel styledLabel)
'''
				fill: '#«Formatter.toHex(styledLabel.labelColor)»',
				'font-size': «styledLabel.labelFontSize»,
				'font-family': '«styledLabel.fontName»',
				'font-weight': '«styledLabel.fontType»',
				'text-anchor': 'center',
				«IF styledLabel.lableAlignment == LabelAlignment.RIGHT»
				'x-alignment': 'right',
				«ELSEIF styledLabel.lableAlignment == LabelAlignment.LEFT»
				'x-alignment': 'left',
				«ELSE»
				'x-alignment': 'middle',
				«ENDIF»
				'ref-x': .5,
'''

	
}