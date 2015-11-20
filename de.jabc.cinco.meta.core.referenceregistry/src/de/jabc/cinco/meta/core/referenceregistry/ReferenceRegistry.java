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
import org.eclipse.core.resources.IResource;
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

public class ReferenceRegistry implements IPartListener {

	private IProject currentProject;
	
	private static ReferenceRegistry instance;
	
	private HashMap<String, String> map;
	private HashMap<String, EObject> objectCache;

	private HashMap<IProject, HashMap<String, EObject>> cachesMap;
	private HashMap<IProject, HashMap<String, String>> registriesMap;
	
	private int count = 0;
	
	private static final String REF_REG_FILE = "refReg.rrg";
	
	private ReferenceRegistry() {
		map = new HashMap<String, String>();
		objectCache = new HashMap<String, EObject>();
		registriesMap = new HashMap<IProject, HashMap<String,String>>();
		cachesMap = new HashMap<IProject, HashMap<String,EObject>>();
		objectCache = new HashMap<String, EObject>();
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
		if (currentProject != null) {
			IPath base = currentProject.getLocation();
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
	
	private void refreshData(IProject p) {
		if (p != null && !p.equals(currentProject)){
			saveAndClearCurrentMaps(p);
			setNewMaps(p);
		}
	}
	
	private void setNewMaps(IProject p) {
		if (!registriesMap.containsKey(p)) {
			load();
			registriesMap.put(p, map);
		}
		map = registriesMap.get(p);
		
		if (!cachesMap.containsKey(p)) {
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
		map.clear();
		objectCache.clear();
	}
	
	private void showError(EObject bo) {
		MessageDialog.openError(
				Display.getCurrent().getActiveShell(), 
				"Error adding Library Component", 
				"The object " + bo + " has no id feature. Can't add it to the registry");
	}
	
	@Override
	public void partActivated(IWorkbenchPart part) {
		System.out.println("ACTIVATE: " + getProject(part));
	}

	@Override
	public void partBroughtToTop(IWorkbenchPart part) {
		System.out.println("ToTOP: " + getProject(part));		
	}

	@Override
	public void partClosed(IWorkbenchPart part) {
		System.out.println("CLOSED: " + getProject(part));	
	}

	@Override
	public void partDeactivated(IWorkbenchPart part) {
		System.out.println("DeACTIVATE: " + getProject(part));
	}

	@Override
	public void partOpened(IWorkbenchPart part) {
		IProject project = getProject(part);
		refreshData(project);
	}

}
