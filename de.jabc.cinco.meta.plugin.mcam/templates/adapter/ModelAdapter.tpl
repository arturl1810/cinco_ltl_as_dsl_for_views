package ${AdapterPackage};

import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl;
import org.eclipse.graphiti.mm.pictograms.PictogramsPackage;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoAdapter;
import graphmodel.ModelElement;
import graphmodel.IdentifiableElement;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName?lower_case?capitalize}Package;
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

public class ${GraphModelName}Adapter extends _CincoAdapter<${GraphModelName}Id,${GraphModelName}, C${GraphModelName}> {

	private C${GraphModelName} modelWrapper = null;

	@Override
	protected void createModelWrapper() {
		try {
			modelWrapper = ${GraphModelName}Wrapper.wrapGraphModel(getModel(), getDiagram());
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	@Override
	protected ${GraphModelName}Id createId(IdentifiableElement obj) {
		return new ${GraphModelName}Id(obj.getId(), obj.eClass());
	}

	@Override
	protected void readModelFromResource() {
		for (EObject obj : getResource().getContents()) {
			if ("${GraphModelName}".equals(obj.eClass().getName()))
				model = (${GraphModelName}) obj;
		}
	}

	public C${GraphModelName} getModelWrapper() {
		if (modelWrapper == null)
			createModelWrapper();
		return modelWrapper;
	}


	@Override
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

	@Override
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

}
