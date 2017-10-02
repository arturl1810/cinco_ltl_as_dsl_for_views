package de.jabc.cinco.meta.core.referenceregistry;

import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;

import de.jabc.cinco.meta.core.referenceregistry.implementing.IFileExtensionSupplier;
import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryPartListener;
import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryResourceChangeListener;
import de.jabc.cinco.meta.core.utils.job.CompoundJob;
import graphmodel.GraphModel;
import graphmodel.internal.InternalGraphModel;

public class ReferenceRegistry {

	private static final String REF_REG_FILE = "refReg.rrg";
	private static final String EXTENSION_ID = "de.jabc.cinco.meta.core.referenceregistry";
	
	private static List<String> RESOURCE_BLACKLIST = Arrays.asList(new String[] {
		REF_REG_FILE, ".git", "_backup"
	});
	
	private static HashSet<String> KNOWN_EXTENSIONS;
	
	private static ReferenceRegistry instance;
	
	/** EObject id -> URI **/
	private HashMap<String, String> map;
	/** EObject id -> EObject instance**/
	private HashMap<String, EObject> cache;
	
	
	
	/** Project -> map **/
	private HashMap<IProject, HashMap<String, String>> registriesMap;
	/** Project -> cache **/
	private HashMap<IProject, HashMap<String, EObject>> cachesMap;
	
	
	
	private RegistryPartListener partListener = new RegistryPartListener();
	private RegistryResourceChangeListener resourceListener = new RegistryResourceChangeListener();
	private boolean registered = false;
	private boolean refreshedOnStartup = false;

	private IProject currentProject = null;
	private CompoundJob reinitJob;

	
	private ReferenceRegistry() {
		map = new HashMap<String, String>();
		cache = new HashMap<String, EObject>();
		registriesMap = new HashMap<IProject, HashMap<String,String>>();
		cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		
		KNOWN_EXTENSIONS = new HashSet<String>();
	}
	
	public static ReferenceRegistry getInstance() {
		if (instance == null)
			instance = new ReferenceRegistry();
		return instance;
	}
	
	public void addElement(EObject bo) {
		String id = EcoreUtil.getID(bo);
		if (id == null || id.isEmpty())
			showError(bo);
		if (!map.containsKey(id)) {
			URI uri = bo.eResource().getURI();
			uri = toWorkspaceRelativeURI(uri);
			map.put(id, uri.toPlatformString(true));
			EObject newBo = getEObject(id);
			cache.put(id, newBo);
		} else {
//			System.out.println(String.format("Found element for id %s. Nothing to do...", id));
		}
	}

