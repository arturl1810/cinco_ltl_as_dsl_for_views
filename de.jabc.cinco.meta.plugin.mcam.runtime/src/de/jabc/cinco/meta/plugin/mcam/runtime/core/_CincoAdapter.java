package de.jabc.cinco.meta.plugin.mcam.runtime.core;

import graphmodel.GraphModel;
import graphmodel.IdentifiableElement;
import graphmodel.ModelElement;
import info.scce.mcam.framework.adapter.ModelAdapter;

import java.io.IOException;
import java.util.Collections;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.graphiti.mm.pictograms.Diagram;

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass;

public abstract class _CincoAdapter<T extends _CincoId, M extends GraphModel> extends CincoRuntimeBaseClass implements ModelAdapter<T> {

	protected M model = null;
	protected Diagram diagram = null;

	protected Resource resource = null;

	protected String modelName = "";
	protected String path = "";
	
	@Override
	public List<T> getEntityIds() {
		List<T> ids = new ArrayList<>();
		T id = createId(getModel());
		id.setElement(getModel());
		ids.add(id);
		
		TreeIterator<EObject> it = getModel().getInternalElement().eAllContents();
		while (it.hasNext()) {
			Object obj = it.next();
			if (obj instanceof ModelElement == false)
				continue;
			
			ModelElement me = (ModelElement) obj;
			id = createId(me);
			id.setElement(me);
			String label = getLabel(me);
			if (label != null)
				id.setLabel(label);
			ids.add(id);
		}
		return ids;
	}

	public M getModel() {
		if (model == null || model.eResource() == null)
			readModelFromResource();
		if (model == null)
			throw new RuntimeException("model is null");
		return this.model;	
	}

	public Diagram getDiagram() {
		if (diagram == null || diagram.eResource() == null)
			readDiagramFromResource();
		if (diagram == null)
			throw new RuntimeException("diagram is null");
		return this.diagram;	
	}

	public void setModel(M model) {
		this.model = model;
	}

	public void setDiagram(Diagram diagram) {
		this.diagram = diagram;
	}

	public void setModelName(String modelName) {
		this.modelName = modelName;
	}

	public void setPath(String path) {
		this.path = path;
	}

	public EObject getElementById(T id) {
		return id.getElement();
//		if (id.getId().equals(getModel().getId()))
//			return getModel();
//		TreeIterator<EObject> it = getModel().eAllContents();
//		while (it.hasNext()) {
//			Object obj = it.next();
//			if (obj instanceof ModelElement == false)
//				continue;
//			
//			ModelElement me = (ModelElement) obj;
//			if (id.getId().equals(me.getId()))
//				return me;
//		}
//		throw new RuntimeException("Could not find element for '" + id + "'");
	}

	public T getIdByString(String idString) {
		for (T id : getEntityIds()) {
			if (idString.equals(id.getId()))
				return id;
		}
		throw new RuntimeException("Could not find id for '" + idString + "'");
	}

	@Override
	public String getModelName() {
		return modelName;
	}

	public void readModel(Resource resource, java.io.File file) {
		modelName = file.getName();
		this.path = file.getPath();
		this.resource = resource;
	}

	public void readModel(Resource resource) {
		this.resource = resource;
	}

	public Resource getResource() {
		if (resource == null)
			throw new RuntimeException("resource is null");
		return resource;
	}

	private void readDiagramFromResource() {
		for (EObject obj : getResource().getContents()) {
			if ("Diagram".equals(obj.eClass().getName()))
				diagram = (Diagram) obj;
		}
	}

	@Override
	public void writeModel(java.io.File arg0) {
		// Register the XMI resource factory for the .website extension
		Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
		Map<String, Object> m = reg.getExtensionToFactoryMap();
		m.put("${GraphModelExtension}", new XMIResourceFactoryImpl());

		// Obtain a new resource set
		ResourceSet resSet = new ResourceSetImpl();

		// create a resource
		Resource resource = resSet.createResource(URI.createFileURI(arg0.getAbsolutePath()));

		// Get the first model element and cast it to the right type, in my
		// example everything is hierarchical included in this first node
		resource.getContents().add(getDiagram());
		resource.getContents().add(getModel());

		// now save the content.
		try {
			resource.save(Collections.EMPTY_MAP);
			this.path = arg0.getPath();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	public String getFilePath() {
		return path;
	}
	
	@SuppressWarnings("unchecked")
	protected void readModelFromResource() {
		model = (M) _resourceExtension.getGraphModel(getResource());
	}
	
	protected abstract T createId(IdentifiableElement obj);

	public abstract String getLabel(ModelElement element);

	public void highlightElement(T id) {
		Object element = id.getElement();
		if (element instanceof ModelElement)
			 ((ModelElement) element).highlight();
	}

	@Override
	public abstract void readModel(java.io.File arg0);

}
