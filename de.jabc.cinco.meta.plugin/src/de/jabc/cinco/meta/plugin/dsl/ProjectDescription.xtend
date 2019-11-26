package de.jabc.cinco.meta.plugin.dsl

import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import java.util.Set
import org.eclipse.core.resources.IProject
import org.eclipse.xtend.lib.annotations.Accessors

import static de.jabc.cinco.meta.plugin.dsl.ProjectType.*

class ProjectDescription extends FileContainerDescription<IProject> {

	@Accessors ProjectTemplate template
	@Accessors ProjectType type = PLUGIN
	@Accessors BuildPropertiesDescription buildProperties = new BuildPropertiesDescription
	@Accessors ManifestDescription manifest = new ManifestDescription
	@Accessors val Set<String> natures = newLinkedHashSet
	@Accessors val Set<String> referencedProjects = newHashSet
	
	new(String name) {
		super(name)
		deleteIfExistent = true
	}
	
	new(ProjectTemplate template, String name) {
		this(name)
		this.template = template
	}
	
	new(ProjectTemplate template) {
		this(template, template.projectName)
	}
	
	def getSourceFolders() {
		folders.filter[isSourceFolder]
	}
	
	def setNatures(String[] names) {
		this => [ natures => [clear addAll(names)] ]
	}
	
	def setReferencedProjects(String[] names) {
		this => [ referencedProjects => [clear addAll(names)] ]
	}
	
	override IProject create() {
		init
		createFiles
		createFolders
		return IResource
	}
	
	protected def init() {
		val project = workspace.root.getProject(name)
		this.IResource = project
		
		var initialize = true
		if (!project.exists)
			project.create(null, monitor)
		else if (isDeleteIfExistent) project => [
			delete(true, true, monitor)
			create(null, monitor)
		]
		else initialize = false
		
		if (!project.isOpen) project.open(monitor)
		
		if (initialize) type.initProject(this)
			
		folders.filter[isDeleteIfExistent].forEach[foldDesc|
			IResource.getFolder(foldDesc.name) => [folder|
				if (folder.exists) folder.delete(true, monitor)
			]
		]
	}
	
	override createFiles() {
		super.createFiles
		if (type.isManifestRequired)
			manifest.create(this)
		if (type.isBuildPropertiesRequired)
			buildProperties.create(this)
	}
	
	override add(FileDescription file) {
		super.add(file)
		file.setProject(this)
	}
	
	override add(FolderDescription folder) {
		super.add(folder)
		folder.setProject(this)
	}
}
