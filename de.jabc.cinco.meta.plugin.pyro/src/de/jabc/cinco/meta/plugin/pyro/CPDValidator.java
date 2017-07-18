package de.jabc.cinco.meta.plugin.pyro;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import productDefinition.Annotation;

public class CPDValidator implements IMetaPluginValidator {


	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation){
			Annotation a = (Annotation) eObject;
			if(a.getName().equals("pyro"))
			{
				if(a.getValue().size()!=1){
						return new ErrorPair<String,EStructuralFeature>(
								"One argument needed",
								eObject.eClass().getEStructuralFeature("value")
								);						
				}
			}
		}
		return null;
	}

}
