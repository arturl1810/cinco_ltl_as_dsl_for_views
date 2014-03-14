package de.jabc.cinco.meta.plugin.primeviewer.validation;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;
import mgl.Annotation;
import mgl.ReferencedType;

import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.ecore.EObject;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;

public class PrimeViewerValidator implements IMetaPluginValidator{

	public PrimeViewerValidator() {
		
	}
	public ErrorPair<String,EStructuralFeature> checkPVLabelContainsLabel(final Annotation anno){
		
			if(anno.getValue()==null||anno.getValue().size()!=1){
				return new ErrorPair<String,EStructuralFeature>("Annotation \"pvLabel\" must must have one valid Attribute as label",anno.eClass().getEStructuralFeature("name"));
				
			}
		
		return null;
	}
	
	public ErrorPair<String,EStructuralFeature> checkPVLabelContainsValidLabel(final Annotation anno){
		ErrorPair<String, EStructuralFeature> pair = null;
		if (anno.getParent() instanceof ReferencedType&&anno.getValue().size()==1){

				String value = anno.getValue().get(0);
				ReferencedType refType = (ReferencedType)anno.getParent();
				if(refType.getType().getEStructuralFeature(value)==null)
					pair = new ErrorPair<String, EStructuralFeature>(String.format("%s ist not valid a Reference or Attribute of Prime Reference %s", value,refType.getName()), anno.eClass().getEStructuralFeature("value"));
			
		}
		
		return pair;
	}
	
	public ErrorPair<String,EStructuralFeature> checkPVFileExtensionValueSize(final Annotation anno){
		
		if(anno.getValue()==null||anno.getValue().size()!=1){
			return new ErrorPair<String,EStructuralFeature>("Annotation \"pvFileExtension\" must must have exactly value as File Extension",anno.eClass().getEStructuralFeature("name"));
			
		}
	
	return null;
}
	
	@Override
	public ErrorPair<String, EStructuralFeature> checkAll(EObject eObject) {
		ErrorPair<String,EStructuralFeature> pair = null;
		if(eObject instanceof Annotation){
			if(((Annotation)eObject).getName().equals("pvLabel")){
				pair = checkPVLabelContainsLabel((Annotation)eObject);
				if(pair!=null)
					return pair;
				
				pair = checkPVLabelContainsValidLabel((Annotation)eObject);
				if(pair!=null)
					return pair;
			}else if(((Annotation)eObject).getName().equals("pvFileExtension")){
				pair = checkPVFileExtensionValueSize((Annotation)eObject);
				if(pair!=null)
					return pair;
			}
		}
		return pair;
	}

}
