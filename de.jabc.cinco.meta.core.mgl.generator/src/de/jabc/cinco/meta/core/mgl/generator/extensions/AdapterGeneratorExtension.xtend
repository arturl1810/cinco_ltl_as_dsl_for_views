package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.ModelElement
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.util.EContentAdapter

import static de.jabc.cinco.meta.core.utils.MGLUtil.*
import org.eclipse.emf.ecore.EStructuralFeature

class AdapterGeneratorExtension {
	
	extension GeneratorUtils = new GeneratorUtils
	
	def generateAdapter(ModelElement it) '''
	package «graphModel.package».adapter;
	
	class «name»EContentAdapter extends «EContentAdapter.name»{
		
		override notifyChanged(«Notification.name» notification) {
			super.notifyChanged(notification)
			val o = notification.notifier
			val feature = notification.feature
			if (o instanceof «fqInternalBeanName») {
				if (feature instanceof «EStructuralFeature.name») {
					if (!feature.invalidFeature) {
						«postAttributeValueChange(it,"o")»
					}
				}
			}
		}
		
		private def invalidFeature(«EStructuralFeature.name» feature) {
			if (feature == null || feature.getName() == null)
				return true;
			
			switch (feature.getName()) {
				«FOR attr : allAttributes(it)»
				case "«attr.attributeName»": return false
				«ENDFOR»
«««				case "incoming": return true
«««				case "outgoing": return true
«««				case "sourceElement": return true
«««				case "targetElement": return true
«««				case "modelElements": return true
			}
			return true
		}
	}
	'''
	
}