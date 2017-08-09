package de.jabc.cinco.meta.plugin.pyro.canvas

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import java.math.BigDecimal
import java.math.RoundingMode
import java.util.HashMap
import java.util.LinkedHashMap
import java.util.LinkedList
import java.util.List
import java.util.Map
import java.util.regex.Matcher
import java.util.regex.Pattern
import mgl.Edge
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.Node
import org.eclipse.emf.ecore.EObject
import style.AbsolutPosition
import style.AbstractPosition
import style.AbstractShape
import style.Alignment
import style.BooleanEnum
import style.Color
import style.ConnectionDecorator
import style.ContainerShape
import style.DecoratorShapes
import style.EdgeStyle
import style.Ellipse
import style.Font
import style.GraphicsAlgorithm
import style.HAlignment
import style.Image
import style.LineStyle
import style.MultiText
import style.NodeStyle
import style.Polygon
import style.Polyline
import style.PredefinedDecorator
import style.Rectangle
import style.RoundedRectangle
import style.Shape
import style.Size
import style.Styles
import style.Text
import style.VAlignment
import org.eclipse.xtext.debug.IStratumBreakpointSupport.DefaultImpl
import java.util.TreeMap

class Shapes extends Generatable {
	
	final GraphModel g
	
	new(GeneratorCompound gc,GraphModel g) {
		super(gc)
		this.g = g
	}
	
	def fileNameShapes(GraphModel g)'''«g.name.lowEscapeDart»_shapes.js'''
	
	
	def createNode(Node node,GraphModel g,Styles styles)
	{
		val styleForNode = node.styling(styles) as NodeStyle
		val markups = styleForNode.mainShape.collectMarkupTags("x",0).entrySet
		val markupCSS = styleForNode.mainShape.collectMarkupCSSTags("x",0,null).entrySet
		val noneTextual = new LinkedList
		for(it:markups){
			if(!key.isTextual){
				noneTextual.add(it)
			}
		}
		//val noneTextual = markups.filter[!key.isTextual].toList
		val textual = markups.filter[key.isTextual].toList
		'''
		joint.shapes.«g.name.lowEscapeDart».«node.name.fuEscapeDart» = joint.shapes.basic.Generic.extend({
			
			    markup: '<g class="rotatable"><g class="scalable">«noneTextual.map[value].join»</g>«textual.map[value].join»</g>',
			    defaults: _.defaultsDeep({
			
			        type: '«g.name.lowEscapeDart».«node.name.fuEscapeDart»',
			        size: {
			            width: «styleForNode.mainShape.size.width»,
			            height: «styleForNode.mainShape.size.height»
			        },
			        attrs: {
			            '.': {
			                magnet: 'passive'
			            },
			            «markupCSS.map[value].join(",\n")»
			        }
			    }, joint.shapes.basic.Generic.prototype.defaults)
			});
		'''
	}
	
	
	def String markupChildren(ContainerShape a,String s){
		var result = ""
		for(var i=0;i<a.children.length;i++){
			result += a.children.get(i).markup(s+"x",i)
		}
		result
	}
	
	def String markupCSSChildren(ContainerShape a,String s,String ref){
		var result = ""
		for(var i=0;i<a.children.length;i++){
			result += a.children.get(i).markupCSS(s+"x",i,ref)
		}
		result
	}
	
	
	def tagClass(String s,int i)'''pyro«s»«i»tag'''
	
	
	def Map<AbstractShape,CharSequence> collectMarkupTags(AbstractShape shape,String prefix,int i){
		val l = new LinkedHashMap
		l.put(shape,shape.markup(prefix,i))
		if(shape instanceof ContainerShape) {
			shape.children.forEach[n,idx|l.putAll(n.collectMarkupTags(i+"x",idx))]			
		}
		return l
	}
	
	def Map<AbstractShape,CharSequence> collectSelectorTags(AbstractShape shape,String prefix,int i){
		val l = new LinkedHashMap
		l.put(shape,shape.selector(prefix,i))
		if(shape instanceof ContainerShape) {
			shape.children.forEach[n,idx|l.putAll(n.collectSelectorTags(i+"x",idx))]			
		}
		return l
	}
	
