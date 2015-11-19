package de.jabc.cinco.meta.plugin.gratext.template

class BackupActionTemplate extends AbstractGratextTemplate {
		
def backupGenerator() {
	fileFromTemplate(BackupGeneratorTemplate)
}
		
override template()
'''	
package «project.basePackage».generator;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.dialogs.InputDialog;
import org.eclipse.jface.window.Window;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IActionDelegate;
import org.eclipse.swt.widgets.Display;

public class BackupAction implements IActionDelegate {

	private ISelection sel;
	
	public BackupAction() {}

	@Override
	public void run(IAction action) {
		System.out.println("Selection: " + sel);
		if (sel instanceof IStructuredSelection) {
			IStructuredSelection ssel = (IStructuredSelection) sel;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IFile) {
				IFile file = (IFile) ssel.getFirstElement();
				//String path = new Path("#backup").append(file.getProjectRelativePath().removeLastSegments(1)).toOSString();
				//String folder = showDirChooser(path);
				//if (folder != null)
				new «backupGenerator.nameWithoutExtension»().doGenerate(file, file.getProjectRelativePath().removeLastSegments(1).toOSString());
			}
		}
	}
	
	private String showDirChooser(String path) {
		InputDialog dlg = new InputDialog(Display.getCurrent().getActiveShell(),
            "Generate Backup", "Type a project-relative output folder", path, null);
        if (dlg.open() == Window.OK) {
          return dlg.getValue();
        } else return null;
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.sel = selection;
	}
}
'''
}