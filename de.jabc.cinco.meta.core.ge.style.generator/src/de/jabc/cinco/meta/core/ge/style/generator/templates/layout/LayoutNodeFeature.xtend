package de.jabc.cinco.meta.core.ge.style.generator.templates.layout

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import mgl.Node
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.features.impl.AbstractLayoutFeature
import org.eclipse.graphiti.features.context.ILayoutContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Shape
import style.Styles

class NodeLayoutFeature extends GeneratorUtils{
	
	def doGenerateNodeLayoutFeature(Node n,Styles styles)'''
	package «n.packageNameLayout»;
	
	public class LayoutFeature«n.fuName» extends «AbstractLayoutFeature.name»{
		
		public LayoutFeature«n.fuName»(«IFeatureProvider.name» fp) {
			super(fp);
		}
		
		@Override
		public boolean canLayout(«ILayoutContext.name» context) {
			Object bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
			if (bo instanceof «n.fqBeanName»)
				return true;
			return false;
		}
		
		@Override
		public boolean layout(«ILayoutContext.name» context) {
			«PictogramElement.name» pe = context.getPictogramElement();
			if (pe instanceof «ContainerShape.name») {
				layout((«ContainerShape.name») pe);
				return true;
			}
			return false;
		}
		
		private boolean layout(«ContainerShape.name» cs) {
			for («Shape.name» child : cs.getChildren()) {
				«n.graphModel.packageName».«n.graphModel.fuName»LayoutUtils.layout(cs.getGraphicsAlgorithm(), child.getGraphicsAlgorithm());
				if (child instanceof «ContainerShape.name») {
					layout((«ContainerShape.name») child);
				}
			}
			return true;
		}
	}
	'''
	
	
}