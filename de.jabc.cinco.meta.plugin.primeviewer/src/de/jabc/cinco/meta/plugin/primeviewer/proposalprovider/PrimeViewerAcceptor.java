package de.jabc.cinco.meta.plugin.primeviewer.proposalprovider;

import java.util.ArrayList;
import java.util.List;

import mgl.Annotation;
import mgl.Attribute;
import mgl.ReferencedEClass;
import mgl.ReferencedModelElement;
import mgl.ReferencedType;

import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

public class PrimeViewerAcceptor implements IMetaPluginAcceptor {
	
	public PrimeViewerAcceptor() {
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		ArrayList<String> aList = new ArrayList<>();
		if(annotation.getName().equals("pvLabel")){
			ReferencedType rType = ((ReferencedType)annotation.getParent());
			if(rType instanceof ReferencedEClass){
				for(EStructuralFeature feature: ((ReferencedEClass) rType).getType().getEAllStructuralFeatures()){
					aList.add(feature.getName());
				}
			}else if(rType instanceof ReferencedModelElement){
				for(Attribute feature: ((ReferencedModelElement) rType).getType().getAttributes()){
					aList.add(feature.getName());
				}
			}
		}
		
		return aList;
		
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		return null;
	}

}
