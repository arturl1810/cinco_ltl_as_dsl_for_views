package ${AdapterPackage};

import java.io.File;
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

	private C${GraphModelName} modelWrapper = null;

	private String modelName = "";
	private String path = "";

	@Override
	public List<${GraphModelName}Id> getEntityIds() {
		ArrayList<${GraphModelName}Id> ids = new ArrayList<>();
		ids.add(create${GraphModelName}Id(model));
		
		TreeIterator<EObject> it = model.eAllContents();
		while (it.hasNext()) {
			ModelElement obj = (ModelElement) it.next();
			${GraphModelName}Id id = create${GraphModelName}Id(obj);
			String label = getLabel(obj);
			if (label != null)
				id.setLabel(label);
			ids.add(id);
		}
		return ids;
	}

	public ${GraphModelName} getModel() {
		return this.model;	
	}

	public Diagram getDiagram() {
		return this.diagram;	
	}

	public C${GraphModelName} getModelWrapper() {
		return modelWrapper;
	}

	private ${GraphModelName}Id create${GraphModelName}Id(IdentifiableElement obj) {
		return new ${GraphModelName}Id(obj.getId(), obj.eClass());
	}

	public EObject getElementById(${GraphModelName}Id id) {
		if (id.getId().equals(model.getId()))
			return model;
		TreeIterator<EObject> it = model.eAllContents();
		while (it.hasNext()) {
			ModelElement obj = (ModelElement) it.next();
			if (id.getId().equals(obj.getId()))
				return obj;
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
		return "unknown label"
	}

	public void highlightElement(${GraphModelName}Id id) {
		Object element = getElementById(id);
		if (element != null)
			if (!(element instanceof ${GraphModelName}))
				<#list ContainerTypes as type>
				if (element instanceof ${type})
					modelWrapper.findC${type}((${type}) element).highlight();
				</#list>
				<#list NodeTypes as type>
				if (element instanceof ${type})
					modelWrapper.findC${type}((${type}) element).highlight();
				</#list>
				<#list EdgeTypes as type>
				if (element instanceof ${type})
					modelWrapper.findC${type}((${type}) element).highlight();
				</#list>
	}

	public void setModel(Resource resource, File file) {
		modelName = file.getName();
		this.path = file.getPath();
		
		for (EObject obj : resource.getContents()) {
			if ("Diagram".equals(obj.eClass().getName()))
				diagram = (Diagram) obj;
			if ("${GraphModelName}".equals(obj.eClass().getName()))
				model = (${GraphModelName}) obj;
		}
		try {
			modelWrapper = ${GraphModelName}Wrapper.wrapGraphModel(model, diagram);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	@Override
	public void readModel(File arg0) {
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
		Resource resource = resSet.getResource(
				URI.createFileURI(arg0.getAbsolutePath()), true);
		// Get the first model element and cast it to the right type, in my
		// example everything is hierarchical included in this first node
		for (EObject obj : resource.getContents()) {
			if ("Diagram".equals(obj.eClass().getName()))
				diagram = (Diagram) obj;
			if ("${GraphModelName}".equals(obj.eClass().getName()))
				model = (${GraphModelName}) obj;
		}
		try {
			modelWrapper = ${GraphModelName}Wrapper.wrapGraphModel(model, diagram);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

	@Override
	public void writeModel(File arg0) {
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
		resource.getContents().add(diagram);
		resource.getContents().add(model);

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
