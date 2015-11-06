package de.jabc.cinco.meta.plugin.primeviewer.validation;
import java.util.ArrayList;
import java.util.Collection;
import java.util.stream.Collectors;

import mgl.Annotation;
import mgl.GraphModel;
import mgl.ModelElement;
import mgl.Node;
import mgl.Edge;
import mgl.ReferencedEClass;
import mgl.ReferencedModelElement;
import mgl.ReferencedType;
import mgl.UserDefinedType;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;

import de.jabc.cinco.meta.core.pluginregistry.validation.ErrorPair;
import de.jabc.cinco.meta.core.pluginregistry.validation.IMetaPluginValidator;

public class PrimeViewerValidator implements IMetaPluginValidator{

	public PrimeViewerValidator() {
		
	}
	
	public ErrorPair<String,EStructuralFeature> checkPVLabelAndPVFileExtensionIsUsed(final Annotation anno){
//		try{
//			GraphModel gm = (GraphModel)anno.getParent();
//			for(Node n: gm.getNodes()){
//				if(n.getPrimeReference()!=null){
//					boolean foundPvLabel=false;
//					boolean foundPvFileExtension=false;
//					for(Annotation a: n.getPrimeReference().getAnnotations()){
//						if(a.getName().equals("pvLabel")){
//							foundPvLabel=true;
//							
//						}else if(a.getName().equals("pvFileExtension")){
//							foundPvFileExtension=true;
//						}
//						
//						if(foundPvFileExtension&&foundPvLabel)
//							break;
//					}
//					if(!foundPvLabel&&foundPvFileExtension)
//						return new ErrorPair<String, EStructuralFeature>(String.format("Node %s has no 'pvLabel' annotation.",n.getName()), anno.eClass().getEStructuralFeature("name"));
//					else if(foundPvLabel&&!foundPvFileExtension)
//						return new ErrorPair<String, EStructuralFeature>(String.format("Node %s has no 'pvFileExtension' annotation.",n.getName()), anno.eClass().getEStructuralFeature("name"));
//					else if(!foundPvLabel&&!foundPvFileExtension)
//						return new ErrorPair<String, EStructuralFeature>(String.format("Node %s has neither 'pvLabel' nor 'pvFileExtension' annotation.",n.getName()), anno.eClass().getEStructuralFeature("name"));
//				}
//			}
//		}catch(ClassCastException ce){
//			return new ErrorPair<String, EStructuralFeature>(String.format("'primeviewer' annotation is not suitable for %s.",anno.getParent().getClass().getSimpleName()), anno.eClass().getEStructuralFeature("name"));
//		}
//		
		return null;
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
				if(refType instanceof ReferencedEClass){
					if(((ReferencedEClass) refType).getType().getEStructuralFeature(value)==null){
						pair = new ErrorPair<String, EStructuralFeature>(String.format("%s ist not a valid Reference or Attribute of Prime Reference %s", value,refType.getName()), anno.eClass().getEStructuralFeature("value"));
					}
				}else if(refType instanceof ReferencedModelElement){
					if(!(getAllAttributes(((ReferencedModelElement) refType).getType()).stream().anyMatch(e -> e.equals(value)))){
						pair = new ErrorPair<String, EStructuralFeature>(String.format("%s ist not a valid Attribute of Prime Reference %s", value,refType.getName()), anno.eClass().getEStructuralFeature("value"));
					}
				}
			
		}
		
		return pair;
	}
	
	private Collection<String> getAllAttributes(ModelElement type) {
		ArrayList<String> attributes = new ArrayList<>();
		ModelElement current = type;
		while(current!=null){
			attributes.addAll(current.getAttributes().stream().map(attr -> attr.getName()).collect(Collectors.toList()));
			current=getExtends(current);
		}
		return attributes;
	}
	private ModelElement getExtends(ModelElement type) {
		if(type instanceof GraphModel){
			return ((GraphModel)type).getExtends();
		}else if(type instanceof Node){
			return ((Node)type).getExtends();
		}else if(type instanceof Edge){
			return ((Edge)type).getExtends();
		}
		return null;
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
		if(eObject instanceof Annotation) {
			if(((Annotation)eObject).getName().equals("primeviewer")){
				pair = checkPVLabelAndPVFileExtensionIsUsed((Annotation)eObject);
				if(pair!=null){
					return pair;
				}
			}
			else if(((Annotation)eObject).getName().equals("pvLabel")){
				pair = checkPVLabelContainsLabel((Annotation)eObject);
				if(pair!=null){
					return pair;
				}
				pair = checkPVLabelContainsValidLabel((Annotation)eObject);
				if(pair!=null){
					return pair;
				}
			}else if(((Annotation)eObject).getName().equals("pvFileExtension")){
				pair = checkPVFileExtensionValueSize((Annotation)eObject);
				if(pair!=null)
					return pair;
			}
		}
		return pair;
	}

}
