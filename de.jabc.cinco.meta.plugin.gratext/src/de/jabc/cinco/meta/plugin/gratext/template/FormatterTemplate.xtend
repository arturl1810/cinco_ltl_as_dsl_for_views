package de.jabc.cinco.meta.plugin.gratext.template

import mgl.Edge

class FormatterTemplate extends AbstractGratextTemplate {


def targetNodes(Edge edge) {
	model.resp(edge).targetNodes
}

override template()
'''	
package «project.basePackage».formatting

import com.google.inject.Inject
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import «project.basePackage».services.*

/**
 * This class contains custom formatting declarations.
 */
public class «project.targetName»Formatter extends AbstractDeclarativeFormatter {
	
	@Inject extension «project.targetName»GrammarAccess
	
	override protected configureFormatting(FormattingConfig c) {
		for(pair: findKeywordPairs('{', '}')) {
			c.setIndentation(pair.first, pair.second)
			c.setLinewrap(1).after(pair.first)
			c.setLinewrap(1).before(pair.second)
			c.setLinewrap(1).after(pair.second)
		}
		for(comma: findKeywords(',')) {
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