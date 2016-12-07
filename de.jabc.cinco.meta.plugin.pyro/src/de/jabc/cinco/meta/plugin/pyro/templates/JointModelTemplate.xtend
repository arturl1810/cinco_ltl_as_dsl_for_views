package de.jabc.cinco.meta.plugin.pyro.templates

import de.jabc.cinco.meta.plugin.pyro.model.StyledModelElement
import style.NodeStyle
import style.AbstractShape
import style.ContainerShape
import style.Shape
import style.Polyline
import style.Image
import style.Rectangle
import style.Ellipse
import javax.annotation.processing.RoundEnvironment
import style.RoundedRectangle
import style.Polygon
import style.Point
import style.AbsolutPosition
import style.Alignment
import style.Text
import style.MultiText
import mgl.NodeContainer
import mgl.Type
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.utils.Formatter
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser
import style.Appearance
import style.LineStyle
import style.Font
import style.HAlignment
import style.VAlignment
import java.util.Set
import java.util.Map
import mgl.GraphicalModelElement
import java.util.List

class JointModelTemplate {
	
	static def createAbstractShape(AbstractShape abstractShape,int i)
	'''
	«IF abstractShape instanceof Shape»
		«IF abstractShape instanceof Polyline»
		'<polygon class="po«i» body"/>'+
		«ELSEIF abstractShape instanceof Image»
		'<image class="im«i» body"/>'+
		«ELSE»
		'<text class="te«i» body-label"/>'+
		«ENDIF»
	«ELSE»
		«IF abstractShape instanceof Polygon»
		'<polygon class="po«i» body"/>'+
		«ELSEIF abstractShape instanceof Ellipse»
		'<ellipse class="el«i» body"/>'+
		«ELSE»
		'<rect class="re«i» body"/>'+
		«ENDIF»
		«var counter = i»
		«FOR AbstractShape shape:(abstractShape as ContainerShape).children»
		«{counter = counter +1;""}»
		«createAbstractShape(shape,counter)»
		«ENDFOR»
    «ENDIF»
	'''
	
	static def getDashArray(Appearance appearance){
		if(appearance.lineStyle == null){
			return "[0]";
		}
		if(appearance.lineStyle == LineStyle.DASH)
		{
			return "[5, 5]";
		}
		if(appearance.lineStyle == LineStyle.DASHDOT)
		{
			return "[5, 2]";
		}
		if(appearance.lineStyle == LineStyle.DASHDOTDOT)
		{
			return "[5, 2, 2]";
		}
		if(appearance.lineStyle == LineStyle.SOLID)
		{
			return "[0]";
		}
		if(appearance.lineStyle == LineStyle.DOT)
		{
			return "[2, 2]";
		}
		if(appearance.lineStyle == LineStyle.UNSPECIFIED)
		{
			return "[0]";
		}
	}
	
	static def getFontStyle(Font font){
		if(font == null){
			return "normal";
		}
		if(font.isBold){
			return "bold";
		}
		if(font.isIsItalic){
			return "italic";
		}
	}
	
	static def createElementApperance(AbstractShape shape)
	'''
	«IF ModelParser.getShapeAppearnce(shape).background != null»
	fill: '#«Formatter.toHex(ModelParser.getShapeAppearnce(shape).background)»',
	«ELSE»
	fill: '#FFFFFF',
	«ENDIF»
	«IF ModelParser.getShapeAppearnce(shape).foreground != null»
	stroke: '#«Formatter.toHex(ModelParser.getShapeAppearnce(shape).foreground)»',
	«ELSE»
	stroke: '#000000',
	«ENDIF»
	«IF shape instanceof Text»
	'stroke-width': 1,
	«ELSE»
	'stroke-width': «ModelParser.getShapeAppearnce(shape).lineWidth»,
	«ENDIF»
	'opacity': «(1.0-ModelParser.getShapeAppearnce(shape).transparency)»,
	«IF ModelParser.getShapeAppearnce(shape).lineInVisible»
	'stroke-opacity': 0,
	«ENDIF»
	'stroke-dasharray': «getDashArray(ModelParser.getShapeAppearnce(shape))»,
	«IF ModelParser.getShapeAppearnce(shape).font != null »
	'font-family':'«ModelParser.getShapeAppearnce(shape).font.fontName»',
	'font-size' : '«ModelParser.getShapeAppearnce(shape).font.size»',
	«ENDIF»
	'font-weight' : '«getFontStyle(ModelParser.getShapeAppearnce(shape).font)»'
	'''
	
