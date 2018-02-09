package de.jabc.cinco.meta.core.mgl.generator.extensions

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.contentadapter.CincoEContentAdapter
import mgl.GraphModel
import mgl.ModelElement
import mgl.UserDefinedType
import org.eclipse.emf.common.notify.Notification
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.emf.ecore.util.EContentAdapter

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.postAttributeValueChange
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension

class AdapterGeneratorExtension {
	
	extension GeneratorUtils = new GeneratorUtils
	
	def generateAdapter(ModelElement it) '''
		package «graphModel.package».adapter
		
		class «name»EContentAdapter extends «EContentAdapter.name» implements «CincoEContentAdapter.name»{
		
			override notifyChanged(«Notification.name» notification) {
				super.notifyChanged(notification)
				val o = notification.notifier
				val feature = notification.feature
				if (o instanceof «fqInternalBeanName») {
					if (o.eContainer == null) return;
					switch feature {
						«EStructuralFeature.name» case feature.isRelevant: {
							«postAttributeValueChange("o")»
							«IF !(it instanceof GraphModel)»
								//o.element.update
								o.element?.rootElement?.updateModelElements
							«ENDIF»
					}}
				}
			}
			
			private def isRelevant(«EStructuralFeature.name» ftr) {
				ftr.eDeliver && «fqInternalPackageName».eINSTANCE.EClassifiers.contains(ftr?.eContainer)
			}
		}
	'''
	
	def generateAdapter(UserDefinedType it) '''
		package «graphModel.package».adapter
		
		class «name»EContentAdapter extends «EContentAdapter.name» {
		
«««			extension «GraphModelExtension.name» = new «GraphModelExtension.name»
		
			override notifyChanged(«Notification.name» notification) {
				super.notifyChanged(notification)
				
				val t = notification.notifier
				if (t instanceof «fqInternalBeanName») {
					t.element?.containingModelElement?.element?.update
				}
			}
			
«««			private def isRelevant(«EStructuralFeature.name» ftr) {
«««				ftr.eDeliver && «fqInternalPackageName».eINSTANCE.EClassifiers.contains(ftr?.eContainer)
«««			}
		
		}
	'''
	
}