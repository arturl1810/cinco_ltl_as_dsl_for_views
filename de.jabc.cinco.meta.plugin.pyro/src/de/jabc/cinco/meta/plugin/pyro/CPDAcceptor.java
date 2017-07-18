package de.jabc.cinco.meta.plugin.pyro;

import java.util.Arrays;
import java.util.List;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.ICPDMetaPluginAcceptor;
import de.jabc.cinco.meta.core.utils.xtext.ChooseFolderApplier;
import productDefinition.Annotation;

public class CPDAcceptor implements ICPDMetaPluginAcceptor {

	public CPDAcceptor() {
		// TODO Auto-generated constructor stub
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		return Arrays.asList("pyro");
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		if(annotation.getName().equals("pyro") && annotation.getValue().size()<=1) {
			return new ChooseFolderApplier(annotation,false);

		}
		return null;
	}

}
