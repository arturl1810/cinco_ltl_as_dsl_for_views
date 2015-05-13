package de.jabc.cinco.meta.plugin.papyrus.validator;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class AnnotationValidator implements IMetaPluginValidator {

	public AnnotationValidator() {
	}

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		// TODO Auto-generated method stub
		return null;
	}

}
