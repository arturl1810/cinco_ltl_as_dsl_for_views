package de.jabc.cinco.meta.core.referenceregistry

import java.util.List
import java.util.Map
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicLong
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
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
	
	static val showDebug = true
	
	val ReferenceRegistry registry
	ExecutorService threadPool
	val minions = ConcurrentHashMap.<Thread>newKeySet
	val loadTime = new AtomicLong(0)
	val readTime = new AtomicLong(0)
	
	new(ReferenceRegistry registry) {
		super("Update references")
		this.registry = registry
		debug("created")
	}
	
	override protected run(IProgressMonitor monitor) {
		debug("run")
		return workWithMinions(false)
	}
	
	def protected workAndWait() {
		debug("work and wait")
		workWithMinions(true)
		registry.crawler = null
		return Status.OK_STATUS
	}
	
	def protected workWithMinions(boolean keepBusy) {
		val debugTime = System.currentTimeMillis
		val numProcessors = Runtime.runtime.availableProcessors
		debug("work with minions, uriQueue.size: " + registry.uriQueue.size + ", available processors: " + numProcessors)
		if (numProcessors > 1) {
			val numMinions = Math.min(registry.uriQueue.size, numProcessors) - 1
			debug("submit " + numMinions + " minions")
			threadPool = Executors.newFixedThreadPool(numProcessors)
			for (i : 0..< numMinions) {
				submitNewMinion
			}
		}
		
		debug("starting to work myself")
		workForRequest(null, keepBusy)
		
		debug("stop, return OK, runTime: " + (System.currentTimeMillis - debugTime) + " loadTime: " + loadTime.get + " extractTime: " + readTime.get)
		registry.crawler = null
		return Status.OK_STATUS
	}
	
	def void submitNewMinion() {
		threadPool.submit[
			notifyStart
			work
			notifyDone
			return true
		]
	}
	
	def notifyStart() {
		minions.add(Thread.currentThread)
	}
	
	def notifyDone() {
		minions.remove(Thread.currentThread)
	}
	
	def isWorkingMinion() {
		minions.contains(Thread.currentThread)
	}
	
	def work() {
		workForRequest(null, false)
	}
	
	def workForRequest(Request<?,?> request) {
		workForRequest(null, true)
	}
	
	def workForRequest(Request<?,?> request, boolean keepBusy) {
		var uri = registry.uriQueue.poll ?: if (keepBusy) pollProcessedURI
		while (uri !== null) {
			work(uri)
			uri = registry.uriQueue.poll ?: if (keepBusy) pollProcessedURI
			if (request?.isProvided) {
				return
			}
		}
		if (registry.inProcess.isEmpty) {
			debug("DONE keys: " + registry.key_on_obj.size + " URIs: " + registry.resURI_on_keys.size)
			declineRemainingRequests
		} else {
			debug("no work left for me, but still " + registry.inProcess.size + " URIs in process")
			if (isWorkingMinion) {
				debug("i am minion")
			} else {
				debug("i am NOT minion; working minions: " + minions.size)
				if (minions.isEmpty) {
					if (!threadPool.isShutdown) {
						debug("shutdown thread pool")
						threadPool.shutdown()
					}
					debug("await termination")
					threadPool.awaitTermination(Long.MAX_VALUE, TimeUnit.NANOSECONDS)
					debug("thread pool terminated")
				}
			}
		}
		return
	}
	
	def pollProcessedURI() {
		for (uri : registry.inProcess.keySet) {
			if (!registry.inProcess.get(uri)?.contains(Thread.currentThread)) {
				return uri
			}
		}
		if (!registry.inProcess.isEmpty) {
			debug("declined to work for the same URI twice: " + registry.inProcess.keySet.head)
		}
		return null
	}
	
	protected def work(URI uri) {
		if (uri !== null) try {
			
			val threads = registry.inProcess.get(uri)
			if (threads === null) {
				registry.inProcess.put(uri, newHashSet)
			}
			registry.inProcess.get(uri).add(Thread.currentThread)
			
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
			
		} catch(Exception e) {
			e.printStackTrace
			
		} finally {
			registry.inProcess.remove(uri)
		}
	}
	
	protected def declineRemainingRequests() {
		registry.keyRequests.values.flatten.forEach[decline]
		registry.uriRequests.values.flatten.forEach[decline]
	}
	
	protected def collectFiles() {
		registry.uriQueue.clear
		for (IFile f : workspaceFiles.sortBy[fileSize].reverse) {
			val uri = URI.createPlatformResourceURI(f.fullPath.toString, true)
			registry.uriQueue.add(uri)
		}
	}
	
	static def getWorkspaceFiles() {
		val files = newArrayList
		collectFiles(ResourcesPlugin.workspace.root, files)
		return files
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
	
	def getFileSize(IFile file) {
		file.rawLocation?.toFile?.length
	}
	
	def Map<String, EObject> extractIds(Resource res) {
		newHashMap => [
			res?.extractIds(it)
		]
	}
	
	def Map<String, EObject> extractIds(URI uri) {
		newHashMap => [
			val tLoad = System.currentTimeMillis
			val res = uri.loadResource
			loadTime.addAndGet(System.currentTimeMillis - tLoad)
			val tRead = System.currentTimeMillis
			res?.extractIds(it)
			readTime.addAndGet(System.currentTimeMillis - tRead)
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
		val maxAttempts = 5
		for (i : 1..maxAttempts) try {
			return new ResourceSetImpl().getResource(uri, true)
		} catch (Throwable e) {
			e.printStackTrace
			debug('''[WorkspaceCrawler] Attempt «i» of «maxAttempts» failed to load resource for URI «uri»''')
		}
	}
	
	def debug(String message) {
		if (showDebug) println(
			"[WorkspaceCrawler-" + hashCode
			+ " Thread-" + Thread.currentThread.hashCode + "] "
			+ message
		)
	}
}