package de.jabc.cinco.meta.core.referenceregistry;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Properties;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.PlatformUI;

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
//			System.err.println("Registering by uri: " + uri.toPlatformString(true));
			map.put(id, uri.toPlatformString(true));
			cache.put(id, bo);
		} else {
			System.out.println(String.format("Found element for id %s. Nothing to do...", id));
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
			//FIXME: Load the new cache!!! This maps the old cache to Project p...
			cache = new HashMap<String, EObject>();
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
		HashMap<IProject, String> affected = getAffectedEntries(searchVal);
		
		for (Entry<IProject, String> e : affected.entrySet()) {
			registriesMap.get(e.getKey()).remove(e.getValue());
			cachesMap.get(e.getKey()).remove(e.getValue());
		}
		if (affected != null && !affected.isEmpty())
			save();
		}

	public void handleRename(URI fromURI, URI toURI) {
		String from = fromURI.toPlatformString(true);
		String to = toURI.toPlatformString(true);
		HashMap<IProject, String> affected = getAffectedEntries(from);
		for (Entry<IProject, String> e : affected.entrySet()) {
			registriesMap.get(e.getKey()).replace(e.getValue(), to);
		}
		if (affected != null && !affected.isEmpty())
			save();
	}
	
	public void handleContentChange(URI affectedFileUri) {
		String resourcePath = affectedFileUri.toPlatformString(true);
		HashMap<IProject, String> affected = getAffectedEntries(resourcePath);
		for (Entry<IProject, String> e : affected.entrySet()) {
			IProject p = e.getKey();
			String objectId = e.getValue();
			String uri = registriesMap.get(p).get(objectId);
			EObject loadedObject = loadObject(objectId, uri);
			cachesMap.get(p).replace(objectId, loadedObject);
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
	private HashMap<IProject, String> getAffectedEntries(String resourcePath) {
		HashMap<IProject, String> affected = new HashMap<IProject, String>();
		for (Entry<IProject, HashMap<String, String>> p2m : registriesMap.entrySet()) {
			HashMap<String, String> m = p2m.getValue();
			for (Entry<String, String> e : m.entrySet()) {
				if (e.getValue().equals(resourcePath)) {
					affected.put(p2m.getKey(), e.getKey());
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
		EObject eObject = res.getEObject(objectId);
		return eObject;
	}

	private Resource getResource(String resourcePath) {
		URI uri = URI.createPlatformResourceURI(resourcePath, true);
		Resource res = new ResourceSetImpl().getResource(uri, true);
		if (res != null)
			res = new ResourceSetImpl().getResource(uri, true);
		return res;
	}

	public void clearRegistry() {
		System.out.println("Clearing");
		this.map = new HashMap<String, String>();
		this.cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		this.cache = new HashMap<String, EObject>();
		this.registriesMap = new HashMap<IProject, HashMap<String,String>>();
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
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().addPartListener(partListener);
		ResourcesPlugin.getWorkspace().addResourceChangeListener(resourceListener);
		registered = true;
	}
	
}
