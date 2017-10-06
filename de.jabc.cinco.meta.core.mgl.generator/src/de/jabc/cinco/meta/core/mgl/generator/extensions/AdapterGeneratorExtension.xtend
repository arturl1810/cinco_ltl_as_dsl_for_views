package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.ModelElement
import graphmodel.internal.InternalPackage
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.util.EContentAdapter
import org.eclipse.emf.ecore.EStructuralFeature
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.postAttributeValueChange

class AdapterGeneratorExtension {
	
	extension GeneratorUtils = new GeneratorUtils
	
	def generateAdapter(ModelElement it) '''
		package «graphModel.package».adapter
		
		class «name»EContentAdapter extends «EContentAdapter.name» {
		
			override notifyChanged(«Notification.name» notification) {
				super.notifyChanged(notification)
				val o = notification.notifier
				val feature = notification.feature
				if (o instanceof «fqInternalBeanName») {
					switch feature {
						«EStructuralFeature.name» case feature.isRelevant: {
							«postAttributeValueChange("o")»
					}}
				}
			}
			
			private def isRelevant(«EStructuralFeature.name» ftr) {
				! «InternalPackage.name».eINSTANCE.EClassifiers.contains(ftr?.eContainer)
			}
		}
	'''
	
}