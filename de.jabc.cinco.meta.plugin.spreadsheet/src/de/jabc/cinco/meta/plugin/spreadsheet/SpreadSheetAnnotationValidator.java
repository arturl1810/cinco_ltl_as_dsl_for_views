package de.jabc.cinco.meta.plugin.spreadsheet;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import mgl.Annotation;
import mgl.Attribute;
import mgl.Node;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

import static de.jabc.cinco.meta.plugin.template.SpreadsheetUtil.getType;
import static de.jabc.cinco.meta.core.pluginregistry.validation.ValidationResult.newError;

public class SpreadSheetAnnotationValidator implements IMetaPluginValidator {

	@Override
	public ValidationResult<String, EStructuralFeature> checkAll(EObject eObject) {
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("spreadsheet")){
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() > 4){
				return newError(
						"At most four arguments are allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			if(args.size()>=1) {
				if(!(args.get(0).equals("multiple") || args.get(0).equals("single"))){
					return newError(
							"Supported options for the first argument are: multiple or single",
							eObject.eClass().getEStructuralFeature("value")
							);
				}
			}
			if(args.size()>=2) {
				Pattern pattern = Pattern.compile("^[^/./\\:*?\"<>|]+$");
			    Matcher matcher = pattern.matcher(args.get(1));
			    if(!matcher.matches()) {
			    	return newError(
			    			args.get(1)+" is not a valid filename.",
							eObject.eClass().getEStructuralFeature("value")
							);
			    }
			}
			if(args.size()>=3) {
				Pattern pattern = Pattern.compile("\\d+");
			    Matcher matcher = pattern.matcher(args.get(2));
			    if(!matcher.matches()) {
			    	return newError(
			    			args.get(2)+" is not a valid number.",
							eObject.eClass().getEStructuralFeature("value")
							);
			    }
			}
			if(args.size()==4) {
				Pattern pattern = Pattern.compile("\\d+");
			    Matcher matcher = pattern.matcher(args.get(3));
			    if(!matcher.matches()) {
			    	return newError(
			    			args.get(3)+" is not a valid number.",
							eObject.eClass().getEStructuralFeature("value")
							);
			    }
			}
			
		}
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("result")){
			//FIXME: Changed during api overhaul. Old verion in comment
//			if(!((Attribute)((Annotation)eObject).getParent()).getType().equals("EDouble")){
			if(!(getType((Attribute)((Annotation)eObject).getParent())).equals("EDouble")){
				return newError(
						"Attribute type EDouble required for result attribute.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 0){
				return newError(
						"No arguments allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("calculating")){
			if(!(((Annotation) eObject).getParent() instanceof mgl.Edge)){
				return newError(
						"Annotation is only capable for Edges.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() != 0){
				return newError(
						"No arguments allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		if(eObject instanceof Annotation&&((Annotation)eObject).getName().equals("resulting")){
			if(!(((Annotation) eObject).getParent() instanceof mgl.Node)){
				return newError(
						"Annotation is only capable for Nodes.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			else {
				mgl.Node node = (Node) ((Annotation) eObject).getParent();
				boolean foundResult = false;
				for (Attribute attr : node.getAttributes()) {
					for (Annotation anno : attr.getAnnotations()) {
						if(anno.getName().equals("result"))foundResult=true;
					}
				}
				if(!foundResult) {
					return newError(
							"A resulting node needs a @result annotation.",
							eObject.eClass().getEStructuralFeature("value")
							);
				}
			}
			
			List<String> args = ((Annotation)eObject).getValue();
			//Amount of arguments validation
			if(args.size() > 1){
				return newError(
						"Only one argument is allowed.",
						eObject.eClass().getEStructuralFeature("value")
						);
			}
			
		}
		return null;
	}
}
