package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.GraphModel
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil

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
			return me;
		}
		«ENDFOR»
	
	}
	'''
	
}