	def Map<EObject,CharSequence> collectMarkupTags(GraphicsAlgorithm shape,String prefix,int i){
		val l = new LinkedHashMap
		l.put(shape,shape.markup(prefix,i))
		if(shape instanceof ContainerShape) {
			shape.children.forEach[n,idx|l.putAll(n.collectMarkupTags(i+"x",idx))]			
		}
		return l
	}
	
	
	def Map<AbstractShape,CharSequence> collectMarkupCSSTags(AbstractShape shape,String prefix,int i,String ref){
		val l = new LinkedHashMap
		l.put(shape,shape.markupCSS(prefix,i,ref))
		if(shape instanceof ContainerShape) {
			shape.children.forEach[n,idx|l.putAll(n.collectMarkupCSSTags(i+"x",idx,'''«prefix.tagClass(i)»'''))]			
		}
		return l
	}
	
	def Map<EObject,CharSequence> collectMarkupCSSTags(GraphicsAlgorithm shape,String prefix,int i,String ref){
		val l = new LinkedHashMap
		l.put(shape,shape.markupCSS(prefix,i,ref))
		if(shape instanceof ContainerShape) {
			shape.children.forEach[n,idx|l.putAll(n.collectMarkupCSSTags(i+"x",idx,ref))]			
		}
		return l
	}
	
	def dispatch markup(Rectangle shape,String s,int i)
	'''<rect class="«s.tagClass(i)»" />'''
	
	def dispatch markup(Text shape,String s,int i)
	'''<text class="«s.tagClass(i)»"/>'''
	
	
	def dispatch markup(MultiText shape,String s,int i)
	'''<text class="«s.tagClass(i)»"/>'''
	
	def dispatch markup(Ellipse shape,String s,int i)
	'''<ellipse class="«s.tagClass(i)»" />'''
	
	def dispatch markup(Polyline shape,String s,int i)
	'''<polyline class="«s.tagClass(i)»"/>'''
	
	def dispatch markup(Polygon shape,String s,int i)
	'''<polygon class="«s.tagClass(i)»"/>'''
	
	def dispatch markup(Image shape,String s,int i)
	'''<image class="«s.tagClass(i)»"/>'''
	
	def dispatch markup(RoundedRectangle shape,String s,int i)
	'''<rect class="«s.tagClass(i)»" />'''
	
	
	def dispatch selector(Rectangle shape,String s,int i)
	'''rect.«s.tagClass(i)»'''
	
	def dispatch selector(Text shape,String s,int i)
	'''text.«s.tagClass(i)»'''
	
	def dispatch selector(MultiText shape,String s,int i)
	'''text.«s.tagClass(i)»'''
	
	def dispatch selector(Ellipse shape,String s,int i)
	'''ellipse.«s.tagClass(i)»'''
	
	def dispatch selector(Polyline shape,String s,int i)
	'''polyline.«s.tagClass(i)»'''
	
	def dispatch selector(Polygon shape,String s,int i)
	'''polygon.«s.tagClass(i)»'''
	
	def dispatch selector(Image shape,String s,int i)
	'''image.«s.tagClass(i)»'''
	
	def dispatch selector(RoundedRectangle shape,String s,int i)
	'''rect.«s.tagClass(i)»'''
	
	
	def dispatch markupCSS(Rectangle shape,String s,int i,String ref)
	'''
	'rect.«s.tagClass(i)»':{
		«ref.ref»
		«shape.shapeCSS»
	}
	'''
	def dispatch markupCSS(RoundedRectangle shape,String s,int i,String ref)
	'''
	'rect.«s.tagClass(i)»':{
		«ref.ref»
		rx:«shape.cornerWidth»,
		ry:«shape.cornerHeight»,
		«shape.shapeCSS»
	}
	'''
	
	def getRef(String string) {
		if(string.nullOrEmpty){
			return ""
		}
		'''
		'ref':'.«string»',
		'''
	}
	
	def dispatch markupCSS(Text shape,String s,int i,String ref)
	'''
	'text.«s.tagClass(i)»':{
		«ref.ref»
		'text':'',
		«shape.shapeCSS»
	}
	'''
	
	def dispatch markupCSS(MultiText shape,String s,int i,String ref)
	'''
	'text.«s.tagClass(i)»':{
		«ref.ref»
		'text':'',
		«shape.shapeCSS»
	}
	'''
	
	def dispatch markupCSS(Ellipse shape,String s,int i,String ref)
	'''
	'ellipse.«s.tagClass(i)»':{
		«ref.ref»
		rx:«shape.size.width/2»,
		ry:«shape.size.height/2»,
		«shape.shapeCSS»
	}
	'''
	
