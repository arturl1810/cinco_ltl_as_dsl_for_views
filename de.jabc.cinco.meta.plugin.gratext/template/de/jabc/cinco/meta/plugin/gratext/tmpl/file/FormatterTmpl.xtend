package de.jabc.cinco.meta.plugin.gratext.tmpl.file

import de.jabc.cinco.meta.plugin.template.FileTemplate

class FormatterTmpl extends FileTemplate {
	
//	String projectBasePackage
//	
//	new(String projectBasePackage) {
//		this.projectBasePackage = projectBasePackage
//	}
	
	override getTargetFileName() '''«model.name»GratextFormatter.xtend'''
	
	override template() '''	
		package «package»
		
		import com.google.inject.Inject
		import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
		import org.eclipse.xtext.formatting.impl.FormattingConfig
		import «basePackage».services.*
		
		/**
		 * This class contains custom formatting declarations.
		 */
		public class «model.name»GratextFormatter extends AbstractDeclarativeFormatter {
			
			@Inject extension «model.name»GratextGrammarAccess
			
			override protected configureFormatting(FormattingConfig c) {
				for (pair : findKeywordPairs('{', '}')) {
					c.setIndentation(pair.first, pair.second)
					c.setLinewrap(1).after(pair.first)
					c.setLinewrap(1).before(pair.second)
					c.setLinewrap(1).after(pair.second)
				}
				for (comma : findKeywords(',')) {
					c.setNoLinewrap().before(comma)
					c.setNoSpace().before(comma)
					c.setLinewrap().after(comma)
				}
				c.setLinewrap(0, 1, 2).before(get_SL_COMMENTRule)
				c.setLinewrap(0, 1, 2).before(get_ML_COMMENTRule)
				c.setLinewrap(0, 1, 1).after(get_ML_COMMENTRule)
			}
		}
	'''
	
}