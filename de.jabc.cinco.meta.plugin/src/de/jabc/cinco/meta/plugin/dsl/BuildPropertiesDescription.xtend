package de.jabc.cinco.meta.plugin.dsl

import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors

class BuildPropertiesDescription extends FileDescription {
	
	@Accessors val Set<String> binIncludes = newHashSet
	@Accessors val Set<String> additionalBundles = newHashSet
	
	new() {
		super("build.properties")
	}
	
	override getContent() '''
		source.. = «project.sourceFolders.map[name + '/'].join(', ')»
		bin.includes = ., META-INF/«binIncludes.map[''', «it»'''].join»
		«"additional.bundles".withValues(additionalBundles)»
	'''
	
	private def withValues(String name, Iterable<String> names) {
		if (!names.nullOrEmpty)
			names.join('''«name» = ''', ", ", "", [it])
	}
}