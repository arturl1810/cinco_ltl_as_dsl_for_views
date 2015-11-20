package de.jabc.cinco.meta.core.referenceregistry;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Properties;

import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

public class ReferenceRegistry{

	private static ReferenceRegistry instance;
	private HashMap<Integer, String> map;
	
	private int count = 0;
	
	private static final String REF_REG_FILE = "refReg.rrg";
	
	private ReferenceRegistry() {
		map = new HashMap<Integer, String>();
	}
	
	public static ReferenceRegistry getInstance() {
		if (instance == null)
			instance = new ReferenceRegistry();
		return instance;
	}
	
	public void addElement(int key, String uri) {
		map.put(key, uri);
	}
	
	public int getKey(String uri) {
		if (map.containsValue(uri)) {
			System.out.println("Found key for " + uri);
			return findKey(uri);
		}
		return count++;
	}
	
	public String generateURI(EObject bo) {
		Resource res = bo.eResource();
		String fragment = res.getURIFragment(bo);
		URI baseURI = res.getURI();
		URI full = baseURI.appendFragment(fragment);
		
		return full.toString();
	}
	
	public EObject getEObject(Integer key) {
		EObject bo = null;
		String uri = map.get(key);
		if (uri != null) {
			URI full = URI.createURI(uri, true);
			Resource res = new ResourceSetImpl().getResource(full, true);
			if (full.fragment() != null) {
				bo = res.getEObject(full.fragment());
			}			
		}
		return bo;
	}
	
	public boolean load() {
		File file = getFile();
		if (file != null && file.exists()) {
			try {
				FileInputStream fis = new FileInputStream(file);
				Properties props = new Properties();
				props.loadFromXML(fis);
				for (Entry<Object, Object> e : props.entrySet()) {
					map.put((Integer) e.getKey(), (String)e.getValue());
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
	
	public boolean save() {
			try {
				File file = getFile();
				if (!file.exists()) {
					file.createNewFile();
				}
				FileOutputStream fos = new FileOutputStream(file);
				Properties props = new Properties();
				props.putAll(map);
				props.storeToXML(fos, "The reference registry");
				fos.close();
				return true;
			} 
			catch (IOException e) {
				e.printStackTrace();
			}
		return false;
	}
	
	public void clearRegistry() {
		this.map = new HashMap<Integer, String>();
		this.count = 0;
	}
	
	public void print() {
		System.out.println("Current count value: " + count);
		System.out.println("RefReg map contents:.....");
		for (Entry<Integer, String> e : map.entrySet()) {
			System.out.println(String.format("KEY: %d \t VALUE: %s", e.getKey(), e.getValue()));
		}
		System.out.println("");
	}
	
	private File getFile() {
		IPath base = ResourcesPlugin.getWorkspace().getRoot().getLocation();
		IPath path = base.append(new Path(REF_REG_FILE));
		File file = path.toFile();
		return file;
	}
	
	private int findKey(String uri) {
		for (Entry<Integer, String> e : map.entrySet()) {
			if (e.getValue().equals(uri))
				return e.getKey();
		}
		return -1;
	}

}


/*package de.jabc.cinco.meta.core.referenceregistry;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Properties;

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

public class ReferenceRegistry{

	private static ReferenceRegistry instance;
	private HashMap<String, String> map;
	
	private int count = 0;
	
	private static final String REF_REG_FILE = "refReg.rrg";
	
	private ReferenceRegistry() {
		map = new HashMap<String, String>();
	}
	
	public static ReferenceRegistry getInstance() {
		if (instance == null)
			instance = new ReferenceRegistry();
		return instance;
	}
	
	public void addElement(EObject bo) {
		String id = EcoreUtil.getID(bo);
		if (id == null || id.isEmpty())
			MessageDialog.openError(
					Display.getCurrent().getActiveShell(), 
					"Error adding Library Component", 
					"The object " + bo + " has no id feature. Can't add it to the registry");
		if (!map.containsKey(id)) {
			URI uri = bo.eResource().getURI();
			map.put(id, uri.toPlatformString(true));
		} else {
			System.out.println(String.format("Found element for id %s. Nothing to do...", id));
		}
	}
	
	public void addElement(String key, String uri) {
		map.put(key, uri);
	}
	
	public String generateURI(EObject bo) {
		Resource res = bo.eResource();
		String fragment = res.getURIFragment(bo);
		URI baseURI = res.getURI();
		URI full = baseURI.appendFragment(fragment);
		
		return full.toString();
	}
	
	public EObject getEObject(String key) {
		EObject bo = null;
		String uri = map.get(key);
		if (uri != null) {
			URI full = URI.createURI(uri, true);
			Resource res = new ResourceSetImpl().getResource(full, true);
			if (full.fragment() != null) {
				bo = res.getEObject(full.fragment());
			}			
		}
		return bo;
	}
	
	public boolean load() {
		File file = getFile();
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
		return false;
	}
	
	public boolean save() {
			try {
				File file = getFile();
				if (!file.exists()) {
					file.createNewFile();
				}
				FileOutputStream fos = new FileOutputStream(file);
				Properties props = new Properties();
				props.putAll(map);
				props.storeToXML(fos, "The reference registry");
				fos.close();
				return true;
			} 
			catch (IOException e) {
				e.printStackTrace();
			}
		return false;
	}
	
	public void clearRegistry() {
		this.map = new HashMap<String, String>();
		this.count = 0;
	}
	
	public void print() {
		System.out.println("Current count value: " + count);
		System.out.println("RefReg map contents:.....");
		for (Entry<String, String> e : map.entrySet()) {
			System.out.println(String.format("KEY: %d \t VALUE: %s", e.getKey(), e.getValue()));
		}
		System.out.println("");
	}
	
	private File getFile() {
		IPath base = ResourcesPlugin.getWorkspace().getRoot().getLocation();
		IPath path = base.append(new Path(REF_REG_FILE));
		File file = path.toFile();
		return file;
	}

}
*/