	public EObject getEObject(String key) {
		if (cache.containsKey(key)) {
			EObject v = cache.get(key);
			return v;
		}
		EObject bo = null;
		String uri = map.get(key);
		if (uri != null) {
			URI full = URI.createURI(uri, true);
			Resource res = new ResourceSetImpl().getResource(full, true);
			bo = res.getEObject(key);
		} else {
			if (!refreshedOnStartup) {
				reinitializeOnStartup(ResourcesPlugin.getWorkspace().getRoot());
			} else {
				if (reinitJob == null) {
					reinitialize(ResourcesPlugin.getWorkspace().getRoot());
				}
				if (reinitJob != null) try {
					reinitJob.join();
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
			bo = searchInAllMaps(key);
			
			if (bo != null) {
				refreshCurrentMap(key);
			} else System.err.println(String.format("Something went wrong. Could not find object for key: %s", key));
		}
		return bo;
	}
	
	private EObject searchInAllMaps(String key) {
		for (HashMap<String, EObject> c : cachesMap.values()) {
			if (c.containsKey(key))
				return c.get(key);
		}
		return null;
	}
	
	private void refreshCurrentMap(String key) {
		for (Entry<IProject, HashMap<String, EObject>> e : cachesMap.entrySet()) {
			if (e.getValue().containsKey(key)) {
				cache = e.getValue();
				map = registriesMap.get(e.getKey());
			}
		}
	}
	
	public void setCurrentMap(IProject p) {
		if (registriesMap.containsKey(p) && cachesMap.containsKey(p)) {
			this.map = registriesMap.get(p);
			this.cache = cachesMap.get(p);
		} else {
			System.out.println(String.format("No registry file found for project: %s. Creating new map", p));
			long debugTime = System.currentTimeMillis();
			
			job("Build Reference Registry")
			  .label("Initializing...")
			  .consume(5)
			    .task(() -> loadMap(p))
			    .task(this::clearCache)
			  .label("Processing resources...")
			  .consume(100)
			    .taskForEach(() -> map.entrySet().stream().map(e -> e.getValue()).distinct(),
				    		this::loadObjects, uri -> uri)
			  .consume(5)
			    .task(() -> storeMaps(p))
			  .onFinished(() -> {
				  System.out.println(String.format(
						"Registry map created. This took %s of your lifetime.",
						"" + (System.currentTimeMillis() - debugTime) + " ms"));
			      })
			  .schedule();
		}
	}
	
	private void loadMap(IProject p) {
		currentProject = p;
		load(p);
	}
	
	private void clearCache() {
		cache = new HashMap<String, EObject>();
	}
	
	private void loadObjects(String resourceUri) {
		Resource res = getResource(resourceUri);
		res.getContents().forEach(obj -> {
			loadObject(res, obj);
		});
	}
	
	private void loadObject(Resource res, Object obj) {
		if (obj instanceof EObject && !(obj instanceof Diagram)) {
			EObject eobj = (EObject) obj;
			String id = res.getURIFragment(eobj);
			if (map.containsKey(id))
				cache.put(id, eobj);
			EcoreUtil.getAllContents(eobj, true).forEachRemaining(child -> {
				loadObject(res, child);
			});
		}
	}
	
	public void storeMaps(IProject p) {
		registriesMap.put(p, map);
		cachesMap.put(p, cache);
	}
	
	public void handleAdd(URI uri) {
		handleContentChange(uri);
	}
	
	public void handleDelete(URI uri) {
		String searchVal = uri.toPlatformString(true);
		HashMap<IProject, List<String>> affected = getAffectedEntries(searchVal);
		
		for (Entry<IProject, List<String>> e : affected.entrySet()) {
			for (String id : e.getValue()) {
				registriesMap.get(e.getKey()).remove(id);
				cachesMap.get(e.getKey()).remove(id);
			}
		}
		if (affected != null && !affected.isEmpty())
			save();
	}

	public void handleProjectDeleted(IProject p) {
		removeProjectFromMaps(p);
	}

	public void handleProjectOpened(IProject p) {
		reinitialize(p);
	}
	
	public void handleProjectClosed(IProject p) {
		removeProjectFromMaps(p);
	}
	
	public void handleRename(URI fromURI, URI toURI) {
		String from = fromURI.toPlatformString(true);
		String to = toURI.toPlatformString(true);
		HashMap<IProject, List<String>> affected = getAffectedEntries(from);
		for (Entry<IProject, List<String>> e : affected.entrySet()) {
			for (String id : e.getValue())
				registriesMap.get(e.getKey()).replace(id, to);
		}
		if (affected != null && !affected.isEmpty())
			save();
	}
	
	public void handleContentChange(URI affectedFileUri) {
		long start = System.currentTimeMillis();
		String resourcePath = affectedFileUri.toPlatformString(true);
//		System.out.println("Content change event for file: " +resourcePath);
		HashMap<IProject, List<String>> affected = getAffectedEntries(resourcePath);
		Map<String,Resource> loadedResources = new HashMap<String,Resource>();
		for (Entry<IProject, List<String>> e : affected.entrySet()) {
			IProject p = e.getKey();
			for (String id : e.getValue()) {
				String objectId = id;
				String uri = registriesMap.get(p).get(objectId);
//				System.out.println("Refreshing: " + uri + "->" + objectId);
				EObject loadedObject = null;
				if (loadedResources.containsKey(uri)) {
					Resource res = loadedResources.get(uri);
					loadedObject = res.getEObject(objectId);
				} else {
					loadedObject = loadObject(objectId, uri);
				}
				if (loadedObject != null) {
					loadedResources.put(uri,loadedObject.eResource());
					HashMap<String, EObject> tmpCache = cachesMap.get(p);
					tmpCache.replace(objectId, loadedObject);
				} else {
					System.out.println(String.format("Failed to load object %s from %s", objectId, uri));
					loadedResources.remove(uri);
					HashMap<String, EObject> tmpCache = cachesMap.get(p);
					tmpCache.remove(objectId);
				}
			}
		}
		if (affected != null && !affected.isEmpty())
			save();
		long end = System.currentTimeMillis();
//		System.out.println("Update time in ms: "+ (end-start));
	}
	
	/**
	 * This method searches the tuples of (IProject,ID) which are affected by changes to the
	 * resource given by the resourcePath
	 * @param resourcePath
	 * @return Affected tuples (IProject,ID)
	 */
	private HashMap<IProject, List<String>> getAffectedEntries(String resourcePath) {
		HashMap<IProject, List<String>> affected = new HashMap<IProject, List<String>>();
		for (Entry<IProject, HashMap<String, String>> p2m : registriesMap.entrySet()) {
			HashMap<String, String> m = p2m.getValue();
			for (Entry<String, String> e : m.entrySet()) {
				if (e.getValue().equals(resourcePath)) {
					if (affected.get(p2m.getKey()) == null)
						affected.put(p2m.getKey(), new ArrayList<String>());
					affected.get(p2m.getKey()).add(e.getKey());
				}
			}
		}
		return affected;
	}
	
	/**
	 * Creates a new HashMap<ID,URI> and fills it with the content of the
	 * registry file.
	 * @param p The project in which to search the stored registry
	 * @return true, if the registry file was successfully loaded, false otherwise
	 */
	private void load(IProject p) {
		File file = getFile(p);
		this.map = new HashMap<String, String>();
		if (file != null && file.exists()) {
			try {
				FileInputStream fis = new FileInputStream(file);
				Properties props = new Properties();
				props.loadFromXML(fis);
				for (Entry<Object, Object> e : props.entrySet()) {
					map.put((String) e.getKey(), (String)e.getValue());
				}
				fis.close();
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	/**
	 * Saves all in-memory maps to the hard disk inside the corresponding IProject
	 * @return true, if all maps were stored, false if an error occurred
	 */
	public boolean save() {
		for (IProject p : registriesMap.keySet()) {
			if (!save(p))
				return false;
		}
		return true;
	}
	
	private boolean save(IProject p) {
			try {
				File file = getFile(p);
				if (!file.exists()) {
					file.createNewFile();
				}
				FileOutputStream fos = new FileOutputStream(file);
				Properties props = new Properties();
				props.putAll(registriesMap.get(p));
				props.storeToXML(fos, "The reference registry");
				fos.close();
				return true;
			} 
			catch (IOException e) {
				e.printStackTrace();
			} 
		return false;
	}
	
	private void removeProjectFromMaps(IProject p) {
		registriesMap.remove(p);
		cachesMap.remove(p);
		if (currentProject != null && currentProject.equals(p))
			currentProject = null;
	}

	private File getFile(IProject p) {
		if (p != null) {
			IPath base = p.getLocation();
			IPath path = base.append(new Path(REF_REG_FILE));
			File file = path.toFile();
			return file;
		} return null;
	}

	

	private void showError(EObject bo) {
		MessageDialog.openError(
				Display.getCurrent().getActiveShell(), 
				"Error adding Library Component", 
				"The object " + bo + " has no id feature or the id is not set. "
						+ "Can't add it to the registry");
	}

	private EObject loadObject(String objectId, String resourcePath) {
		Resource res = getResource(resourcePath);
		if (res == null) 
			return null;
		EObject eObject = res.getEObject(objectId);
		return eObject;
	}

	
	private Resource getResource(String resourcePath) {
		URI uri = URI.createPlatformResourceURI(resourcePath, true);
		try {
			Resource res = new ResourceSetImpl().getResource(uri, true);
//			deleteMarker(resourcePath);
			return res;
		} catch (Exception e) {
//			addMarker(resourcePath);
		}
		return null;
	}

		
	private URI toWorkspaceRelativeURI(URI uri) {
		if (!uri.isRelative() && !uri.isPlatformResource()) {
			IPath path = new Path(uri.toFileString());
			IFile file = ResourcesPlugin.getWorkspace().getRoot().getFileForLocation(path);
			uri = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
		}
		
		if (uri.isRelative() && !uri.isPlatformResource()) {
			uri = URI.createPlatformResourceURI(uri.toString(), true);
		}
		
		return uri;
	}
		
	
	public void clearRegistry() {
		System.out.println("Clearing Reference Registry...");
		this.map = new HashMap<String, String>();
		this.cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		this.cache = new HashMap<String, EObject>();
		this.registriesMap = new HashMap<IProject, HashMap<String,String>>();
	}
	
	public CompoundJob reinitialize(IContainer container) {
		System.out.println("Reinitializing Reference Registry...");
		
		initKnownFileExtensions();
		List<IFile> files = new ArrayList<>();
		Map<String,EObject> objectsById = new HashMap<>();
		Map<IProject,Set<String>> idsByProject = new HashMap<>();
		
		long debugTime = System.currentTimeMillis();
		reinitJob = job("Reinitialize Reference Registry");
		reinitJob.label("Initializing...")
		  .consume(5)
		    .task("Clear registry", this::clearRegistry)
		    .task("Collect files", () -> collectFiles(container, files))
		  .label("Collecting resources...")
		  .consume(80)
		    .taskForEach(() -> files.stream(),
		    			file -> extractIds(file, idsByProject, objectsById),
		    			file -> file.getName())
		  .label("Creating registry entries...")
		  .consume(5)
		    .taskForEach(() -> idsByProject.entrySet().stream(),
		    			e -> registerObjects(e.getKey(), e.getValue(), objectsById),
		    			e -> e.getKey().getName())
		  .consume(5)
		    .task("Save to registry file", this::setCurrentProject)
		    .task("Save to registry file", this::save)
		  .onFinished(() -> { System.out.println(String.format(
					"Registry map created. This took %s of your lifetime.",
					"" + (System.currentTimeMillis() - debugTime) + " ms"));
		  	})
		  .schedule();
		return reinitJob;
	}
	
	public void reinitializeOnStartup(IContainer container) {
		System.out.println("Reinitializing Reference Registry on startup...");
		
		long debugTime = System.currentTimeMillis();
		
		initKnownFileExtensions();
		List<IFile> files = new ArrayList<>();
		Map<String,EObject> objectsById = new HashMap<>();
		Map<IProject,Set<String>> idsByProject = new HashMap<>();
		
		clearRegistry();
		collectFiles(container, files);
		files.forEach(file -> extractIds(file, idsByProject, objectsById));
		idsByProject.entrySet().forEach(e -> registerObjects(e.getKey(), e.getValue(), objectsById));
		setCurrentProject();
		save();
		
		System.out.println(String.format(
				"Registry map created. This took %s of your lifetime.",
				"" + (System.currentTimeMillis() - debugTime) + " ms"));
		
		refreshedOnStartup = true;
	}
	
	private void registerObjects(IProject project, Iterable<String> ids, Map<String,EObject> objectsById) {
		HashMap<String,String> map = new HashMap<>();
		HashMap<String,EObject> cache = new HashMap<>();
		ids.forEach(id -> {
			EObject libCompObject = objectsById.get(id);
			if (libCompObject != null) {
				URI objectUri = libCompObject.eResource().getURI();
				objectUri = toWorkspaceRelativeURI(objectUri);
				map.put(id, objectUri.toPlatformString(true));
				cache.put(id, libCompObject);
			}
		});
		registriesMap.put(project, map);
		cachesMap.put(project, cache);
	}
	
	private void setCurrentProject() {
		if (currentProject != null) {
			map = registriesMap.get(currentProject);
			cache = cachesMap.get(currentProject);
		}
	}
	
	private boolean isBlacklisted(IContainer con) {
		return RESOURCE_BLACKLIST.contains(con.getName());
	}
	
	private boolean isBlacklisted(IFile file) {
		return !KNOWN_EXTENSIONS.contains(file.getFileExtension())
				&& !KNOWN_EXTENSIONS.contains(file.getName());
	}
	
	private void collectFiles(IContainer container, List<IFile> files) {
		if (container instanceof IContainer
				&& !isBlacklisted(container)
				&& container.isAccessible()) {
			
			IResource[] members = null;
			try {
				members = container.members();
			} catch (CoreException e) {
				e.printStackTrace();
			}
			if (members != null)
				Arrays.stream(members).forEach(child -> {
					if (child instanceof IContainer) {
						collectFiles((IContainer) child, files);
					} else if (child instanceof IFile
							&& !isBlacklisted((IFile)child)) {
						files.add((IFile)child);
					}
				});
		}
	}
	
	//FIXME: Changes idsByProject type from Map<IProject,List<String>> to Map<IProject,Set<String>>
	private void extractIds(IFile file, Map<IProject,Set<String>> idsByProject, Map<String, EObject> objectsById) {
		IProject project = file.getProject();
		Set<String> ids = idsByProject.get(project);
		if (ids == null) {
			ids = new HashSet<>();
			idsByProject.put(project, ids);
		}
		Resource res = getResource(file.getFullPath().toOSString());
		if (isCincoResource(res)) {
			ids.addAll(extractIds(res, objectsById));
		}
	}
	
	private List<String> extractIds(Resource res, Map<String,EObject> objectsById) {
		List<String> wanted = new ArrayList<String>();
		res.getContents().forEach(obj -> {
			extractIds(obj, objectsById, wanted);
		});
		return wanted;
	}
	
	private void extractIds(Object obj, Map<String,EObject> objectsById, List<String> wanted) {
		if (obj instanceof EObject && !(obj instanceof Diagram)) {
			EObject eobj = (EObject) obj;
			String id = EcoreUtil.getID(eobj);
			if (id != null && !id.isEmpty()) {
				objectsById.put(id, eobj);
			}
			EStructuralFeature libCompFeature =
					eobj.eClass().getEStructuralFeature("libraryComponentUID");
			if (libCompFeature != null) {
				Object val = eobj.eGet(libCompFeature);
				if (val != null) {
					wanted.add((String) val);
				}
			}
			EcoreUtil.getAllContents(eobj, true).forEachRemaining(child -> {
				extractIds(child, objectsById, wanted);
			});
		}
	}
	
	private boolean isCincoResource(Resource res) {
		if (res == null)
			return false;
		EList<EObject> contents = res.getContents();
		// If the resource is a cinco resource
		if (contents != null && contents.size() == 2) {
			EObject o1 = contents.get(0);
			EObject o2 = contents.get(1);
			return (o1 instanceof Diagram && o2 instanceof InternalGraphModel);
		}
		// If the resource is an arbitrary library created with EMF
		else if (contents != null && contents.size() == 1)
			return (contents.get(0) instanceof EObject);
		return false;
	}

	public void print() {
		System.out.println("----------------------------------------------------------");
		System.out.println("RefReg map contents:");
		if (map.entrySet().isEmpty())
			System.out.println("EMPTY");
		for (Entry<String, String> e : map.entrySet()) {
			System.out.println(String.format("KEY: %s \t VALUE: %s", e.getKey(), e.getValue()));
		}
		System.out.println("");
		System.out.println("Object Cache:");
		if (cache.entrySet().isEmpty())
			System.out.println("EMPTY");
		for (Entry<String, EObject> e : cache.entrySet()) {
			System.out.println(String.format("KEY: %s \t VALUE: %s", e.getKey(), e.getValue()));
		}
		System.out.println("----------------------------------------------------------");
	}
	
	public void registerListener() {
		if (registered)
			return;
		IWorkbench workbench = PlatformUI.getWorkbench();
		if (workbench == null)
			return;
		IWorkbenchWindow activeWorkbenchWindow = workbench.getActiveWorkbenchWindow();
		if (activeWorkbenchWindow == null)
			return;
		IWorkbenchPage activePage = activeWorkbenchWindow.getActivePage();
		if (activePage != null)
			activePage.addPartListener(partListener);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener);
		registered = true;
	}
	
	private void initKnownFileExtensions() {
		IConfigurationElement[] configElements = 
				Platform.getExtensionRegistry().getConfigurationElementsFor(EXTENSION_ID);
		for (IConfigurationElement ce : configElements) {
			try {
				Object o = ce.createExecutableExtension("class");
				KNOWN_EXTENSIONS.addAll(executeExtension(o));
			} catch (CoreException e) {
				e.printStackTrace();
			}
		}
	}

	private Collection<? extends String> executeExtension(final Object o) {
		final List<String> extensions = new ArrayList<String>();
	
		ISafeRunnable runnable = new ISafeRunnable() {
			
			@Override
			public void run() throws Exception {
				extensions.addAll(((IFileExtensionSupplier) o).getKnownFileExtensions());
			}
			
			@Override
			public void handleException(Throwable exception) {
				System.out.println("Exception in client");
				exception.printStackTrace();
			}
		};
		SafeRunner.run(runnable);
		return extensions;
	}

	public GraphModel getGraphModelFromURI(URI uri) {
		String searchFor = toWorkspaceRelativeURI(uri).toPlatformString(true);
		for (Entry<IProject, HashMap<String, String>> map : registriesMap.entrySet()) {
			for (Entry<String, String> e : map.getValue().entrySet()) {
				if (e.getValue().equals(searchFor)) {
					EObject eObj = cachesMap.get(map.getKey()).get(e.getKey());
					if (eObj instanceof GraphModel)
						return (GraphModel) eObj;
				}
			}
		}
		
		return null;
	}
}
