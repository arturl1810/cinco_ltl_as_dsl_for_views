package de.jabc.cinco.meta.core.ge.style.generator.templates.expressionlanguage

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import javax.el.ELContext
import javax.el.VariableMapper
import javax.el.FunctionMapper
import javax.el.CompositeELResolver
import javax.el.ELResolver
import javax.el.BeanELResolver

class ContextTmp extends GeneratorUtils{
	
	def generateContext(mgl.GraphModel gm)'''
	package «gm.packageNameExpression»;
	
	public class «gm.fuName»ExpressionLanguageContext extends «ELContext.name» {
	
		private «Object.name» o;
	
		public «gm.fuName»ExpressionLanguageContext(«Object.name» o) {
			this.o = o;
		}
	
		@Override
		public «VariableMapper.name» getVariableMapper() {
			return null;
		}
	
		@Override
		public «FunctionMapper.name» getFunctionMapper() {
			return null;
		}
	
		@Override
		public «ELResolver.name» getELResolver() {
			«CompositeELResolver.name» compELRes = new «CompositeELResolver.name»();
			compELRes.add(new «BeanELResolver.name»(true));
			compELRes.add(new «gm.fuName»ExpressionLanguageResolver(o));
			return compELRes;
		}
	}
	'''
}