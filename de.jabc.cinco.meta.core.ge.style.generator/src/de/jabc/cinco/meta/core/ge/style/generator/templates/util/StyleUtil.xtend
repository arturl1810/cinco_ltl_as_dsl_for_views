package de.jabc.cinco.meta.core.ge.style.generator.templates.util

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.runtime.expressionlanguage.ExpressionLanguageContext
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoLayoutFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoResizeFeature
import de.jabc.cinco.meta.core.ge.style.generator.runtime.utils.CincoLayoutUtils
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import java.util.LinkedList
import mgl.Edge
import mgl.Node
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.styles.Style
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import style.AbsolutPosition
import style.AbstractShape
import style.Alignment
import style.Appearance
import style.BooleanEnum
import style.ConnectionDecorator
import style.ContainerShape
import style.Ellipse
import style.GraphicsAlgorithm
import style.Image
import style.LineStyle
import style.MultiText
import style.NodeStyle
import style.Point
import style.Polygon
import style.Polyline
import style.PredefinedDecorator
import style.Rectangle
import style.RoundedRectangle
import style.StyleFactory
import style.Text
import de.jabc.cinco.meta.core.utils.MGLUtil
import mgl.ModelElement
import java.util.List
import java.util.regex.Pattern
import javax.el.ELException
import style.Font

class StyleUtil extends APIUtils {


	private static var num = 0;
	private static int index = 0;
	private static Node node;

