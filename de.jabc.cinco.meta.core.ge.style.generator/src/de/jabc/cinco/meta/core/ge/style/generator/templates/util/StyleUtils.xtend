package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoLayoutFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import java.util.LinkedList
import mgl.Edge
import mgl.Node
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.mm.algorithms.styles.Style
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.Shape
import style.AbsolutPosition
import style.AbstractShape
import style.Alignment
import style.Appearance
import style.BooleanEnum
import style.ContainerShape
import style.Ellipse
import style.Image
import style.LineStyle
import style.MultiText
import style.NodeStyle
import style.Point
import style.Polygon
import style.Polyline
import style.Rectangle
import style.RoundedRectangle
import style.StyleFactory
import style.Text

class StyleUtils extends GeneratorUtils {

	private static var num = 0;
	private static Node node;

	def getAlgorithmCode(AbstractShape aShape, String containerShapeName, Node n) {
		node = n;
		'''
				«var currentPeName = getShapeName(aShape)»
				«var currentGaName = getGAName(aShape)»
				«polygonVarDeclaration()»				
				
				«aShape.creator(currentPeName.toString, containerShapeName)»
				
				«aShape.getCode(currentGaName, currentPeName)» 
				
				«aShape.setSize(currentGaName)»
				
				«aShape.appearanceCode(currentGaName)»

				«aShape.setPosition(currentGaName)»
				
				«aShape.recursiveCall(currentPeName.toString)»
			
				linkAllShapes(«currentPeName», bo);
				layoutPictogramElement(«currentPeName»);
			
			if (context.getWidth() != -1 && context.getHeight() != -1)  {
			
				«ResizeShapeContext.name» rc = new «ResizeShapeContext.name»(«currentPeName»);
				rc.setWidth(context.getWidth());
				rc.setHeight(context.getHeight());
				rc.setX(context.getX());
				rc.setY(context.getY());
				«CincoAbstractResizeFeature.name» rf = 
					(«CincoAbstractResizeFeature.name»)getFeatureProvider().getResizeShapeFeature(rc);
				rf.activateApiCall(!hook);
			
				if (rf != null && rf.canResizeShape(rc))
				rf.resizeShape(rc);
			} else if (parentIsDiagram)  {
				«ResizeShapeContext.name» rc = new «ResizeShapeContext.name»(«currentPeName»);
				rc.setWidth(width);
				rc.setHeight(height);
				rc.setX(context.getX() + minX);
				rc.setY(context.getY() + minY);
				«CincoAbstractResizeFeature.name» rf = 
					(«CincoAbstractResizeFeature.name») getFeatureProvider().getResizeShapeFeature(rc);
				rf.activateApiCall(!hook);
			
				if (rf != null && rf.canResizeShape(rc))
				rf.resizeShape(rc);
			}
			
			peService.createChopboxAnchor(«currentPeName»);
			layoutPictogramElement(«currentPeName»);

			if (hook) {
			}

			
			return «currentPeName»;
		'''
	}

	
	def CharSequence getCode(AbstractShape absShape, String containerShapeName) '''
		«var currentPeName = getShapeName(absShape)»
		«var currentGaName = getGAName(absShape)»
		«absShape.creator(currentPeName.toString, containerShapeName)»
		«absShape.getCode(currentGaName, currentPeName)» 
		«absShape.setSize(currentGaName)»
		
		«absShape.setPosition(currentGaName)»
		«absShape.appearanceCode(currentGaName)»

		«absShape.recursiveCall(currentPeName.toString)»
	'''

	def appearanceCode(AbstractShape shape, CharSequence currentGaName) {
		if (shape.referencedAppearance != null) '''«node.packageName».«node.graphModel.name»LayoutUtils.set«shape.referencedAppearance.name»Style(«currentGaName», getDiagram());'''
		else if (shape.inlineAppearance != null)  ''' «node.packageName».«node.graphModel.name»LayoutUtils.«LayoutFeatureTmpl.shapeMap.get(shape)»(«currentGaName», getDiagram());'''
		else '''«node.graphModel.packageName».«node.graphModel.name»LayoutUtils.set_«node.graphModel.name»DefaultAppearanceStyle(«currentGaName», getDiagram());'''
	}

