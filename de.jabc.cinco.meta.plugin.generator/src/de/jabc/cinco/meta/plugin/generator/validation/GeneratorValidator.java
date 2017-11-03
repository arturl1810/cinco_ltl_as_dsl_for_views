package de.jabc.cinco.meta.plugin.generator.validation;

import mgl.Annotation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class GeneratorValidator implements IMetaPluginValidator {

	public GeneratorValidator() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject.eClass().getName().equals("Annotation")){
			Annotation anno = (Annotation)eObject;
			
			if(anno.getName().equals("generatable") && anno.getValue().size() < 2)
				return newError("Generatable Annotation values must consist of qualified implementing Class name and outlet folder (relative to project).",eObject.eClass().getEStructuralFeature("value"));
		}
		return null;
	}

}
