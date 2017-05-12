package de.jabc.cinco.meta.core.ge.style.generator.templates.add

import com.sun.el.ExpressionFactoryImpl
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.ge.style.generator.templates.LayoutFeatureTmpl
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.StyleUtils
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.util.xapi.ResourceExtension
import graphmodel.internal.InternalFactory
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal._Decoration
import graphmodel.internal._Point
import mgl.Edge
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
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

class EdgeAddFeatures extends APIUtils {
	
	extension StyleUtils = new StyleUtils
	
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
			«e.fqInternalBeanName» «e.flName» = («e.fqInternalBeanName») context.getNewObject();
			«IPeService.name» peService = «Graphiti.name».getPeService();
	       
			«Connection.name» connection = peService.createFreeFormConnection(getDiagram());
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
			link(connection, «e.flName»);
			«ConnectionDecorator.name» cd;
			«_Decoration.name» _d;// = «InternalFactory.name».eINSTANCE.create_Decoration();
			«_Point.name» _p;// = «InternalFactory.name».eINSTANCE.create_Point();
			
			«FOR d : CincoUtil.getStyleForEdge(e, styles).decorator»
			_d = «InternalFactory.name».eINSTANCE.create_Decoration();
			_p = «InternalFactory.name».eINSTANCE.create_Point();
			cd = peService.createConnectionDecorator(connection, «d.movable»,«d.location», true);
			«d.call(e)»
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
			
			«Resource.name» eResource = ((«EObject.name») sourceBo).eResource();
			«InternalGraphModel.name» internalGraphModel = new «ResourceExtension.name»().getContent(eResource, «e.graphModel.fqInternalBeanName».class);
			«InternalModelElementContainer.name» container = new «GraphModelExtension.name»().getCommonContainer(internalGraphModel, «e.flName»);
					container.getModelElements().add(«e.flName»);
	
			if (hook) {
			}
	
			((«e.fqCName») «e.flName».getElement()).setPictogramElement(connection);
	
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
			if (context instanceof «IAddConnectionContext.name» && 
				context.getNewObject() instanceof «e.fqInternalBeanName») {
				return true;
			}
			return false;
		}
		
		«FOR d : CincoUtil.getStyleForEdge(e, styles).decorator.filter[decoratorShape != null]»
		«d.code(e)»
		«ENDFOR»
	}
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
	
//	
}