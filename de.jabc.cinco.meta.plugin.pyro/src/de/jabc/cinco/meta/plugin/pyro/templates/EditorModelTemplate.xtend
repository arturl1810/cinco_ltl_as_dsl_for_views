package de.jabc.cinco.meta.plugin.pyro.templates

import mgl.GraphModel
import java.util.ArrayList
import mgl.GraphicalModelElement
import mgl.Attribute
import de.jabc.cinco.meta.plugin.pyro.utils.Formatter
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import de.jabc.cinco.meta.plugin.pyro.model.StyledConnector
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.NodeShape
import de.jabc.cinco.meta.plugin.pyro.model.PolygonPoint
import de.jabc.cinco.meta.plugin.pyro.model.StyledLabel
import mgl.Node
import de.jabc.cinco.meta.plugin.pyro.model.LabelAlignment
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import mgl.Enumeration
import de.jabc4.basic.CreateFolder.SuccessReturn

class EditorModelTemplate implements Templateable{
	
override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums)
'''
	/**
	 * Created by pyro cinco meta plugin
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
	cinco_graphModelAttr = [
	    «FOR Attribute attr : graphModel.attributes  SEPARATOR ', '»
	    	«createAttribute(attr,enums)»
	    «ENDFOR»
	];
	
	/*
	 -------------------------------------------------------
	 -------------Define Nodes and Containers---------------
	 -------------------------------------------------------
	 */
	 
	«FOR StyledNode node: nodes»
		«IF node.modelElement instanceof Node»
			«createNode(node,enums)»
		«ELSE»
			«createContainer(node,enums)»
		«ENDIF»
	«ENDFOR»
	/*
	 -------------------------------------------------------
	 ---------------------Define Edges----------------------
	 -------------------------------------------------------
	 */
	 
	«FOR StyledEdge edge: edges»
		«createEdge(edge,enums)»
	«ENDFOR»
	
	joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);
	«FOR StyledNode node: nodes»
	joint.shapes.devs.«node.modelElement.name»View = joint.shapes.devs.ModelView;
	«ENDFOR»
	
	if (typeof exports === 'object') {
	
	    module.exports = joint.shapes.devs;
	}
'''
	
def createEdge(StyledEdge styledEdge,ArrayList<Type> enums)
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
	        cinco_id: '0',
	        «createAttributes(styledEdge.modelElement,enums)»,
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
	rx: «styledNode.width/4»,
	ry: «styledNode.height/4»,
«ELSEIF styledNode.nodeShape == NodeShape.POLYGON»
	points: '«FOR PolygonPoint p : styledNode.polygonPoints SEPARATOR ' '»«p.toString»«ENDFOR»',
«ELSE»
	«IF styledNode.nodeShape == NodeShape.ROUNDEDRECTANGLE»
	rx:«styledNode.cornerWidth»,
	ry:«styledNode.cornerHeight»,
	«ENDIF»
	width: «styledNode.width»,
	height: «styledNode.height»,
«ENDIF»
'''

def createNodeShapePortBody(StyledNode styledNode)
'''
«IF styledNode.nodeShape == NodeShape.ELLIPSE»
	cx: «styledNode.width/4»,
	cy: «styledNode.width/4»,
	rx: «styledNode.width/4 + 5»,
	ry: «styledNode.height/4 + 5»,
	//'x-ref':
	width: («styledNode.width/4 + 5»),
	height: («styledNode.height/4 + 5»)
«ELSEIF styledNode.nodeShape == NodeShape.POLYGON»
	'transform':'translate(-10,-10)',
	points: '
	«FOR PolygonPoint p : styledNode.polygonPoints SEPARATOR ' '»
		«p.x*1.2»,«p.y*1.2»
	«ENDFOR»',
«ELSE»
	«IF styledNode.nodeShape == NodeShape.ROUNDEDRECTANGLE»
	rx:«styledNode.cornerWidth»,
	ry:«styledNode.cornerHeight»,
	«ENDIF»
	width: «styledNode.width + 20»,
	height: «styledNode.height + 20»
«ENDIF»
'''
	
def createNode(StyledNode styledNode,ArrayList<Type> enums)
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
	        «createAttributes(styledNode.modelElement,enums)»,
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

def createContainer(StyledNode styledNode,ArrayList<Type> enums)
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
	        «createAttributes(styledNode.modelElement,enums)»,
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
	
def createAttributes(GraphicalModelElement modelElement,ArrayList<Type> enums)
'''
	cinco_attrs: [
		«IF !modelElement.attributes.empty»
		«FOR Attribute attr : modelElement.attributes  SEPARATOR ', '»
	        «createAttribute(attr,enums)»
	    «ENDFOR»
	    «ENDIF»
	        ]
'''
def createAttribute(Attribute attr,ArrayList<Type> enums)
'''
	«IF attr.upperBound == 1 && (attr.lowerBound == 0 || attr.lowerBound == 1) »
	«createPrimativeAttribute(attr,enums)»
	«ELSE»
	«createListAttribute(attr,enums)»
	«ENDIF»
	
'''

def createListAttribute(Attribute attr,ArrayList<Type> enums)
'''
	{
		name: '«attr.name»',
		type: 'list',
		subtype: «createPrimativeAttribute(attr,enums)»,
		upper: «attr.upperBound»,
		lower: «attr.lowerBound»,
		values:
		[
		«IF attr.lowerBound > 0»
		«FOR Integer i: 1..attr.lowerBound SEPARATOR ','»
		«createPrimativeAttribute(attr,enums)»
		«ENDFOR»
		«ENDIF»
		]
	}
'''

def getAttributeType(String type) {
	if(type.equals("EString")) return "text";
	if(type.equals("EInt")) return "number";
	if(type.equals("EDouble")) return "double";
	if(type.equals("EBoolean")) return "boolean";
	//ENUM
	return "choice";
}

def public String getAttributeDefault(Attribute attr, ArrayList<Type> enums) {
	if(attr.type.equals("EString")) return "''";
	if(attr.type.equals("EInt")) return "0";
	if(attr.type.equals("EDouble")) return "0.00";
	if(attr.type.equals("EBoolean")) return "false";
	//ENUM
	var type = getEnumByName(attr,enums) as Enumeration;
	if(type == null) { 
		return "''";
	}
	else {
		return ""+createEnumAttribute(attr,type);	
	}

}

def createEnumAttribute(Attribute attr,Enumeration e)
'''
{
	«IF attr.defaultValue != null && !attr.defaultValue.isEmpty»
	selected: '«attr.defaultValue»',
	«ELSE»
	selected: '«e.literals.get(0)»',
	«ENDIF»
	choices : [
«FOR String literal : e.literals SEPARATOR ','»
			'«literal»'
«ENDFOR»
	]
}
'''

def getEnumByName(Attribute attr, ArrayList<Type> enums) {
	var typeName = attr.type;
	for(Type type : enums) {
		if(type.name.equals(typeName)){
			return type;
		}
	}
	return null;
	
}


def createPrimativeAttribute(Attribute attr,ArrayList<Type> enums)
'''
	{
		name: '«attr.name»',
		type: '«getAttributeType(attr.type)»',
		values: «getAttributeDefault(attr,enums)»
	}
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