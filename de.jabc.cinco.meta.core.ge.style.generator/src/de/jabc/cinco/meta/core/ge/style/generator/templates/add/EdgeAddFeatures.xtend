package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractAddFeature
import graphmodel.ModelElementContainer
import mgl.Edge

import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.IAddConnectionContext
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.GraphicsAlgorithmContainer
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeCreateService
import org.eclipse.graphiti.services.IPeService
import org.eclipse.graphiti.mm.pictograms.Connection
import de.jabc.cinco.meta.core.utils.CincoUtils
import org.eclipse.graphiti.mm.algorithms.Ellipse
import style.impl.TextImpl
import style.AbstractShape
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtils
import style.Styles

class EdgeAddFeatures extends GeneratorUtils {
	
	
	
	def doGenerateAddFeature(Edge e, Styles styles) {
								'''
	package «e.packageNameAdd»;
	
	public class AddFeature«e.fuName» extends «CincoAbstractAddFeature.name» {
		
		private static «ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
		private static  «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = null;
	
	  	public AddFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
	
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

			
			«FOR d : CincoUtils.getStyleForEdge(e, styles).decorator»			
				«IF d.predefinedDecorator != null »			
				cd = peCreateService.createConnectionDecorator(connection, false,«d.location», true);
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.create«d.predefinedDecorator.shape.name()»(cd);
				
				«IF d.predefinedDecorator.shape.name() == "ARROW"»				
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.setdefaultStyle(cd.getGraphicsAlgorithm(), getDiagram());
				«ENDIF»
				«IF d.predefinedDecorator.shape.name() != "ARROW"»
				«e.graphModel.packageName».«e.graphModel.fuName»LayoutUtils.set_FlowGraphDefaultAppearanceStyle(cd.getGraphicsAlgorithm(), getDiagram());
				«ENDIF»
				«ENDIF»
				«IF d.decoratorShape != null»	
				«IF d.decoratorShape instanceof TextImpl»	
				«var text = d.decoratorShape as style.Text»
				cd = peCreateService.createConnectionDecorator(connection, false,«d.location», true);
				createShape3(cd, «e.fuName.toFirstLower», "«text.value»");
				link(cd, «e.fuName.toFirstLower»);
				
				«ELSE»
				«var aShape = d.decoratorShape as AbstractShape»
				
				cd = peCreateService.createConnectionDecorator(connection, false, «d.location», true);
				createShape4(cd, «e.fuName.toFirstLower», «getHeigth(aShape)», «getWidth(aShape)»);
				link(cd, «e.fuName.toFirstLower»);
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
	
		public boolean canAdd(«IAddContext.name» context) {
			if (context instanceof «IAddConnectionContext.name» && context.getNewObject() instanceof «e.graphModel.beanPackage».«e.fuName») {
				return true;
			}
			return false;
		}
	

		private void createShape3(«GraphicsAlgorithmContainer.name» gaContainer, info.scce.cinco.product.«e.graphModel.name.toLowerCase».«e.graphModel.name.toLowerCase».«e.fuName» «e.fuName.toFirstLower», «String.name» textValue) {
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
			«Text.name» Text0 = gaService.createDefaultText(getDiagram(), gaContainer);
			
			«ExpressionFactoryImpl.name» factory = new «ExpressionFactoryImpl.name»();
			 «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext elContext = null;

			elContext = new  «e.graphModel.packageName».expression.«e.graphModel.fuName»ExpressionLanguageContext(«e.fuName.toFirstLower»);
			«Object.name» tmp0Value = factory.createValueExpression(elContext, "«StyleUtils.getAnnotationStyleValue(e, styles)»${label}", «Object.name».class).getValue(elContext);

			Text0.setValue(String.format(textValue , tmp0Value));
			peService.setPropertyValue(Text0, «e.graphModel.packageName».«e.graphModel.fuName»GraphitiUtils.KEY_FORMAT_STRING,textValue);
		}
		private void createShape4(«GraphicsAlgorithmContainer.name» gaContainer, info.scce.cinco.product.«e.graphModel.name.toLowerCase».«e.graphModel.name.toLowerCase».«e.fuName» «e.fuName.toFirstLower», «int.name» height, «int.name» width){
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«IPeService.name» peService = «Graphiti.name».getPeService();
			
			«Ellipse.name» Ellipse0 = gaService.createPlainEllipse(gaContainer);
			gaService.setSize(Ellipse0, width ,height);
			
		}
	}
	'''
	
	}
	
	
	def int getHeigth(AbstractShape aShape){
		return aShape.size.height
	}
	
	def int getWidth (AbstractShape aShape){
		return aShape.size.width
	}
	
	
}