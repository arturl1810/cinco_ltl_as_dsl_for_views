package de.jabc.cinco.meta.plugin.dsl

import de.jabc.cinco.meta.plugin.template.FileTemplate
import org.eclipse.core.resources.IFile

class ProjectDescriptionLanguage {
	
	def <T extends FileContainerDescription<?>> file(T container, Class<? extends FileTemplate> template) {
		container => [ add(new FileDescription(template)) ]
	}
	
	def <T extends FileContainerDescription<?>> file(T container, Class<? extends FileTemplate> template, (IFile)=>void postProcessing) {
		container => [ 
			add(new FileDescription(template) => [
				it.postProcessing = postProcessing
			])
		]
	}
	
	def <T extends FileContainerDescription<?>> file(T container, FileTemplate template) {
		container => [ add(new FileDescription(template)) ]
	}
	
	def <T extends FileContainerDescription<?>> file(T container, Pair<Class<? extends FileTemplate>, String> template) {
		container => [ add(new FileDescription(template.value, template.key)) ]
	}
	
	def <T extends FileContainerDescription<?>> setFiles(T container, Class<? extends FileTemplate>[] templates) {
		container => [ templates.map[new FileDescription(it)].forEach[container.add(it)] ]
	}
	
	def <T extends FileContainerDescription<?>> setFiles(T container, Pair<Class<? extends FileTemplate>, String>[] templates) {
		container => [ templates.map[new FileDescription(value, key)].forEach[container.add(it)] ]
	}
	
	def <T extends FileContainerDescription<?>> folder(T container, String name, (FolderDescription)=>FolderDescription... struct) {
		container => [
			add(new FolderDescription(name) => [ 
				struct.forEach[f | f.apply(it)]
			])
		]
	}
	
	def pkg(FolderDescription folder, String name, (PackageDescription)=>PackageDescription... struct) {
		folder => [ 
			packages.add(new PackageDescription(name) => [
				struct.forEach[f | f.apply(it)]
			])
		]
	}
	
	/**
	 * Language construct to define a new project and its inherent structure.
	 * <p>Example usage:
	 * <p><pre>
	 *   project ("fully.qualified.project.name") [ ... ]
	 * </pre></p>
	 * </p>
	 * 
	 * @param name  The name of the project. Typically, only a suffix is provided that
	 *   is used by the generator to create a fully qualified project name following the
	 *   convention 'model.package + projectSuffix'. To do so, use the method 'suffix'
	 *   instead of providing the full name. As an example, for a Cinco product project
	 *   named {@code info.scce.cinco.product.somegraph} the following declaration 
	 *   <p>{@code project (suffix("plugin.name")) [ ... ]}</p>
	 *   would lead to the name {@code info.scce.cinco.product.somegraph.plugin.name}
	 *   for the generated project.
	 * @param struct  The nested language block that defines the inherent project structure.
	 */
	def project(String name, (ProjectDescription)=>ProjectDescription struct) {
		struct.apply(new ProjectDescription(name))
	}
	
	def setBinIncludes(ProjectDescription projDesc, String[] names) {
		projDesc => [ buildProperties.binIncludes => [clear addAll(names)] ]
	}
	
	def setExportedPackages(ProjectDescription projDesc, String[] names) {
		projDesc => [ manifest.exportedPackages => [clear addAll(names)] ]
	}
	
	def setImportedPackages(ProjectDescription projDesc, String[] names) {
		projDesc => [ manifest.importedPackages => [clear addAll(names)] ]
	}

	def setRequiredBundles(ProjectDescription projDesc, String[] names) {
		projDesc => [ manifest.requiredBundles => [clear addAll(names)] ]
	}
	
	def setLazyActivation(ProjectDescription projDesc, boolean flag) {
		projDesc => [ manifest.lazyActivation = flag ]
	}
}
