package de.jabc.cinco.meta.plugin.pyro;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import productDefinition.Annotation;

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class CPDValidator implements IMetaPluginValidator {


	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation){
			Annotation a = (Annotation) eObject;
			if(a.getName().equals("pyro"))
			{
				if(a.getValue().size()!=1){
						return newError(
								"One argument needed",
								eObject.eClass().getEStructuralFeature("value")
								);						
				}
			}
		}
		return null;
	}

}
