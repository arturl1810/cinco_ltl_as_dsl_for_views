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
				if(!a.getValue().isEmpty()){
						return new ErrorPair<String,EStructuralFeature>(
								"No arguments allowed.",
								eObject.eClass().getEStructuralFeature("value")
								);						
				}
			}
		}
		return null;
	}

}
