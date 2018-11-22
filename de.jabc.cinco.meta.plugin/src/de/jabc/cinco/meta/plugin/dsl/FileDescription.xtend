package de.jabc.cinco.meta.plugin.dsl

import de.jabc.cinco.meta.plugin.template.FileTemplate
import java.util.function.Consumer
import org.eclipse.core.resources.IFile
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.core.runtime.Path

class FileDescription extends ProjectResourceDescription<IFile> {
	
	@Accessors CharSequence content
	@Accessors Class<? extends FileTemplate> templateClass
	@Accessors Consumer<IFile> postProcessing
	@Accessors FileTemplate template
	@Accessors boolean overwrite = true
	
	new(String name) { super(name) }
	
	new(Class<? extends FileTemplate> templateClass) {
		this(templateClass.simpleName, templateClass)
	}
	
	new(FileTemplate template) {
		this(template.class)
		this.template = template
	}
	
	new(String name, Class<? extends FileTemplate> templateClass) {
		super(name)
		this.templateClass = templateClass
	}
	
	new(String name, FileTemplate template) {
		this(name, template.class)
		this.template = template
	}
	
	new(String name, CharSequence content) {
		super(name)
		this.content = content
	}
	
	override IFile create() {
		val content = getContent
		if (content !== null)
			return createFile(name, content)
		
		var template = getTemplate
		if (template === null)
			template = (this.template = templateClass?.newInstance)
		if (template !== null) template => [
			it.cpd = this.cpd
			it.model = this.model
			it.parent = this.parent
			it.project = this.project
			createFile(targetFileName, it.content)
		]
		
		if (IResource === null)
			warn("Nothing to create: content is null and no template provided")
		return IResource
	}
	
	protected def createFile(String fileName, CharSequence content) {
		if (overwrite || !parent.IResource.getFile(new Path(fileName))?.exists) {
			val file = parent.IResource.createFile(fileName, content)
			IResource = file
			postProcessing?.accept(file)
		}
		return IResource
	}
}
