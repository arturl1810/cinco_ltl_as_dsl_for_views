package de.jabc.cinco.meta.core.ge.style.generator.templates.layout

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import mgl.Edge
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.ILayoutContext
import org.eclipse.graphiti.features.impl.AbstractLayoutFeature
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import style.Styles

class EdgeLayoutFeature extends GeneratorUtils {
	
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
			if (pe instanceof «Connection.name») {
				layout((«Connection.name») pe);
				return true;
			}
			return false;
		}
		
		private boolean layout(«Connection.name» cs) {
			return true;
		}
	}
	'''
}