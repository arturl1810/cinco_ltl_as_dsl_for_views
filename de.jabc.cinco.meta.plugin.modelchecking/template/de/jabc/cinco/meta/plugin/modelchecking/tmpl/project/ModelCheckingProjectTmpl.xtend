package de.jabc.cinco.meta.plugin.modelchecking.tmpl.project

import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder.ModelBuilderTmpl
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.formulas.FormulaFactoryTmpl
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.formulas.FormulaHandlerTmpl
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.file.ActivatorTmpl
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.file.ModelCheckingAdapterTmpl
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.file.PluginXmlTmpl

class ModelCheckingProjectTmpl extends ProjectTemplate{
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	override projectDescription() {
		project [
			folder ("src-gen") [
				pkg [
					file (ActivatorTmpl)
					file (ModelCheckingAdapterTmpl)
				]
				pkg (subPackage("builder")) [
					file (ModelBuilderTmpl)
				]
				if (model.formulasExist){
					pkg (subPackage("formulas")) [
					
						file(FormulaFactoryTmpl)
						file(FormulaHandlerTmpl)
						
					]
				}
			]
			folder ("xtend-gen") [/* empty source folder */]
			
			natures = #[
				"org.eclipse.xtext.ui.shared.xtextNature"
			]
			
			file (PluginXmlTmpl)
			
			activator = '''«basePackage».Activator'''
			lazyActivation = true
			binIncludes = #[
				"plugin.xml"
			]
			requiredBundles = #[
				model.projectSymbolicName,
				"org.eclipse.core.runtime",
				"org.eclipse.jface",
				"org.eclipse.ui",
				"de.jabc.cinco.meta.plugin.modelchecking.runtime",
				"de.jabc.cinco.meta.runtime;bundle-version=\"1.0.0\"",
				"de.jabc.cinco.meta.core.utils",
				"org.eclipse.graphiti;bundle-version=\"0.15.0\""
			]			
		]
	}
	
	override projectSuffix() {
		'''modelchecking'''
	}
	
	
	
}
