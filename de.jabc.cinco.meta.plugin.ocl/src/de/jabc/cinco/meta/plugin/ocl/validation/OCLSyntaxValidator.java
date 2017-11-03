package de.jabc.cinco.meta.plugin.ocl.validation;

import java.util.List;

import mgl.Annotatable;
import mgl.Annotation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class OCLSyntaxValidator implements IMetaPluginValidator {

	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("ocl")){
			List<String> constraints = ((Annotation)eObject).getValue();
			for(String constraint: constraints){
				String errorMessage = checkConstraint(constraint,((Annotation)eObject).getParent());
				if(errorMessage!=null)
					return newError(errorMessage, eObject.eClass().getEStructuralFeature("value"));
			}
		}
		return null;
	}

	private String checkConstraint(String constraint, Annotatable parent) {
		// TODO Auto-generated method stub
		return null;
	}

}
