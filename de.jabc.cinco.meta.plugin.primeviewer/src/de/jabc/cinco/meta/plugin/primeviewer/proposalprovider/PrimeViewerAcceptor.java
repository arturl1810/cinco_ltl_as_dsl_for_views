package de.jabc.cinco.meta.plugin.primeviewer.proposalprovider;

import java.util.ArrayList;
import java.util.List;

import javax.naming.event.ObjectChangeListener;

import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import mgl.Annotation;
import mgl.ReferencedType;
import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

public class PrimeViewerAcceptor implements IMetaPluginAcceptor {
	
	public PrimeViewerAcceptor() {
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		ArrayList<String> aList = new ArrayList<>();
		if(annotation.getName().equals("pvLabel")){
			ReferencedType rType = ((ReferencedType)annotation.getParent());
			for(EStructuralFeature feature: rType.getType().getEAllStructuralFeatures()){
				aList.add(feature.getName());
			}
		}
		
		return aList;
		
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		return null;
	}

}
