package de.jabc.cinco.meta.plugin.primeviewer.tmpl.project

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.ActivatorTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.ContentProviderTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.LabelProviderTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.PluginXmlTmpl
import de.jabc.cinco.meta.plugin.template.ProjectTemplate

class PrimeViewerProjectTmpl extends ProjectTemplate {
	
	extension GeneratorUtils = new GeneratorUtils
	
	override projectSuffix() '''primeviewer'''
	
	
	
	override projectDescription() {
		project [
			folder ("src") [
				pkg [
					file (ActivatorTmpl)
				]
				forEachOf(primeNodes) [n |
					pkg (subPackage(n.primeTypePackagePrefix)) [
						files = #[
							new ContentProviderTmpl(n),
							new LabelProviderTmpl(n)
						]
					]
				]
			]
			file (PluginXmlTmpl)
			
			activator = '''«basePackage».Activator'''
			lazyActivation = true
			requiredBundles = #[
				model.projectSymbolicName,
				"org.eclipse.ui",
				"org.eclipse.core.runtime",
				"org.eclipse.core.resources",
				"org.eclipse.ui.navigator",
				"org.eclipse.emf.common",
				"org.eclipse.emf.ecore"
			]
			binIncludes = #[
				"plugin.xml"
			]
		]
	}
	
	def primeNodes() {
		model.nodes.filter[primeReference?.hasAnnotation("pvFileExtension")]
	}
}