	def dispatch markupCSS(Polyline shape,String s,int i,String ref)
	'''
	'polyline.«s.tagClass(i)»':{
		«ref.ref»
		points: '«FOR p:shape.points SEPARATOR " "»«p.x»,«p.y»«ENDFOR»',
		«shape.shapeCSS»
	}
	'''
	
	def dispatch markupCSS(Polygon shape,String s,int i,String ref)
	'''
	'polygon.«s.tagClass(i)»':{
		«ref.ref»
		points: '«FOR p:shape.points SEPARATOR " "»«p.x»,«p.y»«ENDFOR»',
		«shape.shapeCSS»
	}
	«shape.markupCSSChildren(s,'''polygon.«s.tagClass(i)»''')»
	'''
	
	def dispatch markupCSS(Image shape,String s,int i,String ref)
	'''
	'image.«s.tagClass(i)»':{
		«ref.ref»
		'xlink:href':'asset/img/«g.name.lowEscapeDart»/«shape.path»',
		«shape.shapeCSS»
	}
	'''
	
	def shapeCSS(AbstractShape shape)
	'''
	«IF shape.size!=null»
	«shape.size.size»,
	«ENDIF»
	«shape.appearance»
	«shape.position.position(shape)»
	'''
	
	def double round(double value, int places) {
	    if (places < 0) throw new IllegalArgumentException();
	
	    var bd = new BigDecimal(value);
	    bd = bd.setScale(places, RoundingMode.HALF_UP);
	    return bd.doubleValue();
	}
	
	def getVerticalRef(Alignment ap,AbstractShape ash) {
		var res = switch(ap.vertical){
			case MIDDLE: 0.5
			case BOTTOM: 1
			case TOP: 0
			case UNDEFINED:0
		}
		if(ap.YMargin!=0&&ash.size!=null){
			res += round(100/ash.size.height*ap.YMargin,2)
		}
		return res
	}
	
	def getHorizontalRef(Alignment ap,AbstractShape ash) {
		var res = switch(ap.horizontal){
			case CENTER: 0.5
			case RIGHT: 1
			case LEFT: 0
			default: 0
		}
		if(ap.XMargin!=0&&ash.size!=null){
			res += round(100/ash.size.height*ap.XMargin,2)
		}
		return res
	}

	
	def appearance(AbstractShape shape){
		if(shape.referencedAppearance!=null){
			return new PyroAppearance(shape.referencedAppearance).appearanceCSS(shape)+","
		}
		if(shape.inlineAppearance!=null){
			return new PyroAppearance(shape.inlineAppearance).appearanceCSS(shape)+","
		}
		return new PyroAppearance().appearanceCSS(shape)+","
	}
	
	def appearance(EdgeStyle es){
		if(es.referencedAppearance!=null){
			return new PyroAppearance(es.referencedAppearance).appearanceCSS(null)
		}
		if(es.inlineAppearance!=null){
			return new PyroAppearance(es.inlineAppearance).appearanceCSS(null)
		}
	}
	
	def appearance(PredefinedDecorator pd){
		if(pd.referencedAppearance!=null){
			return new PyroAppearance(pd.referencedAppearance).appearanceCSS(null)
		}
		if(pd.inlineAppearance!=null){
			return new PyroAppearance(pd.inlineAppearance).appearanceCSS(null)
		}
	}
	
	def appearanceCSS(PyroAppearance app,AbstractShape shape){
		'''
		«IF app.angle!=0»transform: 'rotate(«app.angle»)',«ENDIF»
		«IF app.background!=null && (app.filled==BooleanEnum.TRUE ||app.filled==BooleanEnum.UNDEF)»
			fill: «IF shape.isTextual»«app.foreground.color»«ELSE»«app.background.color»«ENDIF»,
		«ENDIF»
		stroke: «IF app.foreground==null || shape.isTextual»'none'«ELSE»«app.foreground.color»«ENDIF»,
		«IF app.lineInVisible»'stroke-opacity':0.0,«ENDIF»
		«IF app.font!=null»«app.font.font»,«ENDIF»
		«IF app.lineStyle!=LineStyle.UNSPECIFIED&&app.lineStyle!=LineStyle.SOLID»«app.lineStyle.lineStyle»,«ENDIF»
		«IF app.transparency>0»
			'fill-opacity':«1.0-app.transparency»,
			«IF !app.lineInVisible»'stroke-opacity':«1.0-app.transparency»,«ENDIF»
		«ENDIF»
		'stroke-width':«IF shape.isTextual»1«ELSE»«app.lineWidth»«ENDIF»
		'''
	}
	