	/**
	 * This method writes the {@link org.eclipse.graphiti.mm.pictograms.ContainerShape} initialization code.
	 *	
	 * @param cs The {@link ContainerShape} for which the Graphiti code should be generated
	 * @param peName The ContainerShape's name
	 * @param containerName The parent's name
	 */
	def dispatch creator(ContainerShape cs, String peName, String containerName) '''
		«org.eclipse.graphiti.mm.pictograms.ContainerShape.name» «peName» = peService.createContainerShape(«containerName», «containerIsDiagramOrMovable(
			cs as AbstractShape)»);
	'''
	
	/**
	 * This method writes the {@link Shape} initialization code.
	 * 
	 * @param s The {@link style.Shape} for which the Graphiti code should be generated
	 * @param peName The ContainerShape's name
	 * @param containerName The parent's name
	 */
	def dispatch creator(style.Shape s, String peName, String containerName) '''
		«Shape.name» «peName» = peService.createShape(«containerName», «containerIsDiagramOrMovable(s as AbstractShape)»);
	'''

	def dispatch getCode(Ellipse e, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.Ellipse.name» «currentGaName» = gaService.createPlainEllipse(«currentPeName»);
	'''

	def dispatch getCode(Rectangle r, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.Rectangle.name» «currentGaName» = gaService.createPlainRectangle(«currentPeName»);
	'''

	def dispatch getCode(RoundedRectangle rr, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.RoundedRectangle.name» «currentGaName» = gaService.createPlainRoundedRectangle(«currentPeName», «rr.
			cornerWidth», «rr.cornerHeight»);
	'''

	def dispatch getCode(Polygon p, CharSequence currentGaName, CharSequence currentPeName)'''
		points = new «int»[] {«printPoints(p)»};
				
		xs = new «int»[] {«printX(p)»};
		ys = new «int»[] {«printY(p)»};
		
		minX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(xs);
		maxX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(xs);
		
		minY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(ys);
		maxY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(ys);
		
		
		«node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().transform(points, -minX, -minY);
		width = maxX - minX;
		height = maxY - minY;	
		
		parentIsDiagram = false;
			
		«org.eclipse.graphiti.mm.algorithms.Polygon.name» «currentGaName» = gaService.createPolygon(«currentPeName», points);
		
		
		«node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().transform(points, -minX, -minY);
		
		gaService.setSize(«currentGaName», width, height);
		
		pointsString = "";
		for (int i : points) {
			pointsString += String.valueOf(i)+",";
		}
		peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_POINTS, pointsString);
		
		if(!(«currentPeName».getContainer() instanceof «Diagram.name»))
			peService.setPropertyValue(«currentGaName»,«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getContainer().getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getContainer().getGraphicsAlgorithm().getHeight());
		else peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getGraphicsAlgorithm().getHeight()); 
		
			«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.set_FlowGraphDefaultAppearanceStyle(«currentGaName», getDiagram());
			gaService.setLocation(«currentGaName», 0, 0);
			peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_HORIZONTAL, «node.
			graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_HORIZONTAL_UNDEFINED);
			peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_VERTICAL, «node.
			graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_VERTICAL_UNDEFINED);
		
	'''

	def polygonVarDeclaration() '''
		boolean parentIsDiagram = false;
		int width = 0;
		int height = 0;
		int minX = 0;
		int minY = 0; 
		int maxX = 0;
		int maxY = 0;
		int[] points;  
		int[]xs;
		int[] ys;
		String pointsString = "";
	'''

	def dispatch getCode(Polyline p, CharSequence currentGaName, CharSequence currentPeName) '''
