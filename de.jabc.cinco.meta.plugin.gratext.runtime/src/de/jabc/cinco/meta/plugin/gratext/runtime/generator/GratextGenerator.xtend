package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.GraphModel
import java.io.ByteArrayInputStream
import java.io.IOException
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.transaction.RecordingCommand
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.util.TransactionUtil
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.jface.dialogs.MessageDialog
import org.eclipse.swt.widgets.Display

abstract class GratextGenerator<T extends GraphModel> {
	
	private static IProgressMonitor monitor
	
	protected IProject project
	protected T model
	protected Diagram diagram
	private IFile target
	
	def doGenerate(IFile file, String outFolderName) {
		println("[Gratext] File: " + file.getProjectRelativePath());
		val fileUri = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
		val resource = new ResourceSetImpl().getResource(fileUri, true);
		init(file, resource)
		val outFolder = [
			createFolder(new Path(outFolderName))
		].onException[ warn(message) ]
		target = createFile(new Path(fileName(file)), outFolder, template.toString)
	}
	
	def doGenerate(Resource res) {
		init(res)
		val stream = new ByteArrayInputStream(toText(res).getBytes(target.charset))
		target.setContents(stream, true, true, getMonitor)
	}
		
	def toText(Resource res) {
		init(res)
		template.toString
	}
	
	def init(IFile file, Resource res) {
		project = file.project
		init(res)
	}
	
	def init(Resource res) {
		try {
			diagram = res.contents.get(0) as Diagram
			model = res.contents.get(1) as T
		} catch(Exception e) {
			res.contents.forEach[
				switch it {
					Diagram: diagram = it
					GraphModel: model = it as T
				}
			]
		}
		if (diagram == null)
			MessageDialog.openError(Display.current.activeShell, 
					"Error", "No diagram found in resource: " + res)
		else if (model == null)
			MessageDialog.openError(Display.current.activeShell, 
					"Error", "No model found in resource: " + res)
	}
	
	def CharSequence template()
	
	def String fileName(IFile sourceFile)
	
	def createFolder(IPath folderPath) {
		createFolder(folderPath, project)
	}
	
	def createResource(IPath path, IPath filePath) {
		val uri = URI.createPlatformResourceURI(path.append(filePath).toOSString(), true)
		return new ResourceSetImpl().createResource(uri)
	}
	
//	def warn(String msg) {
//		System.out.println("[" + class.simpleName + "] WARN: " + msg);
//	}
	
	static def warn(Exception e) {
		System.out.println("WARN: " + e.class.simpleName + " " + e.message);
	}
	
	static def warn(String msg) {
		System.out.println("WARN: " + /* class.simpleName + " " + */ msg);
	}
	
	static def IProgressMonitor getMonitor() {
		monitor ?: new NullProgressMonitor
	}
	
	static def IFile createFile(IPath name, IContainer container, String content) throws CoreException {
		createFile(name, container, content, getMonitor)
	}
	
