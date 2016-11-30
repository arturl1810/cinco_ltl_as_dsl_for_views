package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import mgl.GraphModel
import org.eclipse.jface.wizard.WizardPage
import org.eclipse.core.resources.IContainer
import org.eclipse.swt.widgets.Text
import org.eclipse.swt.widgets.Button
import org.eclipse.swt.widgets.Composite
import org.eclipse.swt.layout.GridLayout
import org.eclipse.swt.widgets.Label
import org.eclipse.swt.layout.GridData
import org.eclipse.swt.SWT
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.CoreException
import org.eclipse.swt.events.SelectionListener
import org.eclipse.swt.events.SelectionEvent
import org.eclipse.swt.widgets.DirectoryDialog
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.swt.events.KeyListener
import org.eclipse.swt.events.KeyEvent

class NewDiagramWizardPageTmpl extends GeneratorUtils {
	
def generateNewDiagramWizardPage(GraphModel gm)
'''package «gm.packageName».wizard;

public class «gm.fuName»DiagramWizardPage extends «WizardPage.name» {

	private «IContainer.name» container;

	private «Text.name» dirText;
	private «Text.name» fileNameText;
	
	private «Button.name» browseButton;

	protected «gm.fuName»DiagramWizardPage(«String.name» pageName) {
		super(pageName);
		setTitle("Create new «gm.fuName» diagram");
		setMessage("Create a new diagram in an existing or new project");
	}

	public «String.name» getDirectory() {
		return dirText.getText();
	}
	
	public «String.name» getFileName() {
		return fileNameText.getText();
	}

	@Override
	public void createControl(«Composite.name» parent) {
		«Composite.name» composite = new «Composite.name»(parent, «SWT.name».NONE);
		«GridLayout.name» layout = new «GridLayout.name»(3, false);
		composite.setLayout(layout);
		
		«Label.name» projectLbl = new «Label.name»(composite, «SWT.name».NONE);
		projectLbl.setLayoutData(new «GridData.name»(«SWT.name».LEFT, «SWT.name».CENTER, false, false));
		projectLbl.setText("Di&rectory: ");

		dirText = new «Text.name»(composite, «SWT.name».BORDER);
		dirText.setLayoutData(new «GridData.name»(«SWT.name».FILL, «SWT.name».CENTER, true, false));
		dirText.setEditable(false);
		dirText.setEnabled(false);
				
		browseButton = new «Button.name»(composite, «SWT.name».PUSH);
		browseButton.setText("Brows&e...");
		browseButton.setLayoutData(new «GridData.name»(«SWT.name».CENTER, «SWT.name».CENTER, false, false));

		«Label.name» pNameLbl = new «Label.name»(composite, «SWT.name».NONE);
		pNameLbl.setLayoutData(new «GridData.name»(«SWT.name».LEFT, «SWT.name».CENTER, false, false));
		pNameLbl.setText("Fi&le name: ");
		
		fileNameText = new «Text.name»(composite, «SWT.name».BORDER);
		fileNameText.setLayoutData(new «GridData.name»(«SWT.name».FILL, «SWT.name».CENTER, true, false));
		fileNameText.setText("");
		
		dirText.addKeyListener(textKeyListener);
		fileNameText.addKeyListener(textKeyListener);
		browseButton.addSelectionListener(buttonListener);
		
		«IStructuredSelection.name» selection = null; 
		if (getWizard() instanceof «gm.fuName»DiagramWizard) 
			selection = ((«gm.fuName»DiagramWizard) getWizard()).getSelection();
		
		if (selection != null && selection.getFirstElement() instanceof «IContainer.name») {
			container = («IContainer.name») selection.getFirstElement();
			dirText.setText(container.getLocation().toOSString());
		}

		dialogChanged();
		
		setControl(composite);
	}
	
	private «String.name» validateProjectName() {
		«String.name» directory = dirText.getText();
		if (directory.isEmpty())
			return "Select existing project or enter new project name";
		else return null;
	}
	
	private «String.name» validateFileName() {
		«String.name» fileName = fileNameText.getText();
		«String.name» fileExtension = "somegraph";
		if (fileName.isEmpty()) {
			return "Enter file name";
		} else if (fileName.contains(".") && !fileName.endsWith(fileExtension)) {
			return "Worng file extension";
		} else return null;
	}
	
	private boolean checkFileExists() {
		«String.name» fileName = (fileNameText.getText().contains(".") ? fileNameText.getText() : fileNameText.getText().concat(".«gm.name.toLowerCase»"));
		try {
			if (container == null)
				return false;
			for («IResource.name» res : container.members()) {
				if (res.getName().equals(fileName)) 
					return true;
			}
		} catch («CoreException.name» e) {
			e.printStackTrace();
		}
		return false;
	}

	private void dialogChanged() {
		«String.name» projectNameError = validateProjectName();
		«String.name» fileNameError = validateFileName();
		boolean fileExists = checkFileExists();
		if (projectNameError != null) {
			updateStatus(projectNameError);
		} else if (fileNameError != null) {
			updateStatus(fileNameError);
		} else if (fileExists) {
			updateStatus("File already exists");
		}
		else updateStatus(null);
	}
	
	private void updateStatus(«String.name» msg) {
		setErrorMessage(msg);
		if (getContainer().getCurrentPage() != null) {
			getWizard().getContainer().updateMessage();
			getWizard().getContainer().updateButtons();
		}
		setPageComplete(getErrorMessage() == null);
	}
	
	
	private «SelectionListener.name» buttonListener = new «SelectionListener.name»() {
		
		@Override
		public void widgetSelected(«SelectionEvent.name» e) {
			«DirectoryDialog.name» dialog = new «DirectoryDialog.name»(getShell());
			dialog.setText("Select a directory");
			«String.name» rootLocation = «ResourcesPlugin.name».getWorkspace().getRoot().getLocation().toOSString();
			dialog.setFilterPath(rootLocation);
			«String.name» dirName = dialog.open();
			if (dirName != null) {
				dirText.setText(dirName);
			}
			dialogChanged();
		}
		
		@Override
		public void widgetDefaultSelected(«SelectionEvent.name» e) {
			
		}
	};
	
	
	private «KeyListener.name» textKeyListener = new «KeyListener.name»() {
		
		@Override
		public void keyReleased(«KeyEvent.name» e) {
			dialogChanged();
		}
		
		@Override
		public void keyPressed(«KeyEvent.name» e) {
			
		}
	};
}


'''
	
}