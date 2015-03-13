package de.jabc.cinco.meta.plugin.mcam.util;

import java.util.ArrayList;
import java.util.List;

import mgl.Annotation;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

import de.jabc.cinco.meta.core.pluginregistry.proposalprovider.IMetaPluginAcceptor;

public class McamProposalProvider implements IMetaPluginAcceptor {

	public McamProposalProvider() {
	}

	@Override
	public List<String> getAcceptedStrings(Annotation annotation) {
		ArrayList<String> list = new ArrayList<>();
		if ("mcam_changemodule".equals(annotation.getName())) {
			list.add("Choose ChangeModule ...");
		}
		return list;
	}

	@Override
	public IReplacementTextApplier getTextApplier(Annotation annotation) {
		if ("mcam_changemodule".equals(annotation.getName())) {
			return new ChooseClassTextApplier(annotation);
		}
		return null;
	}

}
