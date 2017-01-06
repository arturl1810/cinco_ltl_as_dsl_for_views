package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtils
import de.jabc.cinco.meta.core.utils.CincoUtils
import graphmodel.ModelElementContainer
import mgl.Edge
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.IAddConnectionContext
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.Ellipse
import org.eclipse.graphiti.mm.algorithms.Image
import org.eclipse.graphiti.mm.algorithms.MultiText
import org.eclipse.graphiti.mm.algorithms.Polygon
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeCreateService
import org.eclipse.graphiti.services.IPeService
import style.AbstractShape
import style.Styles

class EdgeAddFeatures extends GeneratorUtils {
	
	EList<style.Text> text = new BasicEList();
	EList<style.MultiText> multitext = new BasicEList();
	EList<style.Polyline> polyline = new BasicEList();
	EList<style.Polygon> polygon = new BasicEList();
	EList<style.Ellipse> ellipse = new BasicEList();
	EList<style.Image> image = new BasicEList();
	
	
	/**
	 * Generates the Class 'AddFeature' for the Edge e
	 * @param e : The edge
	 * @param styles : Styles
	 */
	def doGenerateEdgeAddFeature(Edge e, Styles styles) {
								'''
	package «e.packageNameAdd»;
	
	public class AddFeature«e.fuName» extends «CincoAbstractAddFeature.name» {
		
		private static «ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
		private static  «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = null;
	
	  	public AddFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
	
		/**
		 * Adds a pictogram element to a container shape
		 * @param context : Contains Information needed to let a feature add a pictogram element
		 * @return Returns the connection
		 */
		public «PictogramElement.name» add(«IAddContext.name» context) {
			«IAddConnectionContext.name» addConContext = («IAddConnectionContext.name») context;
			«e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower» = («e.graphModel.beanPackage».«e.fuName») context.getNewObject();
			if («e.fuName.toFirstLower».getId() == null || «e.fuName.toFirstLower».getId().isEmpty())
				«e.fuName.toFirstLower».setId(«EcoreUtil.name».generateUUID());
			«IPeCreateService.name» peCreateService = «Graphiti.name».getPeCreateService();
	       
			«Connection.name» connection = peCreateService.createFreeFormConnection(getDiagram());
			connection.setStart(addConContext.getSourceAnchor());
			connection.setEnd(addConContext.getTargetAnchor());
			
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«Polyline.name» polyline = gaService.createPolyline(connection);
			 «e.graphModel.packageName».«e.graphModel.name»LayoutUtils.setdefaultStyle(polyline, getDiagram());
			
			«Object.name» sourceBo = addConContext.getSourceAnchor().getParent().getLink().getBusinessObjects().get(0);
			«Object.name» targetBo = addConContext.getTargetAnchor().getParent().getLink().getBusinessObjects().get(0);
			
			«ClassLoader.name» contextClassLoader;
	
			if (sourceBo != null && sourceBo.equals(targetBo)) {
				int x = addConContext.getSourceAnchor().getParent().getGraphicsAlgorithm().getX();
				int y = addConContext.getSourceAnchor().getParent().getGraphicsAlgorithm().getY();
				«Point.name» p1 = gaService.createPoint(x - 30, y + 40);
				«Point.name» p2 = gaService.createPoint(x - 30, y - 20);
				((«FreeFormConnection.name») connection).getBendpoints().add(p1);
				((«FreeFormConnection.name») connection).getBendpoints().add(p2);
			}
			
			// create link and wire it
			link(connection, «e.fuName.toFirstLower»);
			«ConnectionDecorator.name» cd;
			«clear»
			«FOR d : CincoUtils.getStyleForEdge(e, styles).decorator»			
				«IF d.predefinedDecorator != null »			
				cd = peCreateService.createConnectionDecorator(connection, false,«d.location», true);
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.create«d.predefinedDecorator.shape.name()»(cd);
				
				«IF d.predefinedDecorator.shape.name() == "ARROW"»				
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.setdefaultStyle(cd.getGraphicsAlgorithm(), getDiagram());
				«ENDIF»
				«IF d.predefinedDecorator.shape.name() != "ARROW"»
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.set_«e.graphModel.fuName»DefaultAppearanceStyle(cd.getGraphicsAlgorithm(), getDiagram());
				«ENDIF»
				«ENDIF»
				
				«IF d.decoratorShape != null»	
				«IF d.decoratorShape instanceof style.Text»	
				«var textShape = d.decoratorShape as style.Text»
				cd = peCreateService.createConnectionDecorator(connection, false,«d.location», true);
				createShapeText«text.length»(cd, «e.fuName.toFirstLower», "«textShape.value»");
				link(cd, «e.fuName.toFirstLower»);
				«{text.add(textShape); ""}»
				«ELSEIF d.decoratorShape instanceof style.Polyline»
				«var polylineShape = d.decoratorShape as style.Polyline»
				cd = peCreateService.createConnectionDecorator(connection, false, «d.location», true);
				«IF polylineShape.size != null»
				createShapePolyline«polyline.length»(cd, «e.fuName.toFirstLower», «polylineShape.width», «polylineShape.heigth»);
				«ELSE»
				createShapePolyline«polyline.length»(cd, «e.fuName.toFirstLower»);
				«ENDIF»
				link(cd, «e.fuName.toFirstLower»);
				«{polyline.add(polylineShape); ""}»		
				«ELSEIF d.decoratorShape instanceof style.Ellipse»
				«var ellipseShape = d.decoratorShape as style.Ellipse»
				cd = peCreateService.createConnectionDecorator(connection, false, «d.location», true);
				«IF ellipseShape.size != null»
				createShapeEllipse«ellipse.length»(cd, «e.fuName.toFirstLower», «ellipseShape.width», «ellipseShape.heigth»);
				«ELSE»
				createShapeEllipse«ellipse.length»(cd, «e.fuName.toFirstLower»);
				«ENDIF»
				link(cd, «e.fuName.toFirstLower»);
				«{ellipse.add(ellipseShape); ""}»				
				«ELSEIF d.decoratorShape instanceof style.Polygon»
				«var polygonShape = d.decoratorShape as style.Polygon»
				cd = peCreateService.createConnectionDecorator(connection, false, «d.location», true);
				«IF polygonShape.size != null»
				createShapePolygon«polygon.length»(cd, «e.fuName.toFirstLower», «polygonShape.width», «polygonShape.heigth»);
				«ELSE»
				createShapePolygon«polygon.length»(cd, «e.fuName.toFirstLower»);
				«ENDIF»
				link(cd, «e.fuName.toFirstLower»);
				«{polygon.add(polygonShape); ""}»				
				«ELSEIF d.decoratorShape instanceof style.MultiText»
				«var multitextShape = d.decoratorShape as style.MultiText»
				cd = peCreateService.createConnectionDecorator(connection, false, «d.location», true);
				createShapeMultiText«multitext.length»(cd, «e.fuName.toFirstLower», "«multitextShape.value»");
				link(cd, «e.fuName.toFirstLower»);
				«{multitext.add(multitextShape); ""}»				
				«ELSEIF d.decoratorShape instanceof style.Image»
				«var imageShape = d.decoratorShape as style.Image»
				cd = peCreateService.createConnectionDecorator(connection, false,«d.location», true);
				«IF imageShape.size != null»
				createShapeImage«image.length»(cd, «e.fuName.toFirstLower», "«imageShape.path»", «imageShape.width», «imageShape.heigth»);
				«ELSE»
				createShapeImage«image.length»(cd, «e.fuName.toFirstLower», "«imageShape.path»");
				«ENDIF»
				link(cd, «e.fuName.toFirstLower»);
				«{image.add(imageShape); ""}»
				«ENDIF»
				«ENDIF»
			«ENDFOR»

			«e.graphModel.beanPackage».«e.graphModel.name» «e.graphModel.name.toLowerCase» =  «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.addToResource(getDiagram(), this.getFeatureProvider());
			«ModelElementContainer.name» container =  «e.graphModel.packageName».«e.graphModel.name»GraphitiUtils.getInstance().getCommonContainer(«e.graphModel.name.toLowerCase», «e.fuName.toFirstLower»);
			container.getModelElements().add(«e.fuName.toFirstLower»);
	
			if (hook) {
			}
			//«e.graphModel.name»EContentAdapter.getInstance().addAdapter(«e.fuName.toFirstLower»);
	
			«UpdateContext.name» uc = new «UpdateContext.name»(connection);
			«IUpdateFeature.name» uf = getFeatureProvider().getUpdateFeature(uc);
			if (uf.canUpdate(uc))
				uf.update(uc);
			return connection;
		}
	
		/**
		 * Checks if the context can be added
		 * @param context : Contains Information needed to let a feature add a pictogram element
		 * @return Returns true if the context can be added or false
		 */
		public boolean canAdd(«IAddContext.name» context) {
			if (context instanceof «IAddConnectionContext.name» && context.getNewObject() instanceof «e.graphModel.beanPackage».«e.fuName») {
				return true;
			}
			return false;
		}
		
		«shapeMethods(e)»	
	}
	'''
	}
	
