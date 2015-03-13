package de.jabc.cinco.meta.plugin.mcam.util;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseClassTextApplier extends ReplacementTextApplier {

	private EObject eObject;

	public ChooseClassTextApplier(EObject eo) {
		this.eObject = eo;
	}

	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		
		
		return "Test";
	}

}
