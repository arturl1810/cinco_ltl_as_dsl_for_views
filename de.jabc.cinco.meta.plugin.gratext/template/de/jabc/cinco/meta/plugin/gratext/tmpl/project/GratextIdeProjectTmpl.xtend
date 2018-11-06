package de.jabc.cinco.meta.plugin.gratext.tmpl.project

import de.jabc.cinco.meta.plugin.template.ProjectTemplate

class GratextIdeProjectTmpl extends ProjectTemplate {
	
	override projectSuffix() { "gratext.ide" }
	
	override projectDescription() {
		
		project [
			folder ("src") [/* empty folder is required */]
			folder ("src-gen") [/* empty folder is required */]
			folder ("xtend-gen") [/* empty folder is required */]
			
			lazyActivation = true
			
			natures = #[
				"org.eclipse.xtext.ui.shared.xtextNature"
			]
			
			requiredBundles = #[
				GratextProjectTmpl.projectName,
 				"org.eclipse.xtext.ide",
				"org.eclipse.xtext.xbase.ide"
			]
		]
	}
}
