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
		«createNode(node)»
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
	joint.shapes.devs.«node.modelElement.name» = joint.shapes.devs.ModelView;
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
	        		position: «styledEdge.labelLocation»,
	        		attrs: {
	        			text: {
	        				dy: -10,
	        				text: 'L: '+getAttributeLabel(attributes.atom),
	        				fill: '#«Formatter.toHex(styledEdge.labelColor)»',
	        				'font-size': «styledEdge.labelFontSize»
	        			}
	        		}
	        	}
	        ]);
	    }
	});
'''

def createEdgeDecorator(StyledConnector styledConnector)
'''
	fill: '#«Formatter.toHex(styledConnector.backgroundColor)»',
	stroke: '#«Formatter.toHex(styledConnector.backgroundColor)»',
	 d: 'M «styledConnector.m1» «styledConnector.m2» L «styledConnector.l11» «styledConnector.l12» L «styledConnector.l21» «styledConnector.l22» z'
'''
	
def createNode(StyledNode styledNode)
'''
		/**
	 * «styledNode.modelElement.name.toFirstUpper»
	 * @type {void|*}
	 */
	joint.shapes.devs.«styledNode.modelElement.class.name.toFirstUpper» = joint.shapes.devs.Model.extend({
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
	                width: «styledNode.width»,
	                height: «styledNode.width»,
	                fill: '#«Formatter.toHex(styledNode.backgroundColor)»',
	                stroke: '#«Formatter.toHex(styledNode.foregroundColor)»',
	                'stroke-width': «styledNode.lineWidth»
	            },
	            '.label': {
	                'font-size': «styledNode.labelFontSize»
	            },
	            '.port-body': {
	                width: («styledNode.width»+ edgeTriggerWidth*2),
	                height: («styledNode.height» + edgeTriggerWidth*2)
	            }
	        }
	    }, joint.shapes.devs.Model.prototype.defaults),
	    setLabel: function() {
	        /**
	         * Get the needed Attributes for the label
	         */
	        var attributes = this.attributes.cinco_attrs;
	        this.attr('.label',{
	        	text: 'L: '+getAttributeLabel(attributes.name),
	        	fill: '#«Formatter.toHex(styledNode.labelColor)»',
	        	'font-size': «styledNode.labelFontSize»
	        });
	    }
	});
'''
	
def createAttributes(GraphicalModelElement modelElement)
'''
	cinco_attrs: {
		«FOR Attribute attr : modelElement.attributes  SEPARATOR ', '»
	        «createAttribute(attr)»
	    «ENDFOR»
	        }
'''
	
def createAttribute(Attribute attr)
'''
	«IF attr.eClass.name.equals("EString")»
	«attr.name»: [' ', 'text']
	«ELSEIF attr.eClass.name.equals("EBoolean")»
	«attr.name»: [false, 'boolean']
	«ELSEIF attr.eClass.name.equals("EList")»
	«attr.name»: [
		{ 
		selected: 'one',
		choices : ['one','two','three']
		},
		'map']
	«ELSEIF attr.eClass.name.equals("EInt")»
	«attr.name»: [0, 'number']
	«ELSEIF attr.eClass.name.equals("EDouble")»
	«attr.name»: [0.00, 'double']
	«ENDIF»
	
'''

	
}