	/**
	 * Clears all lists
	 */
	def clear (){
		text.clear
		multitext.clear
		polyline.clear
		polygon.clear
		ellipse.clear
		image.clear
	}
	
	/**
	 * Calls all createShape-Methods
	 * @param e : The edge
	 */
	def shapeMethods(Edge e){
		var counter = 0
		return 
		'''
			«FOR t:text»
			«getText(t,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
			«{ counter = 0; "" }»
			«FOR m:multitext»
			«getMultiText(m,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
			«{ counter = 0; "" }»
			«FOR p:polyline»
			«getPolyline(p,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
			«{ counter = 0; "" }»
			«FOR p:polygon»
			«getPolygon(p,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
			«{ counter = 0; "" }»
			«FOR el:ellipse»
			«getEllipse(el,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
			«{ counter = 0; "" }»
			«FOR i:image»
			«getImage(i,e,counter)»
			«{ counter = counter + 1; "" }»
			«ENDFOR»
		'''
	}
	
	/**
	 * Returns the right setStyle-Methode for the Edge e
	 * @param shape : AbstractShape
	 * @param currentGaName : String
	 * @param e : The edge
	 */
	def appearanceCodeEdge(AbstractShape shape, String currentGaName, Edge e) {
		if (shape.referencedAppearance != null) '''«e.packageName».«e.graphModel.name»LayoutUtils.set«shape.referencedAppearance.name»Style(«currentGaName», getDiagram());'''
		else if (shape.inlineAppearance != null)  ''' «e.packageName».«e.graphModel.name»LayoutUtils.«LayoutFeatureTmpl.shapeMap.get(shape)»(«currentGaName», getDiagram());'''
		else '''«e.graphModel.packageName».«e.graphModel.name»LayoutUtils.set_«e.graphModel.name»DefaultAppearanceStyle(«currentGaName», getDiagram());'''
	}
	