	def getAlgorithmCode(AbstractShape aShape, String containerShapeName, Node n) {
		node = n;
		index = 0;
		'''
				«var currentPeName = getShapeName(aShape)»
				«var currentGaName = getGAName(aShape)»
				«polyVarDeclaration()»				
				
				«aShape.creator(currentPeName.toString, containerShapeName)»
				
				«aShape.getCode(currentGaName, currentPeName)» 
				
				«aShape.setSizeFromContext(currentGaName)»
				
				«aShape.appearanceCode(currentGaName)»

				«aShape.setPosition(currentGaName)»
				
				«aShape.recursiveCall(currentPeName.toString)»
			
				linkAllShapes(«currentPeName», bo);
				layoutPictogramElement(«currentPeName»);
			
			((«n.fqCName») bo.getElement()).setPictogramElement(«currentPeName»);
			
			bo.setX(«currentPeName».getGraphicsAlgorithm().getX());
			bo.setY(«currentPeName».getGraphicsAlgorithm().getY());
			
			if (context.getWidth() != -1 && context.getHeight() != -1)  {
			
				«ResizeShapeContext.name» rc = new «ResizeShapeContext.name»(«currentPeName»);
				rc.setWidth(context.getWidth());
				rc.setHeight(context.getHeight());
				rc.setX(context.getX());
				rc.setY(context.getY());
				«CincoAbstractResizeFeature.name» rf = 
					(«CincoAbstractResizeFeature.name»)getFeatureProvider().getResizeShapeFeature(rc);
«««				rf.activateApiCall(!hook);
			
				if (rf != null)
					rf.resizeShape(rc);
			} else if (parentIsDiagram)  {
				«ResizeShapeContext.name» rc = new «ResizeShapeContext.name»(«currentPeName»);
				rc.setWidth(width);
				rc.setHeight(height);
				rc.setX(context.getX() + minX);
				rc.setY(context.getY() + minY);
				«CincoAbstractResizeFeature.name» rf = 
					(«CincoAbstractResizeFeature.name») getFeatureProvider().getResizeShapeFeature(rc);
«««				rf.activateApiCall(!hook);
			
				if (rf != null)
					rf.resizeShape(rc);
			}
			
			peService.createChopboxAnchor(«currentPeName»);
			layoutPictogramElement(«currentPeName»);
			
			bo.setWidth(«currentPeName».getGraphicsAlgorithm().getWidth());
			bo.setHeight(«currentPeName».getGraphicsAlgorithm().getHeight());

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
		'''peService.setPropertyValue(«currentGaName», "«CincoLayoutFeature.KEY_GA_NAME»", "«currentGaName»");
		'''+
		if (shape.referencedAppearance != null) '''«node.packageName».«node.graphModel.name»LayoutUtils.set«shape.referencedAppearance.name»Style(«currentGaName», getDiagram());'''
		else if (shape.inlineAppearance != null)  ''' «node.packageName».«node.graphModel.name»LayoutUtils.«LayoutFeatureTmpl.shapeMap.get(shape)»(«currentGaName», getDiagram());'''
		else '''«node.graphModel.packageName».«node.graphModel.name»LayoutUtils.set_«node.graphModel.name»DefaultAppearanceStyle(«currentGaName», getDiagram());'''
	}

	def appearanceCode(PredefinedDecorator shape, CharSequence currentGaName) {
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

	def dispatch creator(style.Image s, String peName, String containerName) '''
		«Shape.name» «peName» = peService.createContainerShape(«containerName», «containerIsDiagramOrMovable(s as AbstractShape)»);
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
	/**
	 * Generates a polygon 
	 * @param p : The polygon that will be generated
	 * @param currentGaName : The 'Impl' of a shape e.g. 'polygonImpl25'
	 * @param currentPeName : The 'Shape' of a 'Impl' of a shape e.g. 'polygonImplSHAPE25
	 */
	def dispatch getCode(Polygon p, CharSequence currentGaName, CharSequence currentPeName)'''
		points = new «int»[] {«p.points.map[x +"," + y].join(",")»};
				
		xs = new «int»[] {«p.points.map[x].join(",")»};
		ys = new «int»[] {«p.points.map[y].join(",")»};
		
		minX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(xs);
		maxX = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(xs);
		
		minY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().min(ys);
		maxY = «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().max(ys);
		
		
		«node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().transform(points, -minX, -minY);
		width = maxX - minX;
		height = maxY - minY;	
		
		parentIsDiagram = («currentPeName».getContainer() instanceof «Diagram.name»);
			
		«org.eclipse.graphiti.mm.algorithms.Polygon.name» «currentGaName» = gaService.createPolygon(«currentPeName», points);
		
		
		«node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.getInstance().transform(points, -minX, -minY);
		
		gaService.setSize(«currentGaName», width, height);
		
		pointsString = "";
		for (int i : points) {
			pointsString += String.valueOf(i)+",";
		} //«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.KEY_INITIAL_POINTS, pointsString);
		peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_INITIAL_POINTS, pointsString);
		
		if(!(«currentPeName».getContainer() instanceof «Diagram.name»))
			peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getContainer().getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getContainer().getGraphicsAlgorithm().getHeight());
		else peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getGraphicsAlgorithm().getHeight()); 
		
			«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.set_«node.graphModel.fuName»DefaultAppearanceStyle(«currentGaName», getDiagram());
			gaService.setLocation(«currentGaName», 0, 0);
			peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_HORIZONTAL, «CincoLayoutUtils.typeName».KEY_HORIZONTAL_UNDEFINED);
			peService.setPropertyValue(«currentGaName», «CincoLayoutUtils.typeName».KEY_VERTICAL,«CincoLayoutUtils.typeName».KEY_VERTICAL_UNDEFINED);
		
	'''
	/**
	 * Generates the variable declaration that is need for the getCode-Method for polygon and polyline
	 */	
	def polyVarDeclaration() '''
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
	/**
	 * Generates a polyline 
	 * @param p : The polyline that will be generated
	 * @param currentGaName : The 'Impl' of a shape e.g. 'polylineImpl'
	 * @param currentPeName : The 'Shape' of a 'Impl' of a shape e.g. 'polylineImplSHAPE'
	 */
	def dispatch getCode(Polyline p, CharSequence currentGaName, CharSequence currentPeName) '''

		points = new «int»[] {«p.points.map[ x+","+y].join(",")»};
				
		xs = new «int»[] {«p.points.map[x].join(",")»};
		ys = new «int»[] {«p.points.map[y].join(",")»};
		
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
			peService.setPropertyValue(«currentGaName», «CincoLayoutUtils.typeName».KEY_INITIAL_PARENT_SIZE, "" + «currentPeName».getContainer().getGraphicsAlgorithm().getWidth() + "," + «currentPeName».getContainer().getGraphicsAlgorithm().getHeight()); 
		} else {
			«currentGaName» = gaService.createPolyline(«currentPeName», new int[] {0,0,10,10,20,0,});
			peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_INITIAL_PARENT_SIZE, "" + width + "," + height); 
		}
		
		peService.setPropertyValue(«currentGaName», «CincoLayoutUtils.typeName».KEY_INITIAL_POINTS, pointsString);
		«node.graphModel.packageName».«node.graphModel.fuName»LayoutUtils.set_«node.graphModel.fuName»DefaultAppearanceStyle(«currentGaName», getDiagram());
		gaService.setLocation(«currentGaName», 0, 0);
		peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_HORIZONTAL,«CincoLayoutUtils.typeName».KEY_HORIZONTAL_UNDEFINED);
		peService.setPropertyValue(«currentGaName»,«CincoLayoutUtils.typeName».KEY_VERTICAL, «CincoLayoutUtils.typeName».KEY_VERTICAL_UNDEFINED);
		
		
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
		
			«ExpressionLanguageContext.name» elContext = 
				new «ExpressionLanguageContext.name»(bo);
			
			«String.name» _expression = "«getText(node)»";
			«Object.name» _values[] = new «Object.name»[_expression.split(";").length];
			for (int i=0; i < _values.length; i++)
				_values[i] = "";
				
			for (int i=0; i < _expression.split(";").length;i++) {
				_values[i] = factory.createValueExpression(elContext, _expression.split(";")[i], «Object.name».class).getValue(elContext);
			}
			