	static synchronized def IFile createFile(IPath name, IContainer container, String content, IProgressMonitor monitor) throws CoreException {
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
	
	static def createFile(IPath path, String fileName, String fileExtension) {
		val filePath = path.append(fileName).addFileExtension(fileExtension)
		val uri = URI.createPlatformResourceURI(filePath.toOSString(), true)
		new ResourceSetImpl().createResource(uri)
	}
	
	static def IContainer createFolder(IPath folderPath, IProject project) throws CoreException {
		createFolder(folderPath, project, getMonitor)
	}
	
	static def IContainer createFolder(IPath folderPath, IProject project, IProgressMonitor monitor) throws CoreException {
		if (folderPath.isEmpty) project
		else createResource(project.getFolder(folderPath), monitor)
	}
	
	static def <T extends IResource> T createResource(T resource) throws CoreException {
		createResource(resource, getMonitor)
	}
	
	static synchronized def <T extends IResource> T createResource(T resource, IProgressMonitor monitor) throws CoreException {
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
	
	static synchronized def addContent(Resource res, EObject... objs) {
		objs.forEach[res.contents.add(it)]
	}
	
	static def createDiagram(String name) {
		createDiagram(name, name)
	}
	
	static def createDiagram(String name, String filename) {
		Graphiti.getPeCreateService().createDiagram(name, filename, true)
	}
	
	static def createFeatureProvider(Diagram diagram) {
		GraphitiUi.getExtensionManager.createFeatureProvider(diagram)
	}
	
	static def <T extends EObject> T edit(T obj, Runnable runnable) {
		val domain = [
			TransactionUtil.getEditingDomain(obj)
				?: TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(obj.eResource.resourceSet)
		].printException
		domain?.execute(runnable)
		return obj
	}
	
	static def Resource edit(Resource res, Runnable runnable) {
		var domain = [
			TransactionUtil.getEditingDomain(res)
				?: TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(res.resourceSet)
		].printException
		domain?.execute(runnable)
		return res
	}
	
	static def execute(TransactionalEditingDomain domain, Runnable runnable) {
		
		var Integer x = null;
		try {
			x = Integer.parseInt("fourtytwo");
		} catch(NumberFormatException e) {
			e.printStackTrace();
			x = 42;
		}
		
		val y = try {
			Integer.parseInt("fourtytwo")
		} catch(NumberFormatException e) {
			e.printStackTrace
			42
		}
		
		
		
		
		domain.getCommandStack().execute(new RecordingCommand(domain) {
			override doExecute() {
				[ runnable.run ].onException[ warn ]
			}
		})
	}
	
	def static void main(String[] args) {
		val x1 = null ?: 42
		println("x1 = " + x1)
		
		val x2 = [ return null as Integer ] ?: 42
		println("x2 = " + x2)
		
		val x3 = [ Integer.parseInt("fourtytwo") ] ?: 42
		println("x3 = " + x3)
		
		val str = "fourtytwo"
		val dft = 42
		val x4 = [
			Integer.parseInt(str)
		].onException[
			warn("Failed to parse '" + str + "'. Switching to default: " + dft)
		] ?: dft
		println("x4 = " + x4)
		
		val x5 = [ Integer.parseInt("fourtytwo") ].ignoreException ?: 42
		println("x5 = " + x5)
		
		val func = [ String s | Integer.parseInt(s) ] // defines function  (String) => int
		val x6 = [ func.apply("fourtytwo") ] ?: 42 
		println("x6 = " + x6)
	}
	
	static def <T> ?: ((Object) => T proc, T defaultVal) {
		proc?.onException[
			System.out.println("WARN: " + class.simpleName + " " + message + ". Defaulting to: " + defaultVal)
		] ?: defaultVal
	}
	
	static def <T> mapException((Object) => T proc, (Exception) => Class<? extends Exception> excls) {
		try {
			proc.apply(null)
		} catch (Exception e) {
			throw [
				excls.apply(e).getConstructor(Throwable)?.newInstance(e)
			].onException[
				excls.apply(e).newInstance
			]
		}
	}
	
	static def mapException((Object) => void proc, (Exception) => Class<? extends Exception> excls) {
		try {
			proc.apply(null)
		} catch (Exception e) {
			throw [
				excls.apply(e).getConstructor(Throwable)?.newInstance(e)
			].onException[
				excls.apply(e).newInstance
			]
		}
	}
	
	static def <T> onFail((Object) => T proc, T dflt) {
		try {
			proc.apply(null)
		} catch (Exception e) {
			dflt
		}
	}
	
	static def <T> onException((Object) => T proc, (Exception) => void handler) {
		try {
			proc.apply(null)
		} catch (Exception e) {
			handler.apply(e)
		}
	}
	
	static def onException((Object) => void proc, (Exception) => void handler) {
		try {
			proc.apply(null)
		} catch (Exception e) {
			handler.apply(e)
		}
	}
	
	static def <T> printException((Object) => T proc) {
		proc.onException[printStackTrace]
	}
	
	static def printException((Object) => void proc) {
		proc.onException[printStackTrace]
	}
	
	static def <T> ignoreException((Object) => T proc) {
		proc.onException[]
	}
	
	static def ignoreException((Object) => void proc) {
		proc.onException[]
	}
}
