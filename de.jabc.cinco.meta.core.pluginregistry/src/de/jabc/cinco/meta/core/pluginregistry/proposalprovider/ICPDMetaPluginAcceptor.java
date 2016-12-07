package de.jabc.cinco.meta.core.pluginregistry.proposalprovider;

import java.util.List;

import productDefinition.Annotation;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal.IReplacementTextApplier;

public interface ICPDMetaPluginAcceptor {
	public List<String> getAcceptedStrings(Annotation annotation);

	public IReplacementTextApplier getTextApplier(Annotation annotation);
}
