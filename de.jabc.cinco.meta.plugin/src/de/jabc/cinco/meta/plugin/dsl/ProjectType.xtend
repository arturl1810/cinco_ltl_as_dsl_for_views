package de.jabc.cinco.meta.plugin.dsl

import java.util.Set
import org.eclipse.core.runtime.Path
import org.eclipse.jdt.core.IClasspathEntry
import org.eclipse.jdt.core.JavaCore
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.core.resources.ResourcesPlugin

class ProjectType {
	
	@Accessors val Set<String> natures = newLinkedHashSet
	@Accessors val Set<IClasspathEntry> classpath = newLinkedHashSet
	@Accessors boolean manifestRequired = false
	@Accessors boolean buildPropertiesRequired = false
	
	
	public static val JAVA = new ProjectType => [
		natures += #[
			JavaCore.NATURE_ID
		]
		
		classpath += #[
			"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8"
		].map[JavaCore.newContainerEntry(new Path(it))]
	]
	
	public static val PLUGIN = new ProjectType => [
		natures += #[
			JavaCore.NATURE_ID,
			"org.eclipse.pde.PluginNature"
		]
		
		classpath += #[
			"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8",
			"org.eclipse.pde.core.requiredPlugins"
		].map[JavaCore.newContainerEntry(new Path(it))]
		
		manifestRequired = true
		buildPropertiesRequired = true
	]
	
	public static val FEATURE = new ProjectType => [
		natures += #[
			JavaCore.NATURE_ID,
			"org.eclipse.pde.PluginNature"
		]
		
		classpath += #[
			"org.eclipse.jdt.launching.JRE_CONTAINER/org.eclipse.jdt.internal.debug.ui.launcher.StandardVMType/JavaSE-1.8",
			"org.eclipse.pde.core.requiredPlugins"
		].map[JavaCore.newContainerEntry(new Path(it))]
		
		manifestRequired = true
		buildPropertiesRequired = true
	]
	
	
	def initProject(ProjectDescription project) {
		val iProject = project.IResource
		iProject.setDescription(project.IProjectDescription, project.monitor)
		if (!classpath.isEmpty) JavaCore.create(iProject) => [
			setRawClasspath(
				classpath
				+ project.IProjectDescription.referencedProjects
					.map[JavaCore.newProjectEntry(fullPath)]
				+ project.sourceFolders
					.map[project.toProjectFolder(name)]
					.map[JavaCore.newSourceEntry(fullPath)]
			, project.monitor)
			setOutputLocation(new Path("/" + project.name + "/bin"), project.monitor)
		]
	}
	
	protected def getIProjectDescription(ProjectDescription project) {
		val workspace = ResourcesPlugin.workspace
		workspace.newProjectDescription(project.name) => [
			buildSpec = #[
				newCommand => [ builderName = JavaCore.BUILDER_ID ],
				newCommand => [ builderName = "org.eclipse.pde.ManifestBuilder" ],
				newCommand => [ builderName = "org.eclipse.pde.SchemaBuilder" ]
			]
			natureIds = natures + project.natures.toList.reverse
			referencedProjects = project.referencedProjects.map[workspace.root.getProject(project.name)]
		]
	}
	
	protected def toProjectFolder(ProjectDescription project, String name) {
		project.IResource.getFolder(name) => [if (!exists) create(false, true, project.monitor)]
	}
}
