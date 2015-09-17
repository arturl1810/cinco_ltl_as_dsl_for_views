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
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage

class SVGModelTemplate implements Templateable{
	
override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
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
		«JointModelTemplate.createNodeModel(node,enums)»
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




	
static def createAttributes(GraphicalModelElement modelElement,ArrayList<Type> enums)
'''
	cinco_attrs: [
		«IF modelElement instanceof mgl.Node»
		«IF (modelElement as mgl.Node).primeReference != null»
		{
			name: 'prime',
			type: 'text',
			option: 'disabled',
			values: ''
		},
		«ENDIF»
		«ENDIF»
		«IF !modelElement.attributes.empty»
		«FOR Attribute attr : ModelParser.getNoUserDefinedAttributtes(modelElement.attributes,enums)  SEPARATOR ', '»
	        «createAttribute(attr,enums)»
	    «ENDFOR»
	    «ENDIF»
	        ]
'''
static def createAttribute(Attribute attr,ArrayList<Type> enums)
'''
	«IF attr.upperBound == 1 && (attr.lowerBound == 0 || attr.lowerBound == 1) »
	«createPrimativeAttribute(attr,enums)»
	«ELSE»
	«createListAttribute(attr,enums)»
	«ENDIF»
	
'''

static def createListAttribute(Attribute attr,ArrayList<Type> enums)
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

static def getAttributeType(String type) {
	if(type.equals("EString")) return "text";
	if(type.equals("EInt")) return "number";
	if(type.equals("EDouble")) return "double";
	if(type.equals("EBoolean")) return "boolean";
	//ENUM
	return "choice";
}

static def public String getAttributeDefault(Attribute attr, ArrayList<Type> enums) {
	if(attr.type.equals("EString")) return "''";
	if(attr.type.equals("EInt")) return "0";
	if(attr.type.equals("EDouble")) return "0.00";
	if(attr.type.equals("EBoolean")) return "false";
	//ENUM
	if(!ModelParser.isUserDefinedType(attr,enums)) {
		var type = getEnumByName(attr,enums) as Enumeration;
		if(type == null) { 
			return "''";
		}
		else {
			return ""+createEnumAttribute(attr,type);	
		}		
	}
	return "''";

}

static def createEnumAttribute(Attribute attr,Enumeration e)
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

static def getEnumByName(Attribute attr, ArrayList<Type> enums) {
	var typeName = attr.type;
	for(Type type : enums) {
		if(type.name.equals(typeName)){
			return type;
		}
	}
	return null;
	
}


static def createPrimativeAttribute(Attribute attr,ArrayList<Type> enums)
'''
	{
		name: '«attr.name»',
		type: '«getAttributeType(attr.type)»',
		values: «getAttributeDefault(attr,enums)»
	}
'''

static def createLabel(StyledLabel styledLabel)
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