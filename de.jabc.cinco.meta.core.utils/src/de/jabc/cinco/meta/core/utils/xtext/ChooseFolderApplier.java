package de.jabc.cinco.meta.core.utils.xtext;

import java.io.File;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.swt.widgets.DirectoryDialog;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.xtext.ui.editor.contentassist.ConfigurableCompletionProposal;
import org.eclipse.xtext.ui.editor.contentassist.ReplacementTextApplier;

public class ChooseFolderApplier extends ReplacementTextApplier {

	private EObject eObject;
	private boolean onlyWorkspaceFiles;
	
	public ChooseFolderApplier(EObject eo) {
		this.eObject = eo;
		this.onlyWorkspaceFiles=true;
	}
	
	public ChooseFolderApplier(EObject eo,boolean onlyWorkspaceFiles) {
		this.eObject = eo;
		this.onlyWorkspaceFiles = onlyWorkspaceFiles;
	}
	
	@Override
	public String getActualReplacementString(
			ConfigurableCompletionProposal proposal) {
		DirectoryDialog dialog = new DirectoryDialog(new Shell());
		IPath projectPath = null;
		dialog.setText("Choose a folder...");
		if (eObject != null) {
			URI resURI = eObject.eResource().getURI();
			IResource iRes = ResourcesPlugin.getWorkspace().getRoot().findMember(resURI.toPlatformString(true));
			IProject p = iRes.getProject();
			projectPath = new Path(p.getName());
			dialog.setFilterPath(p.getLocation().toOSString());
		}
		String filePath = dialog.open();
		if (filePath == null)
			return "";
		IPath iFilePath = new Path(filePath);
		if(!onlyWorkspaceFiles) {
			return "\""+filePath+"\"";
		}
		if (!ResourcesPlugin.getWorkspace().getRoot().getLocation().isPrefixOf(iFilePath)) {
			ErrorDialog.openError(Display.getCurrent().getActiveShell(), "Invalid file", "Unable to process the selected file", 
					new Status(IStatus.ERROR, filePath, "The file you selected is not contained in your workspace. Please choose another file..."));
			return "";
		}
		File iconFile = new File(filePath);
		if (iconFile.exists()) {
			IPath iRelativePath = new Path(filePath);
			iRelativePath = iRelativePath.makeRelativeTo(ResourcesPlugin.getWorkspace().getRoot().getLocation());
			if (projectPath.isPrefixOf(iRelativePath)) {
				iRelativePath = iRelativePath.makeRelativeTo(projectPath);
				filePath = iRelativePath.toOSString();
			} else filePath = "platform:/resource/" + iRelativePath.toOSString();
			
		}
		
		//
		return "\""+filePath+"\"";
	}

}
