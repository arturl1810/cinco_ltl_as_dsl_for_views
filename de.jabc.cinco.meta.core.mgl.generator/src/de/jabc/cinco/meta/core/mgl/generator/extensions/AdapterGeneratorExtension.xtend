package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.ModelElement
import graphmodel.internal.InternalPackage
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.util.EContentAdapter
import org.eclipse.emf.ecore.EStructuralFeature
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.postAttributeValueChange
import mgl.Type
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import graphmodel.internal.InternalModelElement

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
				ftr.eDeliver && ! «InternalPackage.name».eINSTANCE.EClassifiers.contains(ftr?.eContainer)
			}
		}
	'''
	
	def generateAdapter(Type it) '''
		package «graphModel.package».adapter
		
		class «name»EContentAdapter extends «EContentAdapter.name» {
		
			extension «GraphModelExtension.name» = new «GraphModelExtension.name»
		
			override notifyChanged(«Notification.name» notification) {
				super.notifyChanged(notification)
				val o = notification.notifier
				val feature = notification.feature
				if (o instanceof «fqInternalBeanName») {
					var element = o.element.modelElement?.map[it as «InternalModelElement.name»]
					if (element?.size == 1)
						element.head.element.update
				}
			}
			
			private def isRelevant(«EStructuralFeature.name» ftr) {
				ftr.eDeliver && ! «InternalPackage.name».eINSTANCE.EClassifiers.contains(ftr?.eContainer)
			}
		}
	'''
	
}