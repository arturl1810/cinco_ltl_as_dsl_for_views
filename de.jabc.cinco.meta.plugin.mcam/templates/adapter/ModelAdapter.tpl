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
import graphmodel.internal.InternalGraphModel;
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName};
import ${GraphModelPackage}.${GraphModelName?lower_case}.${GraphModelName?lower_case?capitalize}Package;

<#list ContainerTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>
<#list NodeTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>
<#list EdgeTypes as type>
import ${GraphModelPackage}.${GraphModelName?lower_case}.${type};
</#list>

public class ${GraphModelName}Adapter extends _CincoAdapter<${GraphModelName}Id,${GraphModelName}> {

	
	@Override
	protected ${GraphModelName}Id createId(IdentifiableElement obj) {
		return new ${GraphModelName}Id(obj);
	}

	@Override
	protected void readModelFromResource() {
		for (EObject obj : getResource().getContents()) {
			if ("Internal${GraphModelName}".equals(obj.eClass().getName()))
				model = (${GraphModelName}) ((InternalGraphModel) obj).getElement();
		}
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
			 	if (element instanceof ModelElement)
			 		((ModelElement) element).highlight();
	}

	@Override
	public void readModel(java.io.File arg0) {
		modelName = arg0.getName();
		this.path = arg0.getPath();

		// Initialize the model
		${GraphModelName?lower_case?capitalize}Package.eINSTANCE.eClass();
		PictogramsPackage.eINSTANCE.eClass();

		// Obtain a new resource set
		ResourceSet resSet = new ResourceSetImpl();

		// Get the resource
		resource = resSet.getResource(
				URI.createFileURI(arg0.getAbsolutePath()), true);
	}

}
