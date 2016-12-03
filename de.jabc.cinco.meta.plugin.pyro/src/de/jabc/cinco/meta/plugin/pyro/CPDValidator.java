package de.jabc.cinco.meta.plugin.pyro;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import productDefinition.Annotation;

public class CPDValidator implements IMetaPluginValidator {

	public CPDValidator() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation){
			Annotation a = (Annotation) eObject;
			if(a.getName().equals("pyro"))
			{
				if(!a.getValue().isEmpty()){
					if(!a.getValue().get(0).equals("foo"))
					{
						return new ErrorPair<String,EStructuralFeature>(
								"Only foo.",
								eObject.eClass().getEStructuralFeature("value")
								);						
					}
				}
			}
		}
		return null;
	}

}
