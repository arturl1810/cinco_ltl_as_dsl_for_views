package de.jabc.cinco.meta.plugin.ocl.validation;

import java.util.List;

import mgl.Annotatable;
import mgl.Annotation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class OCLSyntaxValidator implements IMetaPluginValidator {

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("ocl")){
			List<String> constraints = ((Annotation)eObject).getValue();
			for(String constraint: constraints){
				String errorMessage = checkConstraint(constraint,((Annotation)eObject).getParent());
				if(errorMessage!=null)
					return new ErrorPair<String, EStructuralFeature>(errorMessage, eObject.eClass().getEStructuralFeature("value"));
			}
		}
		return null;
	}

	private String checkConstraint(String constraint, Annotatable parent) {
		// TODO Auto-generated method stub
		return null;
	}

}