	static def createAbstractShapeAppearance(GraphicalModelElement gme,AbstractShape abstractShape,int i)
	'''
	«IF abstractShape instanceof Shape»
		«IF abstractShape instanceof Polyline»
		'polyline.po«i»': {
			
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			points: '«FOR Point p : (abstractShape as Polyline).points SEPARATOR ' '»«p.x» «p.y»«ENDFOR»'
			
		},
		«ELSEIF abstractShape instanceof Image»
		'image.im«i»': {
			width: «abstractShape.size.width»,
			height: «abstractShape.size.height»,
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			'xlink:href':getImgRootPath()+'«ModelParser.getFileName((abstractShape as style.Image).path)»'
		},
		«ELSE»
		'text.te«i»': {
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			'text-anchor': 'center'
			
		},
		«ENDIF»
	«ELSE»
		«IF abstractShape instanceof Polygon»
		'polygon.po«i»': {
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			points: '«FOR Point p : (abstractShape as Polygon).points SEPARATOR ' '»«p.x» «p.y»«ENDFOR»'
			
		},
		«ELSEIF abstractShape instanceof Ellipse»
		'ellipse.el«i»': {
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			rx: «abstractShape.size.width/2»,
			ry: «abstractShape.size.height/2»,
			
		},
		«ELSE»
		'rect.re«i»': {
			«IF abstractShape instanceof RoundedRectangle»
			rx:«(abstractShape as RoundedRectangle).cornerWidth»,
			ry:«(abstractShape as RoundedRectangle).cornerHeight»,
			«ENDIF»
			«createElementApperance(abstractShape)»,
			«createAbtractShapePosition(gme,abstractShape)»
			width: «abstractShape.size.width»,
			height: «abstractShape.size.height»
			
		},
		«ENDIF»
		«var counter = i»
		«FOR AbstractShape shape:(abstractShape as ContainerShape).children»
		«{counter = counter +1;""}»
		«createAbstractShapeAppearance(gme,shape,counter)»
		«ENDFOR»
    «ENDIF»
	'''
	
	static def createAbtractShapePosition(GraphicalModelElement gme,AbstractShape abstractShape)
	'''
	«IF abstractShape.position != null»
	«IF abstractShape.position instanceof AbsolutPosition»
	'x':«(abstractShape.position as AbsolutPosition).XPos»,
	'y':«(abstractShape.position as AbsolutPosition).YPos»,
	«ELSE»
	«IF (abstractShape.position as Alignment).horizontal == null»
	'x-alignment': 'middle',
	«ELSEIF (abstractShape.position as Alignment).horizontal == HAlignment.RIGHT»
	'x-alignment': 'right',
	«ELSEIF (abstractShape.position as Alignment).horizontal == HAlignment.LEFT»
	'x-alignment': 'left',
	«ELSE»
	'x-alignment': 'middle',
	«ENDIF»
	«IF (abstractShape.position as Alignment).vertical == null»
	'y-alignment': 'center',
	«ELSEIF (abstractShape.position as Alignment).vertical == VAlignment.TOP»
	'y-alignment': 'top',
	«ELSEIF (abstractShape.position as Alignment).vertical== VAlignment.BOTTOM»
	'y-alignment': 'bottom',
	«ELSE»
	'y-alignment': 'center',
	«ENDIF»
	«ENDIF»
	«ELSE»
	«ENDIF»
	'transform':'rotate(«ModelParser.getShapeAppearnce(abstractShape).angle») translate(0,0)',
	«IF ModelParser.isDisabledMove(gme)»
	'pointer-events': 'none',
	«ENDIF»
	'''
	public static def getMainShape(StyledModelElement sme){
		if(sme.style instanceof NodeStyle) {
			var nodeStyle = sme.style as NodeStyle;
			if(nodeStyle.mainShape instanceof Polygon || nodeStyle.mainShape instanceof Polyline) return "polygon";
			if(nodeStyle.mainShape instanceof Rectangle || nodeStyle.mainShape instanceof RoundedRectangle) return "rect";
			if(nodeStyle.mainShape instanceof Ellipse) return "ellipse";
			if(nodeStyle.mainShape instanceof Text || nodeStyle.mainShape instanceof MultiText) return "rect";
			if(nodeStyle.mainShape instanceof Image) return "rect";
		}
		return "";
	}
	
