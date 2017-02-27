package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import java.util.List
import mgl.ModelElement
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti

class ModelElementEContentAdapter extends GeneratorUtils{
	
	def generateModelElementEContentAdapter(ModelElement me) '''
	package «me.packageNameEContentAdapter»;
	
	
	public class «me.fuName»EContentAdapter extends «me.graphModel.fuName»EContentAdapter{
	
		private static «me.fuName»EContentAdapter instance;
	
		public static «me.fuName»EContentAdapter getInstance() {
			if (instance == null) {
				instance = new «me.fuName»EContentAdapter();
			}
			return instance;
		}
	
		@Override
		public void notifyChanged(«Notification.name» notification) {
			«Object.name» o = notification.getNotifier();
			if (invalidFeature((«EStructuralFeature.name») notification.getFeature()))
				return;
			if («me.internalInstanceofCheck("o")») {
				«me.fqBeanName» tmp = 
					(«me.fqBeanName») ((«me.fqInternalBeanName») o).getElement();
				if (getDiagram() == null)
					return;
				«List.name»<«PictogramElement.name»> pes = «Graphiti.name».getLinkService().getPictogramElements(getDiagram(), tmp);
				if (pes == null || pes.isEmpty())
					return;
				
				«PictogramElement.name» pe = pes.get(0);
				
				«UpdateContext.name» uContext = new «UpdateContext.name»(pes.get(0));
				«IFeatureProvider.name» fp = getFeatureProvider();
				if (fp == null) 
					return;
				«IUpdateFeature.name» uf = fp.getUpdateFeature(uContext);
				if (uf != null && uf.canUpdate(uContext)) {
					uf.update(uContext);
				}
				
			}
			
			refreshPropertyView();
		}
		
	
		private boolean invalidFeature(«EStructuralFeature.name» feature) {
			if (feature == null || feature.getName() == null)
				return true;
			
			switch (feature.getName()) {
			case "incoming":
			case "outgoing":
			case "sourceElement":
			case "targetElement":
			case "modelElements":
				return true;
	
			default:
				break;
			}
			return false;
		}
	
	}
	'''
	
}