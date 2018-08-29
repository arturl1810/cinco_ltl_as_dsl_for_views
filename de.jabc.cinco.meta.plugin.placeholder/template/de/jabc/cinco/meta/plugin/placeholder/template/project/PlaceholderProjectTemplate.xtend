package de.jabc.cinco.meta.plugin.placeholder.template.project

import de.jabc.cinco.meta.plugin.placeholder.Constants
import de.jabc.cinco.meta.plugin.placeholder.template.file.PostCreateTemplate
import de.jabc.cinco.meta.plugin.placeholder.template.file.PostMoveTemplate
import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import mgl.Node

class PlaceholderProjectTemplate extends ProjectTemplate {
	
	override projectSuffix() {
		Constants.PROJECT_SUFFIX
	}
	
	override projectDescription() {
		project(projectName)[
			folder("src")[
				pkg(basePackage + Constants.HOOK_PACKAGE_SUFFIX)[
					forEachOf(placeholdedNodes)[n|
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
	/**
	 * Gets all Nodes that have a Placeholder.
	 */
	def  Iterable<Node> getPlaceholdedNodes() {
		model.getAllAnnotationValues(Constants.PROJECT_ANNOTATION)
			.map[str|model.getModelElement(str)].filter(Node)
	}
	
	
}