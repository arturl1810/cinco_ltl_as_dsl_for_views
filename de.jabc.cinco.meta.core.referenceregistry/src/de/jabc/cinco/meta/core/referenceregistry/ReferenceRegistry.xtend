package de.jabc.cinco.meta.core.referenceregistry

import de.jabc.cinco.meta.core.referenceregistry.implementing.IFileExtensionSupplier
import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryResourceChangeListener
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.GraphModel
import java.util.List
import java.util.Set
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.LinkedTransferQueue
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.util.EcoreUtil

class ReferenceRegistry extends CincoRuntimeBaseClass {
	
	static val EXTENSION_ID = "de.jabc.cinco.meta.core.referenceregistry"
	
	static val RESOURCE_BLACKLIST = #{
		".project", ".git", "_backup"
	}
	
	/** filled via extension point EXTENSION_ID */
	static val KNOWN_EXTENSIONS = <String> newHashSet
	
	protected val uriQueue = new LinkedTransferQueue<URI>
	protected val inProcess = new ConcurrentHashMap<URI,Set<Thread>>
	protected val keyRequests = new ConcurrentHashMap<String,List<KeyRequest>>
	protected val uriRequests = new ConcurrentHashMap<URI,List<UriRequest>>
	protected var WorkspaceCrawler crawler
	protected val resourceListener = new RegistryResourceChangeListener
	
	var _initializedOnStartup = false
	var _initializingOnStartup = false
	
	/** String key -> EObject instance **/
	protected val key_on_obj = new ConcurrentHashMap<String,EObject>
	
	/** String key -> resource URI **/
	protected val key_on_resURI = new ConcurrentHashMap<String,String>
	
	/** resource URI -> String list keys **/
	protected val resURI_on_keys = new ConcurrentHashMap<String,Set<String>>
	
	
	/* 
	 * SINGELTON PATTERN: static instance and private constructor
	 */
	static ReferenceRegistry _instance
	static def getInstance() { _instance ?: (_instance = new ReferenceRegistry) }
	private new() {
		// init file extensions via extension point
		EXTENSION_ID.getExtensions(IFileExtensionSupplier)
			.map[knownFileExtensions]
			.forEach[KNOWN_EXTENSIONS.addAll(it)]
		
		// init listener
		workspace.addResourceChangeListener(resourceListener)
	}
	
	synchronized def isInitializedOnStartup() {
		this._initializedOnStartup
	}
	
	synchronized def setInitializedOnStartup(boolean flag) {
		this._initializedOnStartup = flag
	}
	
	synchronized def isInitializingOnStartup() {
		this._initializingOnStartup
	}
	
	synchronized def setInitializingOnStartup(boolean flag) {
		
		this._initializingOnStartup = flag
	}
	
	def EObject getEObject(String key) {
		key_on_obj.get(key)
		?: loadFromResource(key) // load if URI is known
		?: request(key) // create request for crawler
		?: key_on_obj.get(key) // might have been found in the meantime
	}
	
	def EObject loadFromResource(String key) {
		val uriStr = key_on_resURI.get(key)
		if (uriStr !== null) {
			val obj = loadFromResource(URI.createPlatformResourceURI(uriStr, true), key)
			if (obj !== null) {
				key_on_obj.put(key, obj)
			}
			return obj
		}
		return null
	}
	
	def EObject loadFromResource(URI uri, String key) {
		val res = uri.loadResource
		if (res === null)
			return null
		var obj = res.getEObject(key)
		if (obj === null) {
			val index = key.lastIndexOf("/")
			if (index > -1) {
				val name = key.substring(index)
				obj = res.getEObject("/"+name)
			}
		}
		return obj
	}
	
	/**
	 * @deprecated Use {@link #lookup(URI,Class<T>)} instead.
	 */
	@Deprecated
	def GraphModel getGraphModelFromURI(URI uri) {
		lookup(uri, GraphModel)?.head
	}
	
	def <T extends EObject> lookup(Class<T> clazz) {
		workForRequest(null)
		key_on_obj.values.filter(clazz).toSet
	}
	
	def <T extends EObject> lookup(URI uri, Class<T> clazz) {
		var Iterable<T> result = null
		val keys = resURI_on_keys.get(uri.toPlatformString)
		if (!keys.nullOrEmpty) {
			result = keys.map[key_on_obj.get(it)].filter(clazz).toSet
		}
		return result ?: request(uri)?.values?.filter(clazz)?.toSet
	}
	
	protected def loadResource(URI uri) {
		[ new ResourceSetImpl().getResource(uri, true) ]
		.onException[ warn('''Failed to load resource for URI «uri»''') ]
	}
	
	/**
	 * @deprecated Use {@link #register(EObject)} instead.
	 */
	@Deprecated
	def void addElement(EObject obj) {
		register(obj)
	}
	
	def register(EObject obj) {
		val id = getID(obj)
		if (id === null || id.isEmpty()) {
			showErrorDialog(
				"Error adding Library Component", 
				"The object " + obj + " has no ID feature or the ID is not set. "
				+ "Cannot add it to the registry");
		}
		else register(id, obj)
	}
	
	def register(String key, EObject obj) {
		register(key, obj.eResource?.URI, obj)
	}

	def register(String key, URI resUri, EObject obj) {
		val uri = resUri?.toPlatformString
		if (uri !== null) {
			key_on_resURI.put(key, uri)
			var keys = resURI_on_keys.get(uri)
			if (keys === null) {
				keys = newHashSet
				resURI_on_keys.put(uri,keys)
			}
			resURI_on_keys.get(uri).add(key)
		}
		key_on_obj.put(key, obj)
	}
	
	def unregister(String key) {
		if (key !== null) {
			key_on_resURI.remove(key)
			key_on_obj.remove(key)
		}
	}
	
	def unregister(URI uri) {
		resURI_on_keys.remove(uri.toPlatformString)
	}
	
	protected def request(String key) {
		val request = new KeyRequest(key) => [ req |
			if (!keyRequests.containsKey(key)) {
				keyRequests.put(key, newArrayList)
			}
			keyRequests.get(key).add(req)
			workForRequest(req)
		]
		return request.result
	}
	
	protected def request(URI uri) {
		val request = new UriRequest(uri) => [ req |
			if (!uriRequests.containsKey(uri)) {
				uriRequests.put(uri, newArrayList)
			}
			uriRequests.get(uri).add(req)
			workForRequest(req)
		]
		return request.result
	}
	
	def void initializeOnStartup() {
		println("[RefReg-" + System.currentTimeMillis + "] Initializing on startup...");
		initializingOnStartup = true
		val debugTime = System.currentTimeMillis
		crawler = new WorkspaceCrawler(this)
		println("[RefReg-" + System.currentTimeMillis + "] Crawler: " +  crawler?.hashCode)
		/*
		 * workAndWait keeps the crawler busy because we cannot
		 * join jobs at Eclipse startup
		 */
		crawler => [collectFiles; workAndWait]
		
		println("[RefReg-" + System.currentTimeMillis + "] Initialized. "
			+ key_on_obj.size + " keys. "
			+ resURI_on_keys.size + " URIs. "
			+ "This took " + (System.currentTimeMillis - debugTime) + "ms of your lifetime.")
		
		initializedOnStartup = true
		initializingOnStartup = false
	}
	
	def String getID(EObject obj) {
		var id = EcoreUtil.getID(obj)
		if (id.nullOrEmpty && obj instanceof EClass) {
			id = getEClassId(obj as EClass)
		}
		return id
	}
	
	def String getEClassId(EClass clazz) {
		clazz.EPackage.nsURI + "/" + clazz.name
	}
	
	def String toPlatformString(URI uri) {
		if (uri.isPlatformPlugin) {
			uri.toString
		} else uri.toPlatformResourceURI.toPlatformString(true)
	}
	
	def URI toPlatformResourceURI(URI uri) {
		if (!uri.isPlatformResource) {
			if (uri.isRelative) {
				return URI.createPlatformResourceURI(uri.toString, true)
			}
			else {
				val path = new Path(uri.toFileString)
				val file = workspaceRoot.getFileForLocation(path)
				return URI.createPlatformResourceURI(file.fullPath.toOSString, true)
			}
		}
		return uri
	}
	
	static def isBlacklisted(IContainer con) {
		RESOURCE_BLACKLIST.contains(con.name)
	}
	
	static def isWhitelisted(IFile file) {
		KNOWN_EXTENSIONS.contains(file.fileExtension)
		|| KNOWN_EXTENSIONS.contains(file.name)
	}
	
	def void clearRegistry() {
		key_on_resURI.clear
		resURI_on_keys.clear
		key_on_obj.clear
		crawler = new WorkspaceCrawler(this) => [collectFiles; schedule]
	}
	
	def enqueue(URI uri) {
		if (uri?.getFile?.isWhitelisted) {
			uriQueue.add(uri)
			assertCrawler
		}
	}
	
	protected synchronized def assertCrawler() {
		crawler ?: if (!uriQueue.isEmpty) {
			crawler = new WorkspaceCrawler(this) => [ schedule ]
		}
	}
	
	protected def workForRequest(Request<?,?> request) {
		if (!isInitializedOnStartup && !isInitializingOnStartup) {
			initializeOnStartup
			return
		}
		// go help the crawler instead of useless waiting
		assertCrawler?.workForRequest(request)
	}
	
	def void handleAdd(URI uri) {
		handleChange(uri)
	}
	
	def void handleDelete(URI uri) {
		val keys = uri.unregister
		keys?.forEach[unregister]
	}
	
	def void handleChange(URI uri) {
		val keys = uri.unregister
		keys?.forEach[unregister]
		enqueue(uri)
	}
	
	def void handleRename(URI fromURI, URI toURI) {
		val keys = resURI_on_keys.remove(fromURI)
		keys?.forEach[key_on_resURI.remove(it)]
		enqueue(toURI)
	}
}