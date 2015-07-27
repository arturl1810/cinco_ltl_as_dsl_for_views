package de.jabc.cinco.meta.plugin.pyro.validator;

import java.util.List;

import mgl.Annotation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class AnnotationValidator implements IMetaPluginValidator {

	public AnnotationValidator() {
	}

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("pyro")){
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 2){
				return new ErrorPair<String,EStructuralFeature>(
						"Two arguments are needed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
		}
		return null;
	}

}
