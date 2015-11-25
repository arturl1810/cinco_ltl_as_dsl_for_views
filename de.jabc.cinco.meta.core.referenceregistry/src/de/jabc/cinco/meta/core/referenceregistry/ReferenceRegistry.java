package de.jabc.cinco.meta.core.referenceregistry;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Properties;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.graphiti.ui.editor.DiagramEditorInput;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPart;

public class ReferenceRegistry implements IPartListener, IResourceChangeListener {

	private IProject currentProject;
	
	private static ReferenceRegistry instance;
	
	/** EObject id -> URI **/
	private HashMap<String, String> map;
	/** EObject id -> EObject instance**/
	private HashMap<String, EObject> objectCache;
	
	/** Project -> map **/
	private HashMap<IProject, HashMap<String, String>> registriesMap;
	/** Project -> cache **/
	private HashMap<IProject, HashMap<String, EObject>> cachesMap;
	
	private static final String REF_REG_FILE = "refReg.rrg";
	
	private ReferenceRegistry() {
		map = new HashMap<String, String>();
		objectCache = new HashMap<String, EObject>();
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
			System.err.println("Registering by uri: " + uri);
			map.put(id, uri.toPlatformString(true));
			objectCache.put(id, bo);
		} else {
			System.out.println(String.format("Found element for id %s. Nothing to do...", id));
		}
	}
	
	public EObject getEObject(String key) {
		if (objectCache.containsKey(key))
			return objectCache.get(key);

		EObject bo = null;
		String uri = map.get(key);
		if (uri != null) {
			URI full = URI.createURI(uri, true);
			Resource res = new ResourceSetImpl().getResource(full, true);
			bo = res.getEObject(key);
		}
		return bo;
	}
	
	public boolean load() {
		File file = getCurrentFile();
		if (file != null && file.exists()) {
			try {
				FileInputStream fis = new FileInputStream(file);
				Properties props = new Properties();
				props.loadFromXML(fis);
				map = new HashMap<String, String>();
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
		return false;
	}
	
	private boolean load(IProject p) {
		File file = getFile(p);
		if (file != null && file.exists()) {
			try {
				FileInputStream fis = new FileInputStream(file);
				Properties props = new Properties();
				props.loadFromXML(fis);
				map = new HashMap<String, String>();
				for (Entry<Object, Object> e : props.entrySet()) {
					map.put((String) e.getKey(), (String)e.getValue());
				}
				fis.close();
				return true;
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return false;
	}
	
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
	
	private File getCurrentFile() {
		if (currentProject != null) {
			IPath base = currentProject.getLocation();
			IPath path = base.append(new Path(REF_REG_FILE));
			File file = path.toFile();
			return file;
		} return null;
	}
	
	private File getFile(IProject p) {
		if (p != null) {
			IPath base = p.getLocation();
			IPath path = base.append(new Path(REF_REG_FILE));
			File file = path.toFile();
			return file;
		} return null;
	}

	private IProject getProject(IWorkbenchPart part) {
		if (part.getSite().getPage().getActiveEditor() == null) 
			return null;
			IEditorInput editorInput = part.getSite().getPage().getActiveEditor().getEditorInput();
			if (!(editorInput instanceof DiagramEditorInput))
				return null;
			DiagramEditorInput input = (DiagramEditorInput) editorInput;
			URI uri = input.getUri();
			IResource member = ResourcesPlugin.getWorkspace().getRoot().findMember(uri.toPlatformString(true));
			IProject project = member.getProject();
			if (project != null && !project.equals(currentProject))
				return project;
			
			return null;
	}
	
	private void setNewMaps(IProject p) {
		if (!registriesMap.containsKey(p)) {
			if (load(p)) {
				System.err.println("Putting map for project: " + p.getName());
				registriesMap.put(p, map);
			} else registriesMap.put(p, new HashMap<String, String>());
		}
		map = registriesMap.get(p);
		
		if (!cachesMap.containsKey(p)) {
			objectCache = new HashMap<String, EObject>();
			for (String key : map.keySet()) {
				EObject eObject = getEObject(key);
				if (eObject != null) 
					objectCache.put(key, eObject);
			}
			cachesMap.put(p, objectCache);
		}
		objectCache = cachesMap.get(p);
	}

	private void saveAndClearCurrentMaps(IProject p) {
		registriesMap.put(p, map);
		cachesMap.put(p, objectCache);
	}
	
	private void showError(EObject bo) {
		MessageDialog.openError(
				Display.getCurrent().getActiveShell(), 
				"Error adding Library Component", 
				"The object " + bo + " has no id feature. Can't add it to the registry");
	}
	
	@Override
	public void partActivated(IWorkbenchPart part) {
		IProject project = getProject(part);
		if (project != null) {
			setNewMaps(project);
			currentProject = project;
		}
//		print();
	}

	@Override
	public void partBroughtToTop(IWorkbenchPart part) {
//		System.out.println("ToTOP: " + getProject(part));		
	}

	@Override
	public void partClosed(IWorkbenchPart part) {
//		System.out.println("CLOSED: " + getProject(part));	
	}

	@Override
	public void partDeactivated(IWorkbenchPart part) {
		if (currentProject != null)
			saveAndClearCurrentMaps(currentProject);
	}

	@Override
	public void partOpened(IWorkbenchPart part) {
		IProject project = getProject(part);
		if (project != null) {
			setNewMaps(project);
			currentProject = project;
		}
//		print();
	}

	@Override
	public void resourceChanged(IResourceChangeEvent event) {
		IResourceDelta delta = event.getDelta();
		processAffectedFiles(delta);
	}

	private void processAffectedFiles(IResourceDelta delta) {
		for (IResourceDelta child: delta.getAffectedChildren()) {
			IResource res = child.getResource();
			if (res instanceof IFile) {
				IPath fullPath = res.getFullPath();
//				System.out.println("Found affected file: " + fullPath);
//				System.out.println("Delta Kind: " + delta.getKind());
				if (resourceRemoved(fullPath)){
					handleFileRemoval(fullPath);
				} else {
					updateChangedFile(fullPath);
				}
			}
			processAffectedFiles(child);
		}
	}

	private void handleFileRemoval(IPath fullPath) {
		for ( Entry<String, String> e: map.entrySet()) {
			if (e.getValue().equals(fullPath.toString())) {
				String objectId = e.getKey();
				map.remove(objectId);
				objectCache.remove(objectId);
			}
				
		}
	}

	private void updateChangedFile(IPath fullPath) {
		for (Entry<IProject, HashMap<String, String>> val : registriesMap.entrySet()) {
			for (Entry<String, String> e : val.getValue().entrySet()) {
				if (e.getValue().equals(fullPath.toString())) {
					IProject project = val.getKey();
					String objectId = e.getKey();
					String resourcePath = e.getValue();
					refresh(project, objectId, resourcePath);
				}
			}
		}
	}

	private void refresh(IProject project, String objectId, String resourcePath) {
		HashMap<String, EObject> cache = cachesMap.get(project);
		HashMap<String, String> refMap = registriesMap.get(project);
		EObject eObject = loadObject(objectId, resourcePath);
		if (eObject != null)
			cache.put(objectId, eObject);
		else {
			System.err.println("Object removed... ");
			cache.remove(objectId);
			refMap.remove(objectId);
		}
	}

	private EObject loadObject(String objectId, String resourcePath) {
		Resource res = getResource(resourcePath);
		EObject eObject = res.getEObject(objectId);
		return eObject;
	}

	private boolean resourceRemoved(IPath fullPath) {
		Resource res = getResource(fullPath.toOSString());
		return res == null;
	}
	
	private Resource getResource(String resourcePath) {
		URI uri = URI.createPlatformResourceURI(resourcePath, true);
		Resource res = new ResourceSetImpl().getResource(uri, false);
		if (res != null)
			res = new ResourceSetImpl().getResource(uri, true);
		return res;
	}

	public void clearRegistry() {
		this.map = new HashMap<String, String>();
		this.cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		this.objectCache = new HashMap<String, EObject>();
		this.registriesMap = new HashMap<IProject, HashMap<String,String>>();
	}
	
	public void print() {
		System.out.println("RefReg map contents:");
		if (map.entrySet().isEmpty())
			System.out.println("EMPTY");
		for (Entry<String, String> e : map.entrySet()) {
			System.out.println(String.format("KEY: %s \t VALUE: %s", e.getKey(), e.getValue()));
		}
		
		System.out.println("Object Cache:");
		if (objectCache.entrySet().isEmpty())
			System.out.println("EMPTY");
		for (Entry<String, EObject> e : objectCache.entrySet()) {
			System.out.println(String.format("KEY: %s \t VALUE: %s", e.getKey(), e.getValue()));
		}
		System.out.println("");
	}
	
}
