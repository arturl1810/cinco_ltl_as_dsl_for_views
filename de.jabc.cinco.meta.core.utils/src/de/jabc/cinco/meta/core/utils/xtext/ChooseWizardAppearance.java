package de.jabc.cinco.meta.core.utils.xtext;


import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseWizardAppearance extends ReplacementTextApplier {

	private EObject eObject;
	
	public ChooseWizardAppearance(EObject model) {
	  eObject = model;
	}

	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		PerformAppearanceWizard wizard = new PerformAppearanceWizard(eObject);
		if(wizard.getPath()!= null)
		{
			return "\"" +  wizard.getPath() + "\"";
		}
		return "";
	}

}
