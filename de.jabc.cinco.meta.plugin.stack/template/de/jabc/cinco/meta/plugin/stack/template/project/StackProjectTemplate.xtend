package de.jabc.cinco.meta.plugin.stack.template.project

import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import de.jabc.cinco.meta.plugin.stack.template.file.PostCreateTemplate
import de.jabc.cinco.meta.plugin.stack.template.file.PostMoveTemplate
import de.jabc.cinco.meta.plugin.stack.Constants

class StackProjectTemplate extends ProjectTemplate{
	override projectSuffix() {
		Constants.PROJECT_SUFFIX
	}
	override projectDescription() {
		project(projectName)[
			folder("src")[
				pkg(basePackage + Constants.HOOK_PACKAGE_SUFFIX)[
					forEachOf(stackableNodes)[n|
						files = #[
							new PostCreateTemplate(n),
							new PostMoveTemplate(n)
						]
					]
				]
			]
			requiredBundles = #[
				model.projectSymbolicName,
				"de.jabc.cinco.meta.runtime",
				"org.eclipse.graphiti.mm"
			]
		]
	}
	
	def getStackableNodes() {
		model.nodes.filter[hasAnnotation(Constants.PROJECT_ANNOTATION)]
	}
}