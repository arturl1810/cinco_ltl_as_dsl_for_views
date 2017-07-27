package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.GraphModel
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalModelElementContainer

class EmfFactoryTmpl {

	extension APIUtils = new APIUtils()
	
	def generateFactory(GraphModel gm) '''
	package «gm.packageName»;
	
	public class «gm.fuName»Factory extends «gm.fqFactoryName» {
		
		public static «gm.fuName»Factory eINSTANCE = new «gm.fuName»Factory();
		
		@Override
		public «EObject.name» create(«EClass.name» eClass) {
			«FOR me : gm.modelElements.filter[!isIsAbstract]»
			if (eClass.getName().equals("«me.name»"))
				return create«me.fuName»();
			«ENDFOR»
			return super.create(eClass);
		}
		
		«FOR me : gm.modelElements.filter[!isIsAbstract]»
		@Override
		public «me.fqBeanName» create«me.fuName»() {
			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») «me.fqFactoryName».eINSTANCE.create«me.fuName»().getInternalElement();
			«me.fqCName» me = new «me.fqCName»();
			ime.setElement(me);
			ime.eAdapters().add(«me.packageNameEContentAdapter».«me.fuName»EContentAdapter.getInstance());
			return me;
		}
		
«««		«IF !(me instanceof GraphModel)»
«««		public «me.fqBeanName» create«me.fuName»(«InternalModelElementContainer.name» parent) {
«««			«me.fqInternalBeanName» ime = («me.fqInternalBeanName») «me.fqFactoryName».eINSTANCE.create«me.fuName»(parent).getInternalElement();
«««			«me.fqCName» me = new «me.fqCName»();
«««			ime.eAdapters().add(«me.packageNameEContentAdapter».«me.fuName»EContentAdapter.getInstance());
«««			ime.setElement(me);
«««			return me;
«««		}
«««		«ENDIF»
		«ENDFOR»
	
	}
	'''
	
}