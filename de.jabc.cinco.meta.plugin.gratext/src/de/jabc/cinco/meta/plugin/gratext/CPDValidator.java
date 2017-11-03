package de.jabc.cinco.meta.plugin.gratext;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import productDefinition.Annotation;

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class CPDValidator implements IMetaPluginValidator {

	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		if (eObject instanceof Annotation) {
			Annotation a = (Annotation) eObject;
			if (a.getName().equals("disableGratext")) {
				if (!a.getValue().isEmpty()) {
					return newError("No arguments allowed.",
							eObject.eClass().getEStructuralFeature("value"));
				}
			}
		}
		return null;
	}

}