	def boolean getIsTextual(AbstractShape shape){
		if(shape==null){
			return false
		}
		shape instanceof Text || shape instanceof MultiText
	}
	
	def lineStyle(LineStyle ls){
		if(ls==LineStyle.SOLID)return ""
		val r = switch(ls){
			case DASH: "10, 5"
			case DASHDOT:"5, 5, 1, 5"
			case DOT:"1, 5"
			case DASHDOTDOT: "5, 5, 1, 5, 1, 5"
			default: ""
		}
		'''
		'stroke-dasharray':'«r»'
		'''
	}
	
	def font(Font f)
	'''
	'font-family':'«f.fontName»',
	'font-size':'«f.size»px',
	'font-weight':'«IF f.isIsBold»bold«ELSE»normal«ENDIF»',
	'font-style':'«IF f.isIsItalic»italic«ELSE»normal«ENDIF»'
	'''
	
	def color(Color color)
	'''
	'rgb(«color.r»,«color.g»,«color.b»)'
	'''
	
	def size(Size size)
	'''
	width: «size.width»,
	height: «size.height»
	'''
	
	def position(AbstractPosition pos,AbstractShape shape)
	'''
	«IF pos instanceof Alignment»
	'ref-y': «pos.getVerticalRef(shape)»,
	«pos.horizontal.anchor»
	«pos.vertical.anchor(shape)»
	'ref-x': «pos.getVerticalRef(shape)»
	«ENDIF»
	«IF pos instanceof AbsolutPosition»
	'x':«pos.XPos»,
	'y':«pos.YPos»
	«ENDIF»
	'''
	
	def anchor(HAlignment position) {
		if(position==HAlignment.UNDEFINED)return ""
		var r = switch(position) {
			case CENTER: "middle"
			case LEFT: "left"
			case RIGHT: "right"
			default: "none"
		}
		'''
		'text-anchor': '«r»',
		'x-alignment': '«r»',
		'''
	}
	
	def anchor(VAlignment position,AbstractShape shape){
		if(position==VAlignment.UNDEFINED)return ""
		val r = switch(position){
			case TOP: "0em"
			case MIDDLE: "-0.5em"
			case BOTTOM: "-1em"
			default: "0em"
		}
		var a = switch(position) {
			case MIDDLE: "middle"
			case BOTTOM: "bottom"
			case TOP: "top"
			default: "none"
		}
		'''
		«IF !(shape instanceof Text || shape instanceof MultiText)»
		dy:'«r»',
		«ELSE»
		'y-alignment': '«a»',
		«ENDIF»
		'''
		
	}
	
	
	
	def getMarkup(List<AbstractShape> shapes,String prefix){
		var res = ""
		for(var i = 0;i<shapes.length;i++){
			res += shapes.get(i).markup(prefix,i)
		}
	}
	
	def getMarkup(ConnectionDecorator cd){
		cd.decoratorShape.markup("",0)
	}
	
	def dispatch getMarkupCSS(NodeStyle style){
		style.mainShape.markupCSS("",0,"")
	}
	
	def dispatch getMarkupCSS(ConnectionDecorator style){
		style.decoratorShape.markupCSS("",0,"")
	}
	
	
	
	
	def styling(Node node, Styles styles){
		styles.styles.findFirst[name.equals(node.styleAnnotation(styles).value.get(0))]
	}
	
	def styling(Edge edge, Styles styles){
		styles.styles.findFirst[name.equals(edge.styleAnnotation(styles).value.get(0))]
	}
	
	def styleAnnotation(GraphicalModelElement gme, Styles styles){
		gme.annotations.findFirst[name.equals("style")]
	}
	
