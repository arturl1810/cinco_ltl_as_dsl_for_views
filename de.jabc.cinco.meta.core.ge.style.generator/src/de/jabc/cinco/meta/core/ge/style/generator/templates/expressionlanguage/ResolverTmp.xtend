package de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils;
import javax.el.ELResolver
import javax.el.ELContext
import java.util.Iterator
import javax.el.BeanELResolver
import java.beans.FeatureDescriptor

class ResolverTmp extends GeneratorUtils{
	
	
	/**
	 * Generates the Class 'ExpressionLanguageResolver' for the graphmodel gm
	 * @param gm : GraphModel
	 */
	def generateResolver(mgl.GraphModel gm)'''
	package «gm.packageNameExpression»;
	
	public class «gm.fuName»ExpressionLanguageResolver extends «ELResolver.name»{
	
		private «ELResolver.name» delegate = new «BeanELResolver.name»();
		private «Object.name» o;
		
		public «gm.fuName»ExpressionLanguageResolver(«Object.name» o) {
			this.o = o;
		}
		
		@Override
		public Class<?> getCommonPropertyType(«ELContext.name» arg0, «Object.name» base) {
			if (base == null) {
				base = o;
			}
			return delegate.getCommonPropertyType(arg0, base);
		}
	
		@Override
		public «Iterator.name»<«FeatureDescriptor.name»> getFeatureDescriptors(
				«ELContext.name» arg0, «Object.name» base) {
			if (base == null)
				base = o;
			
			return delegate.getFeatureDescriptors(arg0, base);
		}
	
		@Override
		public Class<?> getType(«ELContext.name» arg0, «Object.name» base, «Object.name» arg2) {
			if (base == null)
				base = o;
			return delegate.getType(arg0, base, arg2);
		}
	
		@Override
		public «Object.name» getValue(«ELContext.name» arg0, «Object.name» base, «Object.name» arg2) {
			if (base == null)
				base = o;
			return delegate.getValue(arg0, base, arg2);
		}
	
		@Override
		public boolean isReadOnly(«ELContext.name» arg0, «Object.name» base, «Object.name» arg2) {
			if (base == null) {
				base = o;
			}
			return delegate.isReadOnly(arg0, base, arg2);
		}
	
		@Override
		public void setValue(«ELContext.name» arg0, «Object.name» base, «Object.name» arg2,
				«Object.name» arg3) {
			if (base == null)
				base = o;
			delegate.setValue(arg0, base, arg2, arg3);
			
		}
	}
	'''
}