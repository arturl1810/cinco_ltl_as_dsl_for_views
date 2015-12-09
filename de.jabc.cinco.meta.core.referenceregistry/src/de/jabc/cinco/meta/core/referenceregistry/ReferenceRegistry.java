package de.jabc.cinco.meta.core.referenceregistry;

import graphmodel.GraphModel;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Properties;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.operation.IRunnableWithProgress;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.progress.IProgressService;

import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryPartListener;
import de.jabc.cinco.meta.core.referenceregistry.listener.RegistryResourceChangeListener;

public class ReferenceRegistry {

	private static ReferenceRegistry instance;
	
	/** EObject id -> URI **/
	private HashMap<String, String> map;
	/** EObject id -> EObject instance**/
	private HashMap<String, EObject> cache;
	
	
	
	/** Project -> map **/
	private HashMap<IProject, HashMap<String, String>> registriesMap;
	/** Project -> cache **/
	private HashMap<IProject, HashMap<String, EObject>> cachesMap;
	
	private static final String REF_REG_FILE = "refReg.rrg";
	
	private RegistryPartListener partListener = new RegistryPartListener();
	private RegistryResourceChangeListener resourceListener = new RegistryResourceChangeListener();
	private boolean registered = false;

	private IProject currentProject = null;

	
	private ReferenceRegistry() {
		map = new HashMap<String, String>();
		cache = new HashMap<String, EObject>();
		registriesMap = new HashMap<IProject, HashMap<String,String>>();
		cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		
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
			cache.put(id, bo);
		} else {
//			System.out.println(String.format("Found element for id %s. Nothing to do...", id));
		}
	}

	public EObject getEObject(String key) {
		if (cache.containsKey(key)) {
			return cache.get(key);
		}
		EObject bo = null;
		String uri = map.get(key);
		if (uri != null) {
			URI full = URI.createURI(uri, true);
			Resource res = new ResourceSetImpl().getResource(full, true);
			bo = res.getEObject(key);
		} else {
			System.err.println(String.format("Something went wrong. Could not find object for key: %s", key));
		}
		return bo;
	}
	
	public void setCurrentMap(IProject p) {
		if (registriesMap.containsKey(p) && cachesMap.containsKey(p)) {
			this.map = registriesMap.get(p);
			this.cache = cachesMap.get(p);
		} else {
			System.out.println(String.format("No registry file found for project: %s. Creating new map", p));
			load(p);
			registriesMap.put(p, map);
			cache = new HashMap<String, EObject>();
			currentProject = p;
			for (Entry<String, String> e : map.entrySet()) 
				cache.put(e.getKey(), loadObject(e.getKey(), e.getValue()));
			cachesMap.put(p, cache);
			
		}
	}
	
	public void storeMaps(IProject p) {
		registriesMap.put(p, map);
		cachesMap.put(p, cache);
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
		String resourcePath = affectedFileUri.toPlatformString(true);
		System.out.println("Affected file: " +resourcePath);
		HashMap<IProject, List<String>> affected = getAffectedEntries(resourcePath);
		for (Entry<IProject, List<String>> e : affected.entrySet()) {
			IProject p = e.getKey();
			for (String id : e.getValue()) {
				String objectId = id;
				String uri = registriesMap.get(p).get(objectId);
				System.out.println("Refreshing: " + uri + "->" + objectId);
				EObject loadedObject = loadObject(objectId, uri);
				HashMap<String, EObject> tmpCache = cachesMap.get(p);
				tmpCache.replace(objectId, loadedObject);
			}
		}
		if (affected != null && !affected.isEmpty())
			save();
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
				"The object " + bo + " has no id feature. Can't add it to the registry");
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
		return uri;
	}
	
	public void clearRegistry() {
		System.out.println("Clearing");
		this.map = new HashMap<String, String>();
		this.cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		this.cache = new HashMap<String, EObject>();
		this.registriesMap = new HashMap<IProject, HashMap<String,String>>();
	}
	
	public void reinitialize(final IWorkspaceRoot root) {
		IProgressService progressService = PlatformUI.getWorkbench().getProgressService();
		try {
			progressService.busyCursorWhile(new IRunnableWithProgress() {
				
				@Override
				public void run(IProgressMonitor monitor) throws InvocationTargetException,InterruptedException {
					monitor.beginTask("Reinitialize reference registry", 100);
					monitor.worked(0);
					
					clearRegistry();
					
					monitor.worked(10);
					
					Map<String,EObject> allOther = new HashMap<String, EObject>();
					Map<IProject,List<String>> searchFor = new HashMap<IProject,List<String>>();
					
					monitor.subTask("Searching workspace resources...");
					collectResources(root, searchFor, allOther, monitor);
					monitor.worked(60);
					//FIXME: iteration
					for (Entry<IProject, List<String>> e : searchFor.entrySet()) {
						IProject project = e.getKey();
						List<String> ids = e.getValue();
						for (String id : ids) {
							EObject libCompObject = allOther.get(id);
							if (libCompObject != null) {
								URI objectUri = libCompObject.eResource().getURI();
								objectUri = toWorkspaceRelativeURI(objectUri);
								map.put(id, objectUri.toPlatformString(true));
								cache.put(id, libCompObject);
							}
						}
						registriesMap.put(project, map);
						cachesMap.put(project, cache);
					}				
					allOther.clear();
					if (currentProject != null) {
						map = registriesMap.get(currentProject);
						cache = cachesMap.get(currentProject);
					}
					monitor.worked(100);
				}
			});
		} catch (InvocationTargetException | InterruptedException e) {
			e.printStackTrace();
		}
		
	}
	
	private void collectResources(IResource iRes, Map<IProject,List<String>> searchFor, 
			Map<String,EObject> allOther, 
			IProgressMonitor monitor) {
		
		try {
			if (iRes instanceof IContainer && !iRes.getName().equals(".git")) {
				monitor.subTask("Checking resource: " + iRes.getFullPath());
				for (IResource child : ((IContainer) iRes).members()) {
					collectResources(child, searchFor, allOther, monitor);
				}
			} else if (iRes instanceof IFile && !iRes.getName().equals(REF_REG_FILE)) {
				IFile file = (IFile) iRes;
				IProject project = file.getProject();
				if (!file.exists())
					return;
				
				Resource res = getResource(file.getFullPath().toOSString());
				if (searchFor.get(project)== null)
					searchFor.put(project, new ArrayList<String>());
				if (isCincoResource(res)) {
					List<String> wantedIDs = searchForPrimeNodes(res, allOther);
					searchFor.get(project).addAll(wantedIDs);
				}
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private List<String> searchForPrimeNodes(Resource r, Map<String,EObject> allOther) {
		List<String> wanted = new ArrayList<String>();
		TreeIterator<EObject> it = r.getAllContents();
		EObject bo = null;
		while (it.hasNext()) {
			bo = it.next();
			if (bo instanceof EObject) {
				String id = EcoreUtil.getID(bo);
				if (id != null && !id.isEmpty()) {
					allOther.put(id, bo);
				}
			}
			if (bo instanceof Diagram)
				it.prune();
			else {
				EStructuralFeature libCompFeature = bo.eClass().getEStructuralFeature("libraryComponentUID");
				if (libCompFeature != null && bo.eGet(libCompFeature) != null) {
					String id = (String) bo.eGet(libCompFeature);
					wanted.add(id);
				}
			}
		}
		return wanted;
	}

	private boolean isCincoResource(Resource res) {
		if (res == null)
			return false;
		EList<EObject> contents = res.getContents();
		// If the resource is a cinco resource
		if (contents != null && contents.size() == 2) {
			EObject o1 = contents.get(0);
			EObject o2 = contents.get(1);
			return (o1 instanceof Diagram && o2 instanceof GraphModel);
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
	
	private void addMarker(String resourcePath) {
		try {
			if (currentProject == null)
				return;
			
			IMarker[] markers = currentProject.findMarkers(IMarker.PROBLEM, true, IResource.DEPTH_ONE);
			
			String message = String.format("Can't find resource: %s. Does the referenced project exist in the workspace?", resourcePath);
			for (IMarker m :markers) {
				Object attribute = m.getAttribute(IMarker.MESSAGE);
				if (attribute == null)
					continue;
				if (attribute.equals(message))
					return;
			}
			
			IMarker marker = currentProject.createMarker(IMarker.PROBLEM);
			if (marker.exists()) {
				marker.setAttribute(IMarker.MESSAGE, message);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}

	private void deleteMarker(String resourcePath) {
		if (currentProject == null) 
			return;
		try {
			String message = String.format("Can't find resource: %s. Does the referenced project exist in the workspace?", resourcePath);
			for (IMarker m : currentProject.findMarkers(IMarker.PROBLEM, true, IResource.DEPTH_ONE)) {
				if (m.getAttribute(IMarker.MESSAGE).equals(message))
					m.delete();
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}

	
	
}
