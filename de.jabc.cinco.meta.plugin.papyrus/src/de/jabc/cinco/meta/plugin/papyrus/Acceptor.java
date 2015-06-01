package de.jabc.cinco.meta.plugin.papyrus;

import java.util.ArrayList;
import java.util.List;

import mgl.Annotation;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;
import de.jabc.cinco.meta.core.utils.xtext.ChooseFolderApplier;

public class Acceptor implements IMetaPluginAcceptor {

	public Acceptor() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		ArrayList<String> aList = new ArrayList<>();
		if(annotation.getName().equals("papyrus")){
			if(annotation.getValue().size()==1) {
				aList.add("Choose folder...");
			}
		}
		
		return aList;
		
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		if(annotation.getName().equals("papyrus") && annotation.getValue().size()==1) {
			return new ChooseFolderApplier(annotation,false);

		}
		return null;
	}

}
