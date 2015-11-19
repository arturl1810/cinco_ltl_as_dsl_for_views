package de.jabc.cinco.meta.plugin.gratext.template

class GratextGeneratorTemplate extends AbstractGratextTemplate {
		
override template()
'''	
package «project.basePackage».generator

import graphmodel.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.resources.IContainer
import org.eclipse.core.runtime.CoreException
import java.io.ByteArrayInputStream
import java.io.IOException
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IResource

abstract class GratextGenerator<T extends GraphModel> {
	
	protected IProject project
	protected T model
	protected Diagram diagram
	private IFile target
	
	def doGenerate(IFile file, String outFolder) {
		val fileUri = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
		System.out.println("File: " + file.getName() + " in path " + file.getProjectRelativePath());
		val res = new ResourceSetImpl().getResource(fileUri, true);
		
		init(file, res)
		
		target = createFile(new Path(fileName(file)),
			folder(new Path(outFolder)), template.toString
		)
	}
	
	def init(IFile file, Resource res) {
		project = file.project
		try {
			diagram = res.contents.get(0) as Diagram
			model = res.contents.get(1) as T
		} catch(Exception e) {
			res.contents.forEach[content |
				if (content instanceof Diagram)
					diagram = content as Diagram
				else if (content instanceof GraphModel)
					model = content as T;
			]
		}
		if (diagram == null)
			MessageDialog.openError(Display.current.activeShell, 
					"Error", "No diagram found in file: " + file.name)
		else if (model == null)
			MessageDialog.openError(Display.current.activeShell, 
					"Error", "No model of type 'Data' found in file: " + file.name)
	}
	
	def CharSequence template()
	
	def String fileName(IFile sourceFile)
	
	def folder(IPath folderPath) {
		createFolder(folderPath, project)
	}
	
	def createResource(IPath path, IPath filePath) {
		val uri = URI.createPlatformResourceURI(path.append(filePath).toOSString(), true)
		return new ResourceSetImpl().createResource(uri)
	}
	
	private static  IProgressMonitor monitor
	
	static def IProgressMonitor getMonitor() {
		monitor ?: new NullProgressMonitor
	}
	
	static def IFile createFile(IPath name, IContainer container, String content) throws CoreException {
		createFile(name, container, content, getMonitor)
	}
	
	static def IFile createFile(IPath name, IContainer container, String content, IProgressMonitor monitor) throws CoreException {
		val file = container.getFile(name)
		try {
			val stream = new ByteArrayInputStream(content.getBytes(file.charset))
			if (file.exists) file.setContents(stream, true, true, monitor)
			else file.create(stream, true, monitor)
			stream.close
		} catch(IOException e) {
			e.printStackTrace
		}
		return file
	}
	
	static def IFolder createFolder(IPath folderPath, IProject project) throws CoreException {
		createFolder(folderPath, project, getMonitor)
	}
	
	static def IFolder createFolder(IPath folderPath, IProject project, IProgressMonitor monitor) throws CoreException {
		return createResource(project.getFolder(folderPath), monitor)
	}
	
	static def <T extends IResource> T createResource(T resource) throws CoreException {
		createResource(resource, getMonitor)
	}
	
	static def <T extends IResource> T createResource(T resource, IProgressMonitor monitor) throws CoreException {
		if (resource == null || resource.exists)
			return resource
		if (!resource.parent.exists)
			createResource(resource.parent, monitor);
		switch resource {
			IFile: 		resource.create(new ByteArrayInputStream(newByteArrayOfSize(0)), true, monitor)
			IFolder: 	resource.create(IResource.NONE, true, monitor)
			IProject: { resource.create(monitor) resource.open(monitor) }
		}
		return resource
	}
	
}
'''
}