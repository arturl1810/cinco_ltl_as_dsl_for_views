package ${AdapterPackage};

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
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage;

import graphmodel.ModelElement;
import graphmodel.IdentifiableElement;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName?lower_case?capitalize}Package;
import info.scce.mcam.framework.adapter.ModelAdapter;
import ${GraphModelPackage}.graphiti.${GraphModelName}Wrapper;
import ${GraphModelPackage}.api.c${GraphModelName?lower_case}.C${GraphModelName};

<#list ContainerTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>
<#list NodeTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>
<#list EdgeTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>

public class ${GraphModelName}Adapter implements ModelAdapter<${GraphModelName}Id> {

	private ${GraphModelName} model = null;
	private Diagram diagram = null;

	private Resource resource = null;
	private C${GraphModelName} modelWrapper = null;

	private String modelName = "";
	private String path = "";

	@Override
	public List<${GraphModelName}Id> getEntityIds() {
		ArrayList<${GraphModelName}Id> ids = new ArrayList<>();
		ids.add(create${GraphModelName}Id(getModel()));
		
		TreeIterator<EObject> it = getModel().eAllContents();
		while (it.hasNext()) {
			Object obj = it.next();
			if (obj instanceof ModelElement == false)
				continue;
			
			ModelElement me = (ModelElement) obj;
			${GraphModelName}Id id = create${GraphModelName}Id(me);
			String label = getLabel(me);
			if (label != null)
				id.setLabel(label);
			ids.add(id);
		}
		return ids;
	}

	public ${GraphModelName} getModel() {
		if (model == null)
			readModelFromResource();
		if (model == null)
			throw new RuntimeException("model is null");
		return this.model;	
	}

	public Diagram getDiagram() {
		if (diagram == null)
			readDiagramFromResource();
		if (diagram == null)
			throw new RuntimeException("diagram is null");
		return this.diagram;	
	}

	public void setModel(${GraphModelName} model) {
		this.model = model;
	}

	public void setDiagram(Diagram diagram) {
		this.diagram = diagram;
	}

	public C${GraphModelName} getModelWrapper() {
		if (modelWrapper == null)
			createModelWrapper();
		return modelWrapper;
	}

	public void setModelName(String modelName) {
		this.modelName = modelName;
	}

	public void setPath(String path) {
		this.path = path;
	}

	private ${GraphModelName}Id create${GraphModelName}Id(IdentifiableElement obj) {
		return new ${GraphModelName}Id(obj.getId(), obj.eClass());
	}

	public EObject getElementById(${GraphModelName}Id id) {
		if (id.getId().equals(getModel().getId()))
			return getModel();
		TreeIterator<EObject> it = getModel().eAllContents();
		while (it.hasNext()) {
			Object obj = it.next();
			if (obj instanceof ModelElement == false)
				continue;
			
			ModelElement me = (ModelElement) obj;
			if (id.getId().equals(me.getId()))
				return me;
		}
		throw new RuntimeException("Could not find element for '" + id + "'");
	}

	public ${GraphModelName}Id getIdByString(String idString) {
		for (${GraphModelName}Id id : getEntityIds()) {
			if (idString.equals(id.getId()))
				return id;
		}
		throw new RuntimeException("Could not find id for '" + idString + "'");
	}

	@Override
	public String getModelName() {
		return modelName;
	}

	public String getLabel(ModelElement element) {
		<#list ModelLabels as modelLabel>
		if (element instanceof ${modelLabel.type})
		<#if modelLabel.isModelElement == true>
			return getLabel(((${modelLabel.type}) element).get${modelLabel.attribute?cap_first}());			
		<#else>
			return String.valueOf(((${modelLabel.type}) element).get${modelLabel.attribute?cap_first}());
		</#if>
		</#list>
		return null;
	}

	public void highlightElement(${GraphModelName}Id id) {
		Object element = getElementById(id);
		if (element != null)
			if (!(element instanceof ${GraphModelName}))
				<#list ContainerTypes as type>
				if (element instanceof ${type})
					getModelWrapper().findC${type}((${type}) element).highlight();
				</#list>
				<#list NodeTypes as type>
				if (element instanceof ${type})
					getModelWrapper().findC${type}((${type}) element).highlight();
				</#list>
				<#list EdgeTypes as type>
				if (element instanceof ${type})
					getModelWrapper().findC${type}((${type}) element).highlight();
				</#list>
	}

	public void readModel(Resource resource, java.io.File file) {
		modelName = file.getName();
		this.path = file.getPath();
		this.resource = resource;
	}

	public void readModel(Resource resource) {
		this.resource = resource;
	}

	@Override
	public void readModel(java.io.File arg0) {
		modelName = arg0.getName();
		this.path = arg0.getPath();

		// Initialize the model
		${GraphModelName?lower_case?capitalize}Package.eINSTANCE.eClass();
		PictogramsPackage.eINSTANCE.eClass();

		// Register the XMI resource factory for the .family extension
		Resource.Factory.Registry reg = Resource.Factory.Registry.INSTANCE;
		Map<String, Object> m = reg.getExtensionToFactoryMap();
		m.put("${GraphModelExtension}", new XMIResourceFactoryImpl());

		// Obtain a new resource set
		ResourceSet resSet = new ResourceSetImpl();

		// Get the resource
		resource = resSet.getResource(
				URI.createFileURI(arg0.getAbsolutePath()), true);
	}

	public Resource getResource() {
		if (resource == null)
			throw new RuntimeException("resource is null");
		return resource;
	}

	private void readModelFromResource() {
		for (EObject obj : getResource().getContents()) {
			if ("${GraphModelName}".equals(obj.eClass().getName()))
				model = (${GraphModelName}) obj;
		}
	}

	private void readDiagramFromResource() {
		for (EObject obj : getResource().getContents()) {
			if ("Diagram".equals(obj.eClass().getName()))
				diagram = (Diagram) obj;
		}
	}

	private void createModelWrapper() {
		try {
			modelWrapper = ${GraphModelName}Wrapper.wrapGraphModel(getModel(), getDiagram());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
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

}
