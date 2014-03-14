package de.jabc.cinco.meta.core.utils.xtext;

import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.widgets.FontDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseFontStyle extends ReplacementTextApplier{

	private String prefix;
	
	public ChooseFontStyle() {
		prefix = "";
	}
	
	public ChooseFontStyle(String prefix) {
		this.prefix = prefix;
	}
	
	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		
		FontDialog fd = new FontDialog(new Shell());
		FontData fData = fd.open();
		String style = "";
		switch (fData.getStyle()) {
		case SWT.BOLD:
			style = "BOLD";
			break;
		case SWT.ITALIC:
			style = "ITALIC";
			break;
		case (SWT.BOLD | SWT.ITALIC):
			style = "BOLD, ITALIC";
			break;
		default:
			break;
		}
		
		String retVal = prefix+"\""+fData.name + "\"," +style+ "," + fData.getHeight() +")";
		if (fData != null)
			return retVal;
		else return "";
	}
	
}
