package de.jabc.cinco.meta.core.pluginregistry.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

public interface IMetaPluginValidator {
	public ErrorPair<String,EStructuralFeature> checkAll(final EObject eObject);
}
