package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.contentadapter.CincoEContentAdapter
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
			}
			
		}
	}
	'''
	
}