package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.runtime.utils.CincoLayoutUtils
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.core.utils.MGLUtil
import graphmodel.internal.InternalFactory
import graphmodel.internal._Decoration
import graphmodel.internal._Point
import mgl.Edge
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.IAddConnectionContext
import org.eclipse.graphiti.features.context.IAddContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.algorithms.Polyline
import org.eclipse.graphiti.mm.algorithms.styles.Point
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.services.IGaService
import org.eclipse.graphiti.services.IPeService
import style.AbstractShape
import style.Styles

import static extension de.jabc.cinco.meta.core.utils.CincoUtil.*
import style.EdgeStyle
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtil
import graphmodel.internal.InternalIdentifiableElement
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAddFeature

class EdgeAddFeatures extends APIUtils {
	
	extension StyleUtil = new StyleUtil
	
	/**
	 * Generates the Class 'AddFeature' for the Edge e
	 * @param e : The edge
	 * @param styles : Styles
	 */
	def doGenerateEdgeAddFeature(Edge e, Styles styles) {
	'''
	package «e.packageNameAdd»;
	
	public class AddFeature«e.fuName» extends «CincoAddFeature.name» {
		
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
			«e.fqInternalBeanName» «e.flName» = («e.fqInternalBeanName») context.getNewObject();
			«IPeService.name» peService = «Graphiti.name».getPeService();
	       
			«Connection.name» connection = peService.createFreeFormConnection(getDiagram());
			connection.setStart(addConContext.getSourceAnchor());
			connection.setEnd(addConContext.getTargetAnchor());
			
			«IGaService.name» gaService = «Graphiti.name».getGaService();
			«Polyline.name» polyline = gaService.createPolyline(connection);
«««			«e.graphModel.packageName».«e.graphModel.name»LayoutUtils.set_«e.graphModel.name»DefaultAppearanceStyle(polyline, getDiagram());
			«e.getStyleForEdge(styles).appearanceCodeEdge("polyline", e)»
			«Graphiti.name».getPeService().setPropertyValue(
				polyline, «CincoLayoutUtils.name».KEY_GA_NAME, "connection");
			
			«Object.name» sourceBo = addConContext.getSourceAnchor().getParent().getLink().getBusinessObjects().get(0);
			«Object.name» targetBo = addConContext.getTargetAnchor().getParent().getLink().getBusinessObjects().get(0);
			
			«ClassLoader.name» contextClassLoader;
	
			if (sourceBo != null && sourceBo.equals(targetBo)) {
				int x = addConContext.getSourceAnchor().getParent().getGraphicsAlgorithm().getX();
				int y = addConContext.getSourceAnchor().getParent().getGraphicsAlgorithm().getY();
				
				«_Point.name» p1t = «InternalFactory.name».eINSTANCE.create_Point();
				«_Point.name» p2t = «InternalFactory.name».eINSTANCE.create_Point();
				p1t.setX(x- 30);
				p1t.setY(y+ 40);
				p2t.setX(x- 30);
				p2t.setY(y- 20);
				«e.flName».getBendpoints().add(p1t);
				«e.flName».getBendpoints().add(p2t);
				
				«Point.name» p1c = gaService.createPoint(x - 30, y + 40);
				«Point.name» p2c = gaService.createPoint(x - 30, y - 20);
				((«FreeFormConnection.name») connection).getBendpoints().add(p1c);
				((«FreeFormConnection.name») connection).getBendpoints().add(p2c);
			}
			
			// create link and wire it
			link(connection, «e.flName»);
			«ConnectionDecorator.name» cd;
			«_Decoration.name» _d;// = «InternalFactory.name».eINSTANCE.create_Decoration();
			«_Point.name» _p;// = «InternalFactory.name».eINSTANCE.create_Point();
			«Polyline.name» dummy;
			«FOR d : e.getStyleForEdge(styles).decorator»
			_d = «InternalFactory.name».eINSTANCE.create_Decoration();
			_p = «InternalFactory.name».eINSTANCE.create_Point();
			cd = peService.createConnectionDecorator(connection, «d.movable»,«d.location», true);
			«d.call(e)»
			«Graphiti.name».getPeService().setPropertyValue(
				cd.getGraphicsAlgorithm(), «CincoLayoutUtils.name».KEY_GA_NAME, "«d.gaName»");
			«IF d.decoratorShape != null»
			_d.setNameHint(cd.getGraphicsAlgorithm().getClass().getSimpleName().substring(0,cd.getGraphicsAlgorithm().getClass().getSimpleName().lastIndexOf("Impl")));
			_p.setX(cd.getGraphicsAlgorithm().getX());
			_p.setY(cd.getGraphicsAlgorithm().getY());
			«ENDIF»
			_d.setLocation(«d.location»);
			_d.setLocationShift(_p);
			
			peService.setPropertyValue(cd, "cdIndex", "«CincoUtil.getStyleForEdge(e, styles).decorator.indexOf(d)»");
			link(cd, «e.flName»);
			if («e.flName».getDecorators().size() <= «CincoUtil.getStyleForEdge(e, styles).decorator.indexOf(d)»)
				«e.flName».getDecorators().add(«CincoUtil.getStyleForEdge(e, styles).decorator.indexOf(d)», _d);
			«ENDFOR»
			
			((«e.fqCName») «e.flName».getElement()).setPictogramElement(connection);
			
			// sync bendpoint changes between diagram and model
			applyBendpointSynchronizer(connection);
	
«««			«IF MGLUtil::hasPostCreateHook(e)»
«««			if (hook) «e.packageName».«e.graphModel.fuName»Factory.eINSTANCE.postCreates((«e.fqBeanName») «e.flName».getElement());
«««			«ENDIF»
	
			«UpdateContext.name» uc = new «UpdateContext.name»(connection);
			«IUpdateFeature.name» uf = getFeatureProvider().getUpdateFeature(uc);
			if (uf.canUpdate(uc))
				«e.flName».getElement().updateGraphModel();
			return connection;
		}
	
		/**
		 * Checks if the context can be added
		 * @param context : Contains Information needed to let a feature add a pictogram element
		 * @return Returns true if the context can be added or false
		 */
		public boolean canAdd(«IAddContext.name» context) {
			if (context instanceof «IAddConnectionContext.name» && 
				context.getNewObject() instanceof «e.fqInternalBeanName») {
				return true;
			}
			return false;
		}
		
		«FOR d : CincoUtil.getStyleForEdge(e, styles).decorator.filter[decoratorShape != null]»
		«d.code(e)»
		«ENDFOR»
		
		@Override
		protected void link(«PictogramElement.name» pe, «Object.name» bo) {
			if (bo instanceof «InternalIdentifiableElement.name») {
				bo = ((«InternalIdentifiableElement.name»)bo).getElement();
			}
			super.link(pe, bo);
		}
	}
	'''
	}
	
	/**
	 * Returns the right setStyle-Methode for the Edge e
	 * @param shape : AbstractShape
	 * @param currentGaName : String
	 * @param e : The edge
	 */
	def appearanceCodeEdge(EdgeStyle shape, String currentGaName, Edge e) {
		if (shape.referencedAppearance != null) '''«e.packageName».«e.graphModel.name»LayoutUtils.set«shape.referencedAppearance.name»Style(«currentGaName», getDiagram());'''
		else if (shape.inlineAppearance != null)  '''«e.packageName».«e.graphModel.name»LayoutUtils.«LayoutFeatureTmpl.shapeMap.get(shape)»(«currentGaName», getDiagram());'''
		else '''«e.graphModel.packageName».«e.graphModel.name»LayoutUtils.set_«e.graphModel.name»DefaultAppearanceStyle(«currentGaName», getDiagram());'''
	}
	
	
//	
}