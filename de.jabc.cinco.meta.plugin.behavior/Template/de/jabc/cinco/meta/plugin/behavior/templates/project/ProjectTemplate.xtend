package de.jabc.cinco.meta.plugin.behavior.templates.project

import de.jabc.cinco.meta.plugin.behavior.Constants
import de.jabc.cinco.meta.plugin.behavior.templates.file.PostCreateTemplate
import de.jabc.cinco.meta.plugin.behavior.templates.file.PostMoveTemplate
import mgl.ContainingElement
import mgl.Node

class ProjectTemplate extends de.jabc.cinco.meta.plugin.template.ProjectTemplate {
	
	override projectSuffix() {
		Constants.PROJECT_SUFFIX
	}
	
	override projectDescription() {
		project(projectName)[
			folder("src")[
				pkg(basePackage + Constants.HOOK_PACKAGE_SUFFIX)[
					forEachOf(relevantNodes)[n|
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
				"de.jabc.cinco.meta.plugin.behavior.runtime",
				"org.eclipse.graphiti.mm"
			]
		]
	}
	
	def Iterable<Node> relevantNodes() {
		model.getAllNodesWithAnnotation(Constants.PROJECT_ANNOTATION)
			.filter(ContainingElement)
			.flatMap[containableNodes]
	}
	
}
