package de.jabc.cinco.meta.plugin.papyrus.validator;

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
		
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("papyrus")){
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 1){
				return new ErrorPair<String,EStructuralFeature>(
						"Only one arguments is allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
		}
		return null;
	}

}