«««	ToDO: Polyline
		points = new «int»[] {«printPoints(p)»};
				
		xs = new «int»[] {«printX(p)»};
		ys = new «int»[] {«printY(p)»};
		
		minX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(xs);
		maxX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(xs);
		
		minY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(ys);
		maxY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(ys);
		
		
		width = maxX - minX;
		height = maxY - minY;	
		
		«org.eclipse.graphiti.mm.algorithms.Polyline.name» «currentGaName» = gaService.createPlainPolyline(«currentPeName»);
		
			parentIsDiagram = («currentPeName».getContainer() instanceof «Diagram.name»);
		
		if (parentIsDiagram || minX < 0 || minY < 0)
			«node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().transform(points, -minX, -minY);
		
		pointsString = "";
		for (int i : points) {
			pointsString += String.valueOf(i)+",";
		}
		
		if (!parentIsDiagram) {
			«currentGaName» = gaService.createPolyline(«currentPeName», points);
			peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getContainer().getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getContainer().getGraphicsAlgorithm().getHeight()); 
		} else {
			«currentGaName» = gaService.createPolyline(«currentPeName», new int[] {0,0,10,10,20,0,});
			peService.setPropertyValue(«currentGaName»,«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_PARENT_SIZE, "" + width + "," + height); 
		}
		
		peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_POINTS, pointsString);
		«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.set_FlowGraphDefaultAppearanceStyle(«currentGaName», getDiagram());
		gaService.setLocation(«currentGaName», 0, 0);
		peService.setPropertyValue(«currentGaName»,«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_HORIZONTAL, «node.
			graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_HORIZONTAL_UNDEFINED);
		peService.setPropertyValue(«currentGaName», «node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_VERTICAL, «node.
			graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_VERTICAL_UNDEFINED);
		
		
	'''

	def dispatch getCode(Text t, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.Text.name» «currentGaName» = gaService.createPlainText(«currentPeName»);
		
		«««Hier muss der Code generiert werden, der den anzuzeigenden Wert aus der zugehörigen @style annotation ausliest
		«ExpressionFactoryImpl.name» factory = new com.sun.el.ExpressionFactoryImpl();
		«LinkedList.name» <«Shape.name»>linkingList = new «LinkedList.name» <«Shape.name»>();
		linkingList.add(«currentPeName.toString»);
		«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
		try {
			«currentGaName.toString».setFilled(false);
			«Thread.name».currentThread().setContextClassLoader(AddFeature«node.name».class.getClassLoader());
		
			«node.graphModel.packageNameExpression».«node.graphModel.fuName»ExpressionLanguageContext elContext = new «node.
			graphModel.packageNameExpression».«node.graphModel.fuName»ExpressionLanguageContext(bo);
			«Object.name» tmp0Value = factory.createValueExpression(elContext, "«getText(node)»", «Object.name».class).getValue(elContext);
		
			peService.setPropertyValue(«currentGaName.toString», «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, "«t.value»");

			peService.setPropertyValue(«currentGaName.toString», "Params","«getText(node)»");
			«currentGaName.toString».setValue(String.format("«t.value»", tmp0Value));
		} catch (java.util.IllegalFormatException ife) {
			«currentGaName.toString».setValue("STRING FORMAT ERROR");
		} finally {
			«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
		}
		
	'''

	def dispatch getCode(MultiText p, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.MultiText.name» «currentGaName» = gaService.createPlainMultiText(«currentPeName»);
	'''

	def dispatch getCode(Image p, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.Image.name» «currentGaName» = gaService.createPlainImage(«currentPeName», "«p.path»");
	'''

	def static setSize(AbstractShape a, CharSequence gaName) '''
		if (context.getWidth() > 0 && context.getHeight() > 0)
			gaService.setSize(«gaName»,context.getWidth(),context.getHeight());
		else gaService.setSize(«gaName», «a.size?.width», «a.size?.height»);
		«IF a.size?.widthFixed»
			peService.setPropertyValue(«gaName», "«CincoResizeFeature.FIXED_WIDTH»", "«CincoResizeFeature.FIXED»");
		«ENDIF»
		«IF a.size?.heightFixed»
			peService.setPropertyValue(«gaName», "«CincoResizeFeature.FIXED_HEIGHT»", "«CincoResizeFeature.FIXED»");
		«ENDIF»
	'''

	def static setPosition(AbstractShape aShape, CharSequence gaName) '''
		«IF aShape.eContainer instanceof NodeStyle»
			«var a = aShape.position as AbsolutPosition»
			if (context.getWidth() < 0 && context.getHeight() < 0) 
				gaService.setLocation(«gaName», context.getX() + «a?.XPos», context.getY() + «a?.YPos»);
			else gaService.setLocation(«gaName», context.getX(), context.getY());
		«ELSE»
			«var a = aShape.position»
			«IF a instanceof AbsolutPosition»
				gaService.setLocation(«gaName», «a?.XPos», «a?.YPos»);
			«ELSEIF a instanceof Alignment»
				«var Alignment alignment = a as Alignment»
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_HORIZONTAL»", "«alignment.getHorizontalValue»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_VERTICAL»", "«alignment.getVerticalValue»");
				
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_MARGIN_HORIZONTAL»", "«alignment?.XMargin»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_MARGIN_VERTICAL»", "«alignment?.YMargin»");
			«ELSEIF a == null»
				gaService.setLocation(«gaName», 0, 0);
			«ENDIF»
		«ENDIF»
	'''

	def static setAppearanceCode(AbstractShape abs, Appearance app, CharSequence gaName) '''
		{
			«Style.name» s = gaService.createPlainStyle(getDiagram(), "«if(app.name.isNullOrEmpty) "tmpStyle" else app.name»");
			«IF app.background != null»
				s.setBackground(gaService.manageColor(getDiagram(), «app.background.r», «app.background.g», «app.background.b»));
			«ENDIF»
			«IF app.foreground != null»
				s.setForeground(gaService.manageColor(getDiagram(), «app.foreground.r», «app.foreground.g», «app.foreground.b»));
			«ENDIF»
			«IF app.font != null»
				s.setFont(gaService.manageFont(getDiagram(), «app.font.fontName», «app.font.size», «app.font.isIsItalic», «app.font.
			isIsBold»));
			«ENDIF»
			«IF !app.lineStyle.equals(LineStyle.UNSPECIFIED)»
				s.setLineStyle(«org.eclipse.graphiti.mm.algorithms.styles.LineStyle.name».«app.lineStyle»);
			«ENDIF»
			«IF app.angle != -1.0»
				s.setRotation(«app.angle»);
			«ENDIF»
			«IF !app.filled.equals(BooleanEnum.UNDEF)»
				s.setFilled(«app.filled»);
			«ENDIF»
			s.setLineVisible(«!app.lineInVisible»);
			s.setLineWidth(«app.lineWidth»);
			s.setTransparency(«app.transparency»);
			«gaName».setStyle(s);
		}
	'''

	def static setAppearance(AbstractShape aShape, CharSequence gaName) {
		var app = if(aShape.referencedAppearance == null) aShape.inlineAppearance else aShape.referencedAppearance
		var Appearance newApp = StyleFactory.eINSTANCE.createAppearance
		app.resolveParents(newApp)
		return setAppearanceCode(aShape, newApp, gaName)
	}

	def static void resolveParents(Appearance app, Appearance newApp) {
		if (app == null)
			return
		else
			app.parent.resolveParents(newApp)
		if (app.angle != -1.0)
			newApp.angle = app.angle
		if (app.lineWidth != -1)
			newApp.lineWidth = app.lineWidth
		if (app.lineInVisible != null)
			newApp.lineInVisible = app.lineInVisible
		if (app.transparency != -1.0)
			newApp.transparency = app.transparency
		if (!app.filled.equals(BooleanEnum.UNDEF))
			newApp.filled = app.filled
		if (!app.imagePath.isNullOrEmpty)
			newApp.imagePath = app.imagePath
		if (!app.lineStyle.equals(LineStyle.UNSPECIFIED))
			newApp.lineStyle = app.lineStyle
		if (app.background != null)
			newApp.background = EcoreUtil.copy(app.background)
		if (app.foreground != null)
			newApp.foreground = EcoreUtil.copy(app.foreground)
		if (app.font != null)
			newApp.font = EcoreUtil.copy(app.font)
	}

	static def containerIsDiagramOrMovable(AbstractShape abs) {
		return (abs.parentContainerShape == null)
	}

	static def getShapeName(AbstractShape aShape) {
		if(aShape.name.isNullOrEmpty) aShape.genSName() else aShape.name + "Shape";
	}

	static def getGAName(AbstractShape aShape) {
		if(aShape.name.isNullOrEmpty) aShape.genGName() else aShape.name;
	}

	def static getHorizontalValue(Alignment a) {
		switch a.horizontal {
			case LEFT: CincoLayoutFeature.KEY_HORIZONTAL_LEFT
			case CENTER: CincoLayoutFeature.KEY_HORIZONTAL_CENTER
			case RIGHT: CincoLayoutFeature.KEY_HORIZONTAL_RIGHT
			case UNDEFINED: CincoLayoutFeature.KEY_HORIZONTAL_UNDEFINED
		}
	}

	def static getVerticalValue(Alignment a) {
		switch a.vertical {
			case TOP: CincoLayoutFeature.KEY_VERTICAL_TOP
			case MIDDLE: CincoLayoutFeature.KEY_VERTICAL_MIDDLE
			case BOTTOM: CincoLayoutFeature.KEY_VERTICAL_BOTTOM
			case UNDEFINED: CincoLayoutFeature.KEY_VERTICAL_UNDEFINED
		}
	}

	def static genSName(AbstractShape aShape) '''«aShape.class.simpleName.toFirstLower»SHAPE«num»'''

	def static genGName(AbstractShape aShape) '''«aShape.class.simpleName.toFirstLower»«num++»'''

	def recursiveCall(AbstractShape aShape, String containerShapeName) {
		if (aShape instanceof ContainerShape) {
			for (child : aShape.children) {
				return '''
				{
					«child.getCode(containerShapeName)»
				}'''
			}
		}
	}
	
	def static getText(Edge e){
		var annot = e.annotations
		for( an : annot){
			var name = an.name
			if(name.equals("style")){
				var value = an.value
				return listToString(value)
			}
		}
	}

//	def static getAnnotationStyleShapeValue(Node n, Styles styles) {
//		var style = CincoUtils.getStyleForNode(n, styles)
//		val mainShape = style.mainShape
//		var result = getTextValue(mainShape)
//		return result
//	}
//
//	def static getTextValue(AbstractShape shape) {
//		if (shape instanceof ContainerShape) {
//			var children = shape.children
//			for (child : children) {
//				return getTextValue(child)
//			}
//		}
//		if (shape instanceof Text)
//			return shape.value
//	}

	def static getText(Node n) {
		var listAnnot = n.annotations;
		var annot = listAnnot.get(0);
		var listValue = annot.value;
		return listToString(listValue);
	}

	def static listToString(EList<String> list) {
		var string = "";
		if (list.size > 1) {
			for (var i = 1; i < list.size - 1; i++) {
				string += list.get(i);
				string += ", ";
			}
			string += list.get(list.size - 1);
		} else
			string += list.get(list.size - 1);
		return string;
	}


	def static String printPoints(Polygon p) {
		var EList<Point> polyPoints = p.points;
		var pointValues = "";
		for (points : polyPoints) {
			pointValues += points.x + "," + points.y + ",";
		}
		return pointValues
	}

	def static String printPoints(Polyline p) {
		var EList<Point> polyPoints = p.points;
		var pointValues = "";
		for (points : polyPoints) {
			pointValues += points.x + "," + points.y + ",";
		}
		return pointValues
	}

	def static String printX(Polygon p) {
		var EList<Point> polyPoints = p.points;
		var pointX = "";
		for (points : polyPoints) {
			pointX += points.x + ",";
		}
		return pointX;
	}

	def static String printY(Polygon p) {
		var EList<Point> polyPoints = p.points;
		var pointY = "";
		for (points : polyPoints) {
			pointY += points.y + ",";
		}
		return pointY;
	}


	def static String printX(Polyline p) {
		var EList<Point> polyPoints = p.points;
		var pointX = "";
		for (points : polyPoints) {
			pointX += points.x + ",";
		}
		return pointX;
	}

	def static String printY(Polyline p) {
		var EList<Point> polyPoints = p.points;
		var pointY = "";
		for (points : polyPoints) {
			pointY += points.y + ",";
		}
		return pointY;
	}
	
}
