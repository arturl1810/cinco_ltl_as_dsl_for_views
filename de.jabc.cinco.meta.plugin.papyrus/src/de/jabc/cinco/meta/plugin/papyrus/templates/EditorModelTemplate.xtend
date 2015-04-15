package de.jabc.cinco.meta.plugin.papyrus.templates

import mgl.GraphModel
import java.util.ArrayList
import mgl.Node
import mgl.Edge
import de.jabc.cinco.meta.plugin.papyrus.StyledModelElement
import mgl.GraphicalModelElement
import mgl.Attribute

class EditorModelTemplate implements Templateable{
	
override create(GraphModel graphModel,ArrayList<StyledModelElement> nodes,ArrayList<StyledModelElement> edges)
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
	/*
	 -------------------------------------------------------
	 -------------Define Nodes and Containers---------------
	 -------------------------------------------------------
	 */
	
	
	/**
	 * GraphModel Attributes
	 * @type {{GraphModel: string[]}}
	 */
	cinco_graphModelAttr = {
	    «FOR Attribute attr : graphModel.attributes  SEPARATOR ', '»
	    	«createAttribute(attr)»
	    «ENDFOR»
	};
	
	«FOR StyledModelElement modelElement: nodes»
		«createNode(modelElement)»
	«ENDFOR»
	
	/*
	 -------------------------------------------------------
	 ---------------------Define Edges----------------------
	 -------------------------------------------------------
	 */
	
	«FOR StyledModelElement modelElement: edges»
		«createNode(modelElement)»
	«ENDFOR»
	
	joint.shapes.devs.ModelView = joint.dia.ElementView.extend(joint.shapes.basic.PortsViewInterface);
	«FOR StyledModelElement modelElement: nodes»
	joint.shapes.devs.«modelElement.modelElement.name» = joint.shapes.devs.ModelView;
	«ENDFOR»
	
	if (typeof exports === 'object') {
	
	    module.exports = joint.shapes.devs;
	}
'''
	
def createEdge(StyledModelElement styledEdge)
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
	        size: { width: «styledModelElement», height: 300 },
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