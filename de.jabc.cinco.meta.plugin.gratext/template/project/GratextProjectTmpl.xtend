package project

import de.jabc.cinco.meta.plugin.dsl.FolderDescription
import de.jabc.cinco.meta.plugin.gratext.build.GratextModelBuild
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import file.EcoreTmpl
import file.FormatterTmpl
import file.GenmodelTmpl
import file.GrammarTmpl
import file.InternalPackageTmpl
import file.MweWorkflowTmpl
import file.QualifiedNameProviderTmpl
import file.ResourceTmpl
import file.RuntimeModuleTmpl
import file.ScopeProviderTmpl
import file.TransformerTmpl
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.Path

import static de.jabc.cinco.meta.core.utils.EclipseFileUtils.copyFromBundleToFile
import static de.jabc.cinco.meta.plugin.gratext.GratextBuilder.PROJECT_REGISTRY

class GratextProjectTmpl extends ProjectTemplate {
	
	FolderDescription srcFolder
	
	override projectSuffix() { "gratext" }
	
	override projectDescription() {
		
		project (projectName) [
			
			folder ("model") [
				isSourceFolder = false
				pkg (basePackage) [
					files = #[
						EcoreTmpl,
						GenmodelTmpl
					]
				]
			]
			folder ("src") [
				pkg (basePackage) [
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
			
			// some empty source folders required
			folder ("src-gen")
			folder ("xtend-gen")
			folder ("model-gen")
			
			natures = #[
				"org.eclipse.xtext.ui.shared.xtextNature"
			]
			
			binIncludes = #[
				"plugin.xml",
				"plugin.properties"
			]
			
			requiredBundles = #[
				model.projectName,
				"org.eclipse.ui",
				"org.eclipse.ui.navigator",
				"org.eclipse.swt",
				"org.eclipse.core.runtime",
				"org.eclipse.core.resources",
				"org.eclipse.emf.common",
				"org.eclipse.emf.ecore",
				"org.eclipse.emf.codegen.ecore",
				"org.eclipse.emf.transaction",
				"org.eclipse.emf.mwe.utils",
				"org.eclipse.emf.mwe2.launch",
				"org.eclipse.xtext",
				"org.eclipse.xtext.generator",
				"org.eclipse.xtext.util",
				"org.eclipse.xtext.xbase",
				"org.eclipse.xtext.xbase.lib",
				"org.eclipse.xtext.common.types",
				"org.antlr.runtime",
				"org.apache.commons.logging",
				"de.jabc.cinco.meta.core.mgl.model",
				"de.jabc.cinco.meta.core.ui",
				"de.jabc.cinco.meta.core.utils",
				"de.jabc.cinco.meta.plugin.gratext.runtime"
			]
		]
	}
	
	override createProject() {
		super.createProject => [
			PROJECT_REGISTRY.add(this)
			new GratextModelBuild(it).runAndWait
			assertAntlrPatch
		]
	}
	
	def proceed() {
		srcFolder => [
			pkg (basePackage) [
				files = #[
					GrammarTmpl,
					RuntimeModuleTmpl
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
	}
	
	def getMglModel() {
		model
	}
	
	private def assertAntlrPatch(IProject project) {
		val file = project.getFile(new Path(".antlr-generator-3.2.0-patch.jar"));
		if (!file.exists) copyFromBundleToFile(
			"de.jabc.cinco.meta.libraries",
			"lib_local/antlr-generator-3.2.0-patch.jar",
			file
		);
	}
}