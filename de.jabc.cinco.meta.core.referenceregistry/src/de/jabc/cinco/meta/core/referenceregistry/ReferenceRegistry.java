package de.jabc.cinco.meta.core.referenceregistry;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;

public class ReferenceRegistry implements Serializable{

	private static final long serialVersionUID = 4355837301853271006L;

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
	
	public static String generateURI(EObject bo) {
		Resource res = bo.eResource();
		String base = res.getURI().toPlatformString(true);
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
				ObjectInputStream ois = new ObjectInputStream(new FileInputStream(file));
				Object o = ois.readObject();
				count = ois.readInt();
				ois.close();
				if (o instanceof Map) {
					map =  (HashMap<Integer, String>) o;
					print();
					return true;
				}
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			} catch (ClassNotFoundException e) {
				// TODO Auto-generated catch block
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
					ObjectOutputStream oos = new ObjectOutputStream(new FileOutputStream(file));
					oos.writeObject(map);
					oos.writeInt(count);
					oos.close();
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
