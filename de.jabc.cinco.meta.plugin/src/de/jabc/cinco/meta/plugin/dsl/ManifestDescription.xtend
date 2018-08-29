package de.jabc.cinco.meta.plugin.dsl

import java.util.Set
import org.eclipse.xtend.lib.annotations.Accessors

class ManifestDescription extends FileDescription {
	
	@Accessors String activator
	@Accessors boolean lazyActivation = false
	@Accessors val Set<String> exportedPackages = newHashSet
	@Accessors val Set<String> importedPackages = newHashSet
	@Accessors val Set<String> requiredBundles = newHashSet
	
	new () {
		super("MANIFEST.MF")
	}
	
	override create() {
		parent = new FolderDescription("META-INF") => [
			parent = ManifestDescription.this.project
			create
		]
		super.create
	}
	
	override getContent() '''
		Manifest-Version: 1.0
		Bundle-ManifestVersion: 2
		Bundle-Name: «project.name»
		Bundle-SymbolicName: «project.symbolicName»; singleton:=true
		Bundle-Version: 1.0.0
		Bundle-RequiredExecutionEnvironment: JavaSE-1.8
		«IF activator != null»
			Bundle-Activator: «activator»
		«ENDIF»
		«IF isLazyActivation»
			Bundle-ActivationPolicy: lazy
		«ENDIF»
«««		«FOR name:requiredBundles  BEFORE "Require-Bundle: " SEPARATOR ",\n "»«name»«ENDFOR»
«««		«FOR name:importedPackages BEFORE "Import-Package: " SEPARATOR ",\n "»«name»«ENDFOR»
«««		«FOR name:exportedPackages BEFORE "Export-Package: " SEPARATOR ",\n "»«name»«ENDFOR»
		«"Require-Bundle".with(requiredBundles)»
		«"Import-Package".with(importedPackages)»
		«"Export-Package".with(exportedPackages)»
	'''
	
	private def with(String name, Iterable<String> names) {
		names.join('''«name»: ''', ",\n ", "", [it])
	}
}