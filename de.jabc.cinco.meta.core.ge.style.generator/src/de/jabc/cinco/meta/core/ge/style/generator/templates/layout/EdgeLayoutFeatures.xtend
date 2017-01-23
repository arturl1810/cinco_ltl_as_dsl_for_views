package de.jabc.cinco.meta.core.ge.style.generator.templates.layout

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.Edge
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ILayoutContext
import org.eclipse.graphiti.features.impl.AbstractLayoutFeature
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import style.Styles
import org.eclipse.graphiti.mm.algorithms.Text
import org.eclipse.graphiti.mm.pictograms.ConnectionDecorator
import org.eclipse.graphiti.datatypes.IDimension
import org.eclipse.graphiti.services.Graphiti
import de.jabc.cinco.meta.core.ge.style.generator.runtime.utils.CincoLayoutUtils

class EdgeLayoutFeatures extends APIUtils {
	
	/**
	 * Generates the Class 'LayoutFeature' for the Edge e
	 * @param e : The edge
	 * @param styles : Styles
	 */
	def doGenerateEdgeLayoutFeature(Edge e,Styles styles)'''
	package «e.packageNameLayout»;
	
	public class LayoutFeature«e.fuName» extends «AbstractLayoutFeature.name»{
		
		public LayoutFeature«e.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		@Override
		public boolean canLayout(«ILayoutContext.name» context) {
			Object bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
			if (bo instanceof «e.fqBeanName»)
				return true;
			return false;
		}
		
		@Override
		public boolean layout(«ILayoutContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			Object bo = getBusinessObjectForPictogramElement(pe);
			if (bo instanceof «e.graphModel.beanPackage».«e.name») {
				if (pe instanceof «Connection.name») {
					«Connection.name» conn = («Connection.name») pe;
					for («ConnectionDecorator.name» cd : conn.getConnectionDecorators()) {
						if (cd.getGraphicsAlgorithm() instanceof «Text.name») {
							«Text.name» t = («Text.name») cd.getGraphicsAlgorithm();
						    «IDimension.name» dim = «CincoLayoutUtils.name».getTextDimension(t);
						    «Graphiti.name».getGaService().setSize(t, dim.getWidth(), dim.getHeight());
						 }
					}
				}
			}
			return true;
		}
	}
	'''
}