	static def createNodeShapePortBody(StyledModelElement sme)
	'''
	«IF getMainShape(sme).equals("ellipse")»
		cx: «(sme.style as NodeStyle).mainShape.size.width/4»,
		cy: «(sme.style as NodeStyle).mainShape.size.width/4»,
		rx: «(sme.style as NodeStyle).mainShape.size.width/2 + 20»,
		ry: «(sme.style as NodeStyle).mainShape.size.height/2 + 20»,
		'transform':'rotate(«ModelParser.getShapeAppearnce((sme.style as NodeStyle).mainShape).angle») translate(0,0)',
	«ELSEIF getMainShape(sme).equals("polygon")»
		'transform':'rotate(«ModelParser.getShapeAppearnce((sme.style as NodeStyle).mainShape).angle»)',
		x: 0,
		y: 0,
		points: '
		«IF (sme.style as NodeStyle).mainShape instanceof Polyline»
		«FOR Point p : ((sme.style as NodeStyle).mainShape as Polyline).points SEPARATOR ' '»
			«p.x*1.2»,«p.y*1.2»
		«ENDFOR»',
		«ELSE»
		«FOR Point p : ((sme.style as NodeStyle).mainShape as Polygon).points SEPARATOR ' '»
			«p.x*1.2»,«p.y*1.2»
		«ENDFOR»',
		«ENDIF»
	«ELSE»
		x: -10,
		y: -10,
		«IF (sme.style as NodeStyle).mainShape instanceof RoundedRectangle»
		rx:«((sme.style as NodeStyle).mainShape as RoundedRectangle).cornerWidth»,
		ry:«((sme.style as NodeStyle).mainShape as RoundedRectangle).cornerHeight»,
		«ENDIF»
		'transform':'rotate(«ModelParser.getShapeAppearnce((sme.style as NodeStyle).mainShape).angle»)',
		width: «(sme.style as NodeStyle).mainShape.size.width + 20»,
		height: «(sme.style as NodeStyle).mainShape.size.height + 20»,
	«ENDIF»
	'''
	
	static def createNodeModel(StyledModelElement sme,List<Type> enums)
	'''
/**
 * Model «sme.modelElement.name.toFirstUpper»
 * @type {void|*}
 */
joint.shapes.devs.Model«sme.modelElement.name.toFirstUpper» = joint.shapes.basic.Generic.extend(_.extend({}, joint.shapes.basic.PortsModelInterface, {

    type_name: 'devs.«sme.modelElement.name.toFirstUpper»',
    markup: '<g class="rotatable"><g class="scalable"><g class="inPorts"/><g class="outPorts"/>'+
    «createAbstractShape((sme.style as NodeStyle).mainShape,1)»
    '</g>'+
    '</g>',
    
    portMarkup: '<g class="port port<%= id %>"><«getMainShape(sme)» class="port-body"/><text class="port-label"/></g>',

    defaults: joint.util.deepSupplement({

        type: 'devs.«sme.modelElement.name.toFirstUpper»',
        cinco_id: '0',
        cinco_name: '«sme.modelElement.name.toFirstUpper»',
        cinco_feature: {
        	«IF ModelParser.isDisabledDelete(sme.modelElement)»
        	'delete':false,
        	«ELSE»
        	'delete':true,
        	«ENDIF»
        	«IF ModelParser.isDisabledCreate(sme.modelElement)»
        	'create':false,
        	«ELSE»
        	'create':true,
        	«ENDIF»
        	«IF ModelParser.isDisabledMove(sme.modelElement)»
        	'move':false
        	«ELSE»
        	'move':true
        	«ENDIF»
        	
    	},
        «IF sme.modelElement instanceof NodeContainer»
        cinco_type: 'Container',
        «ELSE»
        cinco_type: 'Node',
        «ENDIF»
	        «EditorModelTemplate.createAttributes(sme.modelElement,enums)»,
	        size: { 
	        	width: «(sme.style as NodeStyle).mainShape.size.width»,
	        	height: «(sme.style as NodeStyle).mainShape.size.height»
	        },

        inPorts: [''],
        outPorts: [],

        attrs: {
            '.scalable' :{
            },
            '.': { magnet: false },
            '.port-body': {
                «createNodeShapePortBody(sme)»
                magnet: false,
                fill: '#transparent',
                stroke: '#ffffff'
                
            },
            «createAbstractShapeAppearance(sme.modelElement,(sme.style as NodeStyle).mainShape,1)»
            '.label': { text: 'ModelRect', 'ref-x': .5, 'ref-y': 10, ref: '.body', 'text-anchor': 'middle' },
            '.inPorts .port-label': { x:0, dy: 0, 'text-anchor': 'end', fill: '#ffffff'},
            '.outPorts .port-label':{ x: 0, dy: 0, fill: '#ffffff' }
        }

    }, joint.shapes.basic.Generic.prototype.defaults),

    setLabel: function() {
		var attributes = this.attributes.cinco_attrs;
			«FOR Map.Entry<Text,Integer> text:ModelParser.getTextShapes((sme.style as NodeStyle).mainShape,1).entrySet»
			this.attr('text.te«text.value»',{
	        	text: '«Formatter.getLabelText(text.key,ModelParser.getStyleAnnotationValues(sme.modelElement))»',
	        	«createElementApperance(text.key)»,
	        	«createAbtractShapePosition(sme.modelElement,text.key)»
				'text-anchor': 'center'
				
	        });
	        «ENDFOR»
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

joint.shapes.devs.«sme.modelElement.name.toFirstUpper» = joint.shapes.devs.Model«sme.modelElement.name.toFirstUpper».extend({
	    defaults: joint.util.deepSupplement({}, joint.shapes.devs.Model«sme.modelElement.name.toFirstUpper».prototype.defaults)
	});
	'''
}