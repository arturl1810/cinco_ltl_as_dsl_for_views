package de.jabc.cinco.meta.plugin.primeviewer.tmpl.project

import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.ActivatorTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.ContentProviderTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.LabelProviderTmpl
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.PluginXmlTmpl
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import de.jabc.cinco.meta.plugin.dsl.ProjectDescription
import de.jabc.cinco.meta.plugin.dsl.FolderDescription
import de.jabc.cinco.meta.plugin.dsl.PackageDescription
import de.jabc.cinco.meta.plugin.dsl.FileDescription
import de.jabc.cinco.meta.plugin.dsl.ProjectDescriptionLanguage
import de.jabc.cinco.meta.plugin.primeviewer.tmpl.file.ProviderHelperTmpl

class PrimeViewerProjectTmpl extends ProjectTemplate {
	
	extension GeneratorUtils = new GeneratorUtils
	
	override projectSuffix() '''primeviewer'''
	
	override projectDescription() {
		val project = new ProjectDescription(this)
		
		val folder = new FolderDescription(project, "src")
		project.add(folder)
		project.add(new FileDescription(PluginXmlTmpl))
		
		val pkg = new PackageDescription(projectName)
		folder.packages.add(pkg)
		pkg.add(new FileDescription(ActivatorTmpl))
		
		for (node : primeNodes) {
			val subPkg = new PackageDescription(
				subPackage(node.primeTypePackagePrefix)
			)
			subPkg.add(
				new FileDescription(
					new ContentProviderTmpl(node)
				)
			)
			subPkg.add(
				new FileDescription(
					new LabelProviderTmpl(node)
				)
			)
			subPkg.add(
				new FileDescription(
					new ProviderHelperTmpl(node)
				)
			)
			folder.packages.add(subPkg)
		}
		
		project.manifest => [
			activator = '''«basePackage».Activator'''
			lazyActivation = true
			requiredBundles.addAll(#[
				model.projectSymbolicName,
				"org.eclipse.ui",
				"org.eclipse.core.runtime",
				"org.eclipse.core.resources",
				"org.eclipse.ui.navigator",
				"org.eclipse.emf.common",
				"org.eclipse.emf.ecore"
			])
		]
		
		project.buildProperties.binIncludes.add("plugin.xml")
		
		return project
	}
	
	def projectDescription2() {
		project [
			folder ("src") [
				pkg [
					file (ActivatorTmpl)
				]
				forEachOf(primeNodes) [n |
					pkg (subPackage(n.primeTypePackagePrefix)) [
						files = #[
							new ContentProviderTmpl(n),
							new LabelProviderTmpl(n),
							new ProviderHelperTmpl(n)
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