«««			«Object.name» tmp0Value = factory.createValueExpression(elContext, "«getText(node)»", «Object.name».class).getValue(elContext);
		
			peService.setPropertyValue(«currentGaName.toString», «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, "«t.value»");

			peService.setPropertyValue(«currentGaName.toString», "Params","«getText(node)»");
«««			if (tmp0Value != null)
			«currentGaName.toString».setValue(String.format("«t.value»", _values));
«««			else «currentGaName.toString».setValue("");
		} catch (java.util.IllegalFormatException ife) {
			«currentGaName.toString».setValue("STRING FORMAT ERROR");
		} catch («ELException.name» ele) {
			if (ele.getCause() instanceof «NullPointerException.name»)
				«currentGaName».setValue("null");
		} finally {
			«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
		}
		
	'''

	def dispatch getCode(MultiText t, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.MultiText.name» «currentGaName» = gaService.createPlainMultiText(«currentPeName»);
		
		«ExpressionFactoryImpl.name» factory = new com.sun.el.ExpressionFactoryImpl();
		«LinkedList.name» <«Shape.name»>linkingList = new «LinkedList.name» <«Shape.name»>();
		linkingList.add(«currentPeName.toString»);
		«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
		try {
			«currentGaName.toString».setFilled(false);
			«Thread.name».currentThread().setContextClassLoader(AddFeature«node.name».class.getClassLoader());
		
			«ExpressionLanguageContext.name» elContext = 
				new «ExpressionLanguageContext.name»(bo);
				
			«Object.name» tmp0Value = factory.createValueExpression(elContext, "«getText(node)»", «Object.name».class).getValue(elContext);
		
			peService.setPropertyValue(«currentGaName.toString», «node.graphModel.packageName».«node.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, "«t.value»");

			peService.setPropertyValue(«currentGaName.toString», "Params","«getText(node)»");
			if (tmp0Value != null)
				«currentGaName.toString».setValue(String.format("«t.value»", ((«String.name») tmp0Value).split(";")));
			else «currentGaName.toString».setValue("");
		} catch (java.util.IllegalFormatException ife) {
			«currentGaName.toString».setValue("STRING FORMAT ERROR");
		} catch («ELException.name» ele) {
			if (ele.getCause() instanceof «NullPointerException.name»)
				«currentGaName».setValue("null");
		} finally {
			«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
		}
	'''

	def dispatch getCode(Image p, CharSequence currentGaName, CharSequence currentPeName) '''
		«org.eclipse.graphiti.mm.algorithms.Image.name» «currentGaName» = gaService.createImage(«currentPeName», "«p.path»");
		«currentGaName».setStretchH(true);
		«currentGaName».setStretchV(true);
	'''

	def setSizeFromContext(AbstractShape a, CharSequence gaName) '''
«««		if (context.getWidth() > 0 && context.getHeight() > 0)
«««			gaService.setSize(«gaName», context.getWidth(), context.getHeight());
«««		else 
		//Setting the size independent of the one given in the context. 
		//Thus, it is possible to resize inner shapes correctly
		gaService.setSize(«gaName», «a.size?.width», «a.size?.height»);
		«setSizeProperties(a, gaName)»
	'''
	
	def setSize(AbstractShape a, CharSequence gaName) '''
		gaService.setSize(«gaName», «a.size?.width», «a.size?.height»);
		«setSizeProperties(a, gaName)»
	'''
	
	def setSizeProperties(AbstractShape a,  CharSequence gaName) '''
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
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_HORIZONTAL»", "«CincoLayoutFeature.KEY_HORIZONTAL_UNDEFINED»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_VERTICAL»", "«CincoLayoutFeature.KEY_VERTICAL_UNDEFINED»");
			«ELSEIF a instanceof Alignment»
				«var Alignment alignment = a as Alignment»
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_HORIZONTAL»", "«alignment.getHorizontalValue»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_VERTICAL»", "«alignment.getVerticalValue»");
				
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_MARGIN_HORIZONTAL»", "«alignment?.XMargin»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_MARGIN_VERTICAL»", "«alignment?.YMargin»");
			«ELSEIF a == null»
				gaService.setLocation(«gaName», 0, 0);
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_HORIZONTAL»", "«CincoLayoutFeature.KEY_HORIZONTAL_UNDEFINED»");
				peService.setPropertyValue(«gaName», "«CincoLayoutFeature.KEY_VERTICAL»", "«CincoLayoutFeature.KEY_VERTICAL_UNDEFINED»");
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

	def call(ConnectionDecorator cd, Edge e) {
		if (cd.predefinedDecorator != null) return cd.predefinedDecorator.cdCall(e)
		if (cd.decoratorShape != null) return cd.decoratorShape.cdShapeCall(e)
	}

	
	def cdCall(PredefinedDecorator pd, Edge e) '''
		de.jabc.cinco.meta.core.ge.style.generator.runtime.utils.CincoLayoutUtils.create«pd.shape.getName»(cd);
