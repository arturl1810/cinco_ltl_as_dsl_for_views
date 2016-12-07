package de.jabc.cinco.meta.core.utils.xtext;


import mgl.Annotation;

import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseWizard extends ReplacementTextApplier {

	private Annotation annotation;
	
	public ChooseWizard(Annotation annot) {
		annotation = annot;
	}
	
	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		
		PerformWizard wizard = new PerformWizard(annotation);
		if(wizard.getPath()!= null)
		{
			return "\"" +  wizard.getPath() + "\"";
		}
		return "";
	}

}
