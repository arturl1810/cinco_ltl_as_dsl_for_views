package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.swt.graphics.RGB;
import org.eclipse.swt.widgets.ColorDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class PickColorApplier extends ReplacementTextApplier {

	private String preFix;
	
	public PickColorApplier(String retValPrefix) {
		preFix = retValPrefix;
	}
	
	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		
		ColorDialog cDialog = new ColorDialog(new Shell());
		RGB rgb = cDialog.open();
		String r, g, b;
		
		r = String.valueOf(rgb.red);
		g = String.valueOf(rgb.green);
		b = String.valueOf(rgb.blue);
		
		return preFix + r + "," + g +"," + b + ")";
	}

}
