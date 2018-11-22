package de.jabc.cinco.meta.plugin.gratext.tmpl.project

import de.jabc.cinco.meta.plugin.dsl.FolderDescription
import de.jabc.cinco.meta.plugin.gratext.build.GratextModelBuild
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.EcoreTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.FormatterTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.GenmodelTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.GrammarTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.InternalPackageTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.MweWorkflowTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.QualifiedNameProviderTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.ResourceTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.RuntimeModuleTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.ScopeProviderTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.TransformerTmpl
import de.jabc.cinco.meta.plugin.template.ProjectTemplate

import static de.jabc.cinco.meta.plugin.gratext.GratextBuilder.PROJECT_REGISTRY
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.AstFactoryTmpl
import de.jabc.cinco.meta.plugin.gratext.tmpl.file.LinkingServiceTmpl
import de.jabc.cinco.meta.plugin.dsl.ProjectDescription

class GratextProjectTmpl extends ProjectTemplate {
	
	ProjectDescription project
	FolderDescription srcFolder
	
	override projectSuffix() { "gratext" }
	
	override projectDescription() {
		project [
			folder ("model") [
				isSourceFolder = false
				pkg [
					files = #[
						EcoreTmpl,
						GenmodelTmpl
					]
				]
			]
			folder ("src") [
				pkg [
					file (ResourceTmpl)
				]
				pkg (subPackage("generator")) [
					file (TransformerTmpl)
				]
				pkg ("internal") [
					file (InternalPackageTmpl)
				]				
				srcFolder = it
			]
			
			folder ("src-gen")   [/* empty source folder */]
			folder ("xtend-gen") [/* empty source folder */]
			folder ("model-gen") [/* empty source folder */]
			
			natures = #[
				"org.eclipse.xtext.ui.shared.xtextNature"
			]
			
			binIncludes = #[
				"plugin.xml",
				"plugin.properties"
			]
			
			requiredBundles = #[
				model.projectName,
				"de.jabc.cinco.meta.core.utils",
				"de.jabc.cinco.meta.plugin.gratext.runtime",
				"org.eclipse.emf.transaction",
				"org.eclipse.emf.mwe2.launch",
				"org.eclipse.xtext.ide",
				"org.eclipse.xtext.xbase.ide"
			]
			project = it
		]
	}
	
	override createProject() {
		super.createProject => [
			PROJECT_REGISTRY.add(this)
			new GratextModelBuild(it).runAndWait
		]
	}
	
	def proceed() {
		srcFolder => [
			pkg [
				files = #[
					GrammarTmpl,
					RuntimeModuleTmpl,
					AstFactoryTmpl,
					LinkingServiceTmpl
				]
				file (new MweWorkflowTmpl(projectName, basePackage))
			]
			pkg (subPackage("scoping")) [
				file (QualifiedNameProviderTmpl)
				file (ScopeProviderTmpl)
			]
			pkg (subPackage("formatting")) [
				file (FormatterTmpl)
			]
			create // create this folder, i.e. packages and files defined above
		]
		project => [
			additionalBundles = #[
				"org.eclipse.xtext.xbase",
				"org.eclipse.xtext.common.types",
				"org.eclipse.xtext.xtext.generator",
				"org.eclipse.emf.mwe.utils",
				"org.eclipse.emf.mwe2.launch",
				"org.eclipse.emf.mwe2.lib",
				"org.objectweb.asm",
				"org.apache.commons.logging",
				"org.apache.log4j",
				"com.ibm.icu"
			]
			buildProperties.create
		]
	}
	
	def getMglModel() {
		model
	}
}