	def createEdge(Edge e,Styles styles){
		val styleForEdge = e.styling(styles) as EdgeStyle
		'''
		joint.shapes.«g.name.lowEscapeDart».«e.name.fuEscapeDart» = joint.dia.Link.extend({
				markup: '<path class="connection"/>'+
				'<path class="marker-source"/>'+
				'<path class="marker-target"/>'+
				'<path class="connection-wrap"/>'+
				'<g class="labels"></g>'+
				'<g class="marker-vertices"/>'+
				'<g class="marker-arrowheads"/>'+
				'<g class="link-tools" />',
			    defaults: {
			        type: '«g.name.lowEscapeDart».«e.name.fuEscapeDart»',
			        attrs: {
			            '.connection': {
			                «styleForEdge.appearance»
			            },
			            '.marker-target': { 
			            	«IF styleForEdge.targetMarker!=null»
			            	«styleForEdge.targetMarker.markerCSS»
			            	«ELSE»
			            	fill: '#000', stroke: '#000'
			            	«ENDIF»
			            },
			            '.marker-source': { 
			            	«IF styleForEdge.sourceMarker!=null»
			            	«styleForEdge.sourceMarker.markerCSS»
			            	«ELSE»
			            	fill: '#000', stroke: '#000'
			            	«ENDIF»
			            }
			        },
			        labels:[
			        	«styleForEdge.decorator.decoratorCSS»
			        ]
			    }
			});
		'''
	}
	
	def getTargetMarker(EdgeStyle style){
		style.decorator.findFirst[n|n.location==1.0]
	}
	
	def getSourceMarker(EdgeStyle style){
		style.decorator.findFirst[n|n.location==0.0]
	}
	
	def decoratorMarkups(List<ConnectionDecorator> cds){
		var result = ""
		for(var i = 0;i<cds.length;i++){
			result += cds.get(i).decoratorMarkup("x",i)+"\n"
		}
		result
	}
	
	def decoratorCSS(List<ConnectionDecorator> cds)
	'''
	«FOR cd:cds.filter[n|n.decoratorShape instanceof Text ||n.decoratorShape instanceof MultiText].indexed SEPARATOR ","»
	{
		position: «cd.value.location»,
		markup:'<text class="pyro«cd.key»link"/>',
	    attrs: {
			'text.pyro«cd.key»link': {
				«{
					val shape = cd.value.decoratorShape as Shape
					'''
					text:'«shape.getText»',
					«shape.shapeCSS»
					'''
				}»
			}
	     }
	}
	«ENDFOR»
	'''
	
	def String getText(Shape shape){
		if(shape instanceof Text){
			return shape.value
		}
		if(shape instanceof MultiText){
			return shape.value
		}
		return ""
	}
	
//	def decoratorMarkupsCSS(List<ConnectionDecorator> cds){
//		var result = ""
//		for(var i = 0;i<cds.length;i++){
//			result += cds.get(i).decoratorCSS("x",i)+"\n"
//		}
//		result
//	}
	
	def decoratorMarkup(ConnectionDecorator cd,String s,int i)
	'''
	<g class="label positional-«s»«i»">
	«IF cd.predefinedDecorator!=null»
	<path class="predefined-«s»«i»"/>
	«ELSE»
	«cd.decoratorShape.collectMarkupTags(s,i).entrySet.map[value].join»
	«ENDIF»
	</g>
	'''
		
		
	def markerCSS(ConnectionDecorator cd)
	'''
	«IF cd.predefinedDecorator!=null»
		d: '«cd.predefinedDecorator.shape.polyline»',
		«cd.predefinedDecorator.appearance»,
		markerWidth:4,
		markerHeight:4
	«ENDIF»
	'''
	
//	def decoratorCSS(ConnectionDecorator cd,String s,int i)
//	'''
//	'.positional-«s»«i»':{
//		position: «cd.location»
//	},
//	«IF cd.predefinedDecorator!=null»
//	'.predefined-«s»«i»' : {
//		d: '«cd.predefinedDecorator.shape.polyline»',
//		«cd.predefinedDecorator.appearance»,
//		markerWidth:4,
//		markerHeight:4,
//	},
//	«ELSE»
//	«cd.decoratorShape.collectMarkupCSSTags(s,i,'''positional-«s»«i»''').entrySet.map[value].join(",")»
//	«ENDIF»
//
//	'''
	
	
	def polyline(DecoratorShapes ds){
		switch(ds){
			case ARROW:return "M 0,0 L 5,-5 M 0,0 L 5,5"
			case CIRCLE:return "M 100, 100 m -75, 0 a 75,75 0 1,0 150,0 a 75,75 0 1,0 -150,0"
			case DIAMOND:return "M 50 0 100 100 50 200 0 100 Z"
			case TRIANGLE:return "M 26 0 L 0 13 L 26 26 z"
		}
	}
	
	
	def contentShapes(Styles styles)
	'''
	joint.shapes.«g.name.lowEscapeDart» = {};
	
	«g.nodes.map[createNode(g,styles)].join("\n")»
	
	«g.edges.map[createEdge(styles)].join("\n")»
	
	'''
	
	
	
	
	
}