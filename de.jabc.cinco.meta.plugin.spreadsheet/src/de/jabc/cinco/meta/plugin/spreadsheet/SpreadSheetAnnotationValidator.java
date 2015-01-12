package de.jabc.cinco.meta.plugin.spreadsheet;

import java.util.List;

import mgl.Annotation;
import mgl.Attribute;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class SpreadSheetAnnotationValidator implements IMetaPluginValidator {

	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("spreadsheet")){
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 0){
				return new ErrorPair<String,EStructuralFeature>(
						"No Arguments allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("result")){
			if(!((Attribute)((Annotation)eObject).getParent()).getType().equals("EDouble")){
				return new ErrorPair<String,EStructuralFeature>(
						"Attribute type EDouble required for result attribute.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 0){
				return new ErrorPair<String,EStructuralFeature>(
						"No arguments allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("calculating")){
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 0){
				return new ErrorPair<String,EStructuralFeature>(
						"No arguments allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		return null;
	}
}
