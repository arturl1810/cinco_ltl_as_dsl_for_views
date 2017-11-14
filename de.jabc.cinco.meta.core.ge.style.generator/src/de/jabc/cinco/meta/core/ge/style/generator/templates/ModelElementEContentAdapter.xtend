package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.adapter.CincoEContentAdapter
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.ModelElement
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.EStructuralFeature

class ModelElementEContentAdapter extends GeneratorUtils{
	
	extension APIUtils = new APIUtils
	
	def doGenerateModelElementEContentAdapter(ModelElement me) '''
	package «me.packageNameEContentAdapter»;
	
	
	public class «me.fuName»EContentAdapter extends «me.graphModel.package».adapter.«me.fuName»EContentAdapter implements «CincoEContentAdapter.name»{
	
		private static «me.fuName»EContentAdapter instance;
	
		private «me.fuName»EContentAdapter() {};
	
		public static «me.fuName»EContentAdapter getInstance() {
			if (instance == null) {
				instance = new «me.fuName»EContentAdapter();
			}
			return instance;
		}
	
		@Override
		public void notifyChanged(«Notification.name» notification) {
			«Object.name» o = notification.getNotifier();
			«Object.name» feature = notification.getFeature();
			if (feature instanceof «EStructuralFeature.name»)
				if (!((«EStructuralFeature.name») feature).eDeliver()) return;
			if («me.internalInstanceofCheck("o")») {
				«me.fqInternalBeanName» tmp = 
					(«me.fqInternalBeanName») o;
				
				if («me.cInstanceofCheck("tmp.getElement()")» && tmp.getRootElement() != null) {
					((«me.fqCName») tmp.getElement()).update();
				}
«««				if (getDiagram() == null)
«««					return;
«««				«List.name»<«PictogramElement.name»> pes = «Graphiti.name».getLinkService().getPictogramElements(getDiagram(), tmp);
«««				if (pes == null || pes.isEmpty())
«««					return;
«««				
«««				«PictogramElement.name» pe = pes.get(0);
«««				
«««				«UpdateContext.name» uContext = new «UpdateContext.name»(pes.get(0));
«««				«IFeatureProvider.name» fp = getFeatureProvider();
«««				if (fp == null) 
«««					return;
«««				«IUpdateFeature.name» uf = fp.getUpdateFeature(uContext);
«««				if (uf != null && uf.canUpdate(uContext)) {
«««					uf.update(uContext);
«««				}
			}
			
«««			refreshPropertyView();
		}
		
	
«««		private boolean invalidFeature(«EStructuralFeature.name» feature) {
«««			if (feature == null || feature.getName() == null)
«««				return true;
«««			
«««			switch (feature.getName()) {
«««			case "incoming":
«««			case "outgoing":
«««			case "sourceElement":
«««			case "targetElement":
«««			case "modelElements":
«««				return true;
«««	
«««			default:
«««				break;
«««			}
«««			return false;
«««		}
	
	}
	'''
	
}