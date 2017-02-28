package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.APIUtils
import mgl.GraphModel
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject

class EmfFactoryTmpl {

	extension APIUtils = new APIUtils()
	
	def generateFactory(GraphModel gm) '''
	package «gm.packageName»;
	
	public class «gm.fuName»Factory extends «gm.fqFactoryName» {
		
		@Override
		public «EObject.name» create(«EClass.name» eClass) {
			«FOR me : gm.modelElements»
			if (eClass.getName().equals("«me.name»"))
				return new «me.fqCName»();
			«ENDFOR»
			return super.create(eClass);
		}
	}
	'''
	
}