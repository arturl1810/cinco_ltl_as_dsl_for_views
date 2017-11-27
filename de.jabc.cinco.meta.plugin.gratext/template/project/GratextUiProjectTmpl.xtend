package project

import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import file.EditorTmpl
import file.PluginXmlTmpl
import file.ProposalProviderTmpl
import de.jabc.cinco.meta.plugin.dsl.ProjectType

class GratextUiProjectTmpl extends ProjectTemplate {
	
	override projectSuffix() { "gratext.ui" }
	
	override projectDescription() {
		
		project (projectName) [
			folder ("src") [
				pkg (basePackage) [
					file (EditorTmpl)
				]
				pkg (subPackage("contentassist")) [
					file (ProposalProviderTmpl)
				]
			]
			folder ("src-gen") [/* empty folder is required */]
			folder ("xtend-gen") [/* empty folder is required */]
			
			file (new PluginXmlTmpl(GratextProjectTmpl.basePackage))
			
			lazyActivation = true
			
			natures = #[
				"org.eclipse.xtext.ui.shared.xtextNature"
			]
			
			requiredBundles = #[
				GratextProjectTmpl.projectName,
				"de.jabc.cinco.meta.plugin.gratext.runtime"
			]
			
			importedPackages = #[
				"org.apache.log4j",
				"org.eclipse.emf.common.util",
				"org.eclipse.emf.ecore.resource",
				"org.eclipse.emf.edit.domain",
				"org.eclipse.emf.transaction",
				"org.eclipse.emf.transaction.impl",
				"org.eclipse.emf.transaction.util",
				"org.eclipse.gef",
				"org.eclipse.ui.editors.text",
				"org.eclipse.ui.ide",
				"org.eclipse.ui.part",
				"org.eclipse.ui.views.properties.tabbed",
				"org.eclipse.xtext.ui.editor",
				"de.jabc.cinco.meta.core.ui.editor"
			]
			
			binIncludes = #[
				"plugin.xml"
			]
		]
	}
}