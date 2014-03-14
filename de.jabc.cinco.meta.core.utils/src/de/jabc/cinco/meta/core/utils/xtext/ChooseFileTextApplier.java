package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseFileTextApplier extends ReplacementTextApplier {

	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		
		FileDialog dialog = new FileDialog(new Shell());
		dialog.setText("Choose an image file...");
		String filePath = dialog.open();
		
		return "\""+filePath+"\")";
	}

}