«««		«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.set_«node.graphModel.name»DefaultAppearanceStyle(cd.getGraphicsAlgorithm(), getDiagram());
		«pd.appearanceCode("cd.getGraphicsAlgorithm()")»
	'''
	
	def cdShapeCall(GraphicsAlgorithm ga, Edge e) {
		if (ga instanceof Text || ga instanceof MultiText)
		'''createShape«ga.hashName»(cd, («e.fqInternalBeanName») «e.flName», "«ga.value»", "«e.text»");'''
		else 
		'''createShape«ga.hashName»(cd, («e.fqInternalBeanName») «e.flName», «ga.size?.width», «ga.size?.height»);'''
	}
	
	def code(ConnectionDecorator cd, Edge e) {
		if (cd.predefinedDecorator != null) return cd.predefinedDecorator.cdCode(e)
		if (cd.decoratorShape != null) return cd.decoratorShape.cdShapeCode(e)
	}
	
	def cdShapeCode(GraphicsAlgorithm ga, Edge e) '''
		«IF (ga instanceof style.Text || ga instanceof MultiText)»
		private void createShape«ga.hashName»(«GraphicsAlgorithmContainer.name» gaContainer, «e.fqInternalBeanName» «e.flName», «String.name» textValue, «String.name» attrValue) {
		«ELSE»
		private void createShape«ga.hashName»(«GraphicsAlgorithmContainer.name» gaContainer, «e.fqInternalBeanName» «e.flName», int width, int height) {
		«ENDIF»
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
			
			«ga.cdCode(e)»
			
			«IF ga.size != null»
			gaService.setSize(«ga.simpleName.toLowerCase», width, height);
			«ELSE»
			gaService.setSize(«ga.simpleName.toLowerCase», 100, 25);
			«ENDIF»
			«appearanceCode(ga as AbstractShape,ga.simpleName.toLowerCase)»
		}
	'''
	
	def dispatch cdCode(Text ga, Edge e) '''
		«var currentGaName = "text"»
		«org.eclipse.graphiti.mm.algorithms.Text.name» «currentGaName» = gaService.createPlainText(gaContainer);
				
		«««Hier muss der Code generiert werden, der den anzuzeigenden Wert aus der zugehörigen @style annotation ausliest
		«ExpressionFactoryImpl.name» factory = new com.sun.el.ExpressionFactoryImpl();
		«LinkedList.name» <«Shape.name»>linkingList = new «LinkedList.name» <«Shape.name»>();
		«ClassLoader.name» contextClassLoader = «Thread.name».currentThread().getContextClassLoader();
		try {
			«currentGaName.toString».setFilled(false);
			«Thread.name».currentThread().setContextClassLoader(AddFeature«e.name».class.getClassLoader());
		
			«ExpressionLanguageContext.name» elContext = 
				new «ExpressionLanguageContext.name»(«e.flName»);
			
			«String.name» _expression = "«getText(e)»";
			«Object.name» _values[] = new «Object.name»[_expression.split(";").length];
			for (int i=0; i < _values.length; i++)
				_values[i] = "";
				
			for (int i=0; i < _expression.split(";").length;i++) {
				_values[i] = factory.createValueExpression(elContext, _expression.split(";")[i], «Object.name».class).getValue(elContext);
			}
			
«««			«Object.name» tmp0Value = factory.createValueExpression(elContext, "«getText(node)»", «Object.name».class).getValue(elContext);
		
			peService.setPropertyValue(«currentGaName.toString», «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, "«ga.value»");

			peService.setPropertyValue(«currentGaName.toString», "Params","«getText(e)»");
«««			if (tmp0Value != null)
			«currentGaName.toString».setValue(String.format("«ga.value»", _values));
«««			else «currentGaName.toString».setValue("");
		} catch (java.util.IllegalFormatException ife) {
			«currentGaName.toString».setValue("STRING FORMAT ERROR");
		} catch («ELException.name» ele) {
			if (ele.getCause() instanceof «NullPointerException.name»)
				«currentGaName».setValue("null");
		} finally {
			«Thread.name».currentThread().setContextClassLoader(contextClassLoader);
		}
	'''
	
	def dispatch cdCode(MultiText ga, Edge e) '''
		«MultiText.name» multitext = gaService.createMultiText(gaContainer);
		multitext.setFilled(false);
		«e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = new «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext(«e.flName»);
		Object tmpValue = factory.createValueExpression(elContext, attrValue, «Object.name».class).getValue(elContext);
		
		peService.setPropertyValue(multitext, «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, textValue);
		multitext.setValue(String.format(textValue , tmpValue));
	'''
	
	def dispatch cdCode(Ellipse ga, Edge e) {
		ga.getCode("ellipse", "gaContainer")	
	}
	
	def dispatch cdCode(Rectangle ga, Edge e) {
		ga.getCode("rectangle", "gaContainer")
	} 
	
	def dispatch cdCode(RoundedRectangle ga, Edge e) {
		ga.getCode("roundedRectangle", "gaContainer")
	}
	
	def dispatch cdCode(Polyline p, Edge e) '''
		«org.eclipse.graphiti.mm.algorithms.Polyline.name» polyline = gaService.createPolyline(gaContainer, new int[] {«p.points.map[x +","+y].join(",")»});
	'''
	
	def dispatch cdCode(Polygon p, Edge e) '''
		«org.eclipse.graphiti.mm.algorithms.Polygon.name» polygon = gaService.createPolygon(gaContainer, new int[] {«p.points.map[x +","+y].join(",")»});
	'''
	def dispatch cdCode(Image ga, Edge e) {
		ga.getCode("image", "gaContainer")
	}
	
	
	def static setAppearance(AbstractShape aShape, CharSequence gaName) {
		var app = if (aShape.referencedAppearance == null) aShape.inlineAppearance else aShape.referencedAppearance
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
			aShape.children.map[ '''
			{
				«getCode(containerShapeName)»
			}'''
			].join("\n")
		}
	}
	
	
	def getText(ModelElement me) {
		val annot = MGLUtil.getAnnotation(me, "style")
		val values = annot.value 
		switch (me) {
			Node: me.getText(values)
			Edge: me.getText(values)
		}
	} 
	
	/**
	 * 
	 */
	private def dispatch getText(Edge e, EList<String> vals){
		vals.subList(1,vals.size).join(";")
	}
	
	/**
	 * Auxiliary method to get the text of a node
	 * @param n : The node
	 * @return Returns the string with the text of a node
	 */
	private def dispatch getText(Node n, EList<String> vals) {
		if (n.isPrime) {
			val expPattner = Pattern.compile("\\$\\{(.*)\\}")
			vals.subList(1,vals.size)
			.map[
				val m = expPattner.matcher(it)
				if (m.matches) {
					MGLUtil::refactorIfPrimeAttribute(n,m.group(1))
				} else it
			].join(";")	
			
		} else vals.subList(1,vals.size).join(";")
	}
	
	def size(GraphicsAlgorithm ga) {
		switch (ga) {
			AbstractShape: ga.size
		}
	}

	def value(GraphicsAlgorithm ga) {
		switch (ga) {
			Text: ga.value
			MultiText: ga.value
		}
	}

	def hashName(GraphicsAlgorithm ga) {
		ga.class.simpleName.replaceFirst("Impl", "")+ga.hashCode
	}
	
	def simpleName(GraphicsAlgorithm ga) {
		ga.class.simpleName.replaceFirst("Impl", "")
	}
	
	def getGaName(style.ConnectionDecorator cd) {
		if (!cd.name.isNullOrEmpty) return cd.name
		else {
			if (cd.predefinedDecorator != null) return cd.predefinedDecorator.shape.toString+index++
			if (cd.decoratorShape != null) return "Shape"+index++
		} 
	}
	
	def getFName(Font f) {
		if (f == null) "Arial" else f.fontName
	}
	
	def getFontSize(Font f) {
		if (f == null) 8 else f.size
	}
	
	def isBold(Font f) {
		if (f == null) false else f.isIsBold
	}
	
	def isItalic(Font f) {
		if (f == null) false else f.isIsItalic
	}
}
