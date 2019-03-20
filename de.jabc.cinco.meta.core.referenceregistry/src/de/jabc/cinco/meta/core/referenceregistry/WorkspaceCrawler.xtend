package de.jabc.cinco.meta.core.referenceregistry

import java.util.List
import java.util.Map
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Status
import org.eclipse.core.runtime.jobs.Job
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.mm.pictograms.Diagram

import static extension de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry.isBlacklisted
import static extension de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry.isWhitelisted

class WorkspaceCrawler extends Job {
	
	val ReferenceRegistry registry
	public var Thread thread
	
	new(ReferenceRegistry registry) {
		super("Update references")
		this.registry = registry
	}
	
	protected def init() {
		registry.uriQueue.clear
		val files = newArrayList
		collectFiles(ResourcesPlugin.workspace.root, files);
		for (IFile f : files) {
			val uri = URI.createPlatformResourceURI(f.fullPath.toString, true)
			registry.uriQueue.add(uri)
		}
	}
	
	def protected run() {
		run(new NullProgressMonitor)
	}
	
	override protected run(IProgressMonitor monitor) {
		thread = Thread.currentThread
		var uri = registry.uriQueue.poll
		while (uri !== null) {
			val map = uri.extractIds
			for (String id : map.keySet.filterNull) {
				val obj = map.get(id)
				registry.register(id, uri, obj)
				if (registry.keyRequests.containsKey(id)) {
					registry.keyRequests.remove(id).forEach[provide(obj)]
				}
			}
			if (registry.uriRequests.containsKey(uri)) {
				registry.uriRequests.remove(uri).forEach[provide(map)]
			}
			uri = registry.uriQueue.poll
		}
		// queue is now empty, decline unfulfilled requests
		registry.keyRequests.values.flatten.forEach[decline]
		registry.uriRequests.values.flatten.forEach[decline]
		
		registry.crawler = null
		return Status.OK_STATUS
	}
	
	static def void collectFiles(IContainer container, List<IFile> fileList) {
		if (container instanceof IContainer
				&& !container.isBlacklisted
				&& container.isAccessible) {
			
			var IResource[] members = null
			try {
				members = container.members
			} catch (CoreException e) {
				e.printStackTrace();
			}
			members?.forEach[ switch it {
				IFile case isWhitelisted: fileList.add(it)
				IContainer: collectFiles(fileList)
			}]
		}
	}
	
	def Map<String, EObject> extractIds(URI uri) {
		newHashMap => [
			uri.loadResource?.extractIds(it)
		]
	}
	
	def void extractIds(Resource res, Map<String,EObject> objectsById) {
		res.contents.forEach[
			extractIds_rec(objectsById)
		]
	}
	
	def void extractIds_rec(EObject obj, Map<String,EObject> objectsById /*, List<String> referenced */) {
		if (obj instanceof EObject && !(obj instanceof Diagram)) {
			val eobj = obj as EObject;
			val id = registry.getID(eobj)
			if (!id?.isEmpty) {
				objectsById.put(id, eobj)
			}
//			val libCompFeature =
//					eobj.eClass.getEStructuralFeature("libraryComponentUID")
//			if (libCompFeature !== null) {
//				val libCompUID = eobj.eGet(libCompFeature)
//				if (libCompUID !== null) {
//					referenced.add(libCompUID as String)
//				}
//			}
			EcoreUtil.getAllContents(eobj, true).forEachRemaining[
				extractIds_rec(objectsById /*, referenced */)
			]
		}
	}
	
	def loadResource(URI uri) {
		try {
			new ResourceSetImpl().getResource(uri, true)
		} catch (Exception e) {
			println('''[WorkspaceCrawler] Failed to load resource for URI «uri»''')
			return null
		}
	}
}