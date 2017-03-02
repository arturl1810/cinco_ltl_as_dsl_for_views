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
			«FOR me : gm.modelElements»
			if (eClass.getName().equals("«me.name»"))
				return new «me.fqCName»();
			«ENDFOR»
			return super.create(eClass);
		}
		
		«FOR me : gm.modelElements»
		@Override
		public «me.fqBeanName» create«me.fuName»() {
			«me.fqCName» me = new «me.fqCName»();
			«me.fqInternalBeanName» ime = «me.fqInternalFactoryName».eINSTANCE.createInternal«me.fuName»();
			ime.setElement(me);
			ime.setId(«EcoreUtil.name».generateUUID());
			return me;
		}
		«ENDFOR»
	
	}
	'''
	
}