	/**
	 * Gets the coordinates of the points
	 * @param points : List of points
	 * @return Returns the coordinates of all points separated with a comma
	 */
	def getPoints(EList<style.Point> points){
		var result = ""
		for( p: points)
		{
			if(result == "")
				result = p.x + ", " + p.y
			else 
				result = result + ", " + p.x + ", " + p.y
		}
		return result
	}
	
	/**
	 * Generates the methode 'createShapeText'
	 * @param t : Text
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getText (style.Text t, Edge e, int counter){
		'''
		/**
		 * Defines the appearance of the text
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the text
		 * @param textValue : Value of the text
		 */
		private void createShapeText«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower» , «String.name» textValue) {
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
					
			«ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
			«e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = null;
						
			elContext = new  «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext(«e.fuName.toFirstLower»);
			«Object.name» tmpValue = factory.createValueExpression(elContext, "«StyleUtils.getText(e)»", «Object.name».class).getValue(elContext);
			
			«Text.name» text = gaService.createDefaultText(getDiagram(), gaContainer);			
			text.setValue(String.format(textValue , tmpValue));
			peService.setPropertyValue(text, «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING,textValue);
			«appearanceCodeEdge(t, "text", e)»
		}
		
		'''		
	}
	
	/**
	 * Generates the methode 'createShapeMultiText'
	 * @param m : Multitext
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getMultiText(style.MultiText m, Edge e, int counter){
		'''
		/**
		 * Defines the appearance of the multitext
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the multitext
		 * @param textValue : Value of the multitext
		 */
		private void createShapeMultiText«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «String.name» textValue) {
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
			
			«MultiText.name» multitext = gaService.createMultiText(gaContainer);
			multitext.setFilled(false);
			«e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = new «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext(«e.fuName.toFirstLower»);
			Object tmpValue = factory.createValueExpression(elContext, "«StyleUtils.getText(e)»", «Object.name».class).getValue(elContext);
			
			peService.setPropertyValue(multitext, «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING, textValue);
			multitext.setValue(String.format(textValue , tmpValue));
			«appearanceCodeEdge(m, "multitext", e)»
		}
		
		'''
	}
	
	/**
	 * Generates the methode 'createShapeEllipse'
	 * @param el : Ellipse
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getEllipse(style.Ellipse el, Edge e, int counter){
		'''
		«IF el.size != null»
		/**
		 * Defines the appearance of the ellipse
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the ellipse
		 * @param width : Width of the ellipse
		 * @param height : Height of the ellipse
		 */
		private void createShapeEllipse«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «int.name» width, «int.name» height){
		«ELSE»
		/**
		 * Defines the appearance of the ellipse
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the ellipse
		 */
		private void createShapeEllipse«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower»){
		«ENDIF»
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
								
			«Ellipse.name» ellipse = gaService.createPlainEllipse(gaContainer);
			«IF el.size != null»
			gaService.setSize(ellipse, width, height);
			«ENDIF»
			«appearanceCodeEdge(el, "ellipse", e)»
		}
		
		'''
	}
	
	/**
	 * Generates the methode 'createShapePolyline'
	 * @param p : Polyline
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getPolyline(style.Polyline p, Edge e, int counter)	{
		'''
		«IF p.size != null»
		/**
		 * Defines the appearance of the polyline
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the polyline
		 * @param width : Width of the polyline
		 * @param height : Height of the polyline
		 */
		private void createShapePolyline«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «int.name» width, «int.name» height) {
		«ELSE»
		/**
		 * Defines the appearance of the polyline
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the polyline
		 */
		private void createShapePolyline«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower») {
		«ENDIF»
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
						
			«Polyline.name» polyline = gaService.createPolyline(gaContainer, new int[] {«getPoints(p.points)»});
			«IF p.size != null»
			gaService.setSize(polyline, width, height);
			«ENDIF»
			«appearanceCodeEdge(p, "polyline", e)»
		}
		
		'''
	}
	
	/**
	 * Generates the methode 'createShapePolygon'
	 * @param p : Polygon
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getPolygon(style.Polygon p, Edge e, int counter)	{
		'''
		«IF p.size != null»
		/**
		 * Defines the appearance of the polygon
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the polygon
		 * @param width : Width of the polygon
		 * @param height : Height of the polygon
		 */
		private void createShapePolygon«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «int.name» width, «int.name» height) {
		«ELSE»
		/**
		 * Defines the appearance of the polygon
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the polygon
		 */
		private void createShapePolygon«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower») {
		«ENDIF»
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
						
			«Polygon.name» polygon = gaService.createPolygon(gaContainer, new int[] {«getPoints(p.points)»});
			«IF p.size != null»
			gaService.setSize(polygon, width, height);
			«ENDIF»
			«appearanceCodeEdge(p, "polygon", e)»
		}
		
		'''
	}
	
	/**
	 * Generates the methode 'createShapImage'
	 * @param i : Image
	 * @param e : The edge
	 * @param counter : Makes the methode unique 
	 */
	def getImage(style.Image i, Edge e, int counter){
		'''
		«IF i.size != null»
		/**
		 * Defines the appearance of the image
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the image
		 * @param path : Path of the image
		 * @param width : Width of the image
		 * @param height : Height of the image
		 */
		private void createShapeImage«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «String.name» path, «int.name» height, «int.name» width){
		«ELSE»
		/**
		 * Defines the appearance of the image
		 * @param gaContainer : The container for the new graphics algorithm
		 * @param «e.fuName.toFirstLower» : Name of the image
		 * @param path : Path of the image
		 */
		private void createShapeImage«counter»(«GraphicsAlgorithmContainer.name» gaContainer, «e.graphModel.beanPackage».«e.fuName» «e.fuName.toFirstLower», «String.name» path){
		«ENDIF»
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
						
			«String.name» imageId = «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.getInstance().getImageId(path);
			«Image.name» image= gaService.createImage(gaContainer, imageId);
			gaService.setSize(image, width ,height);
		}
		
		'''
	}
	
	/**
	 * Returns the heigth of the shape
	 * @param aShape : AbstractShape
	 */
	def int getHeigth(AbstractShape aShape){
		return aShape.size.height
	}
	
	/**
	 * Returns the width of the shape
	 * @param aShape : AbstractShape
	 */
	def int getWidth (AbstractShape aShape){
		return aShape.size.width
	}	
}