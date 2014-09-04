package de.jabc.cinco.meta.core.wizards.project;

import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

public class MainPage extends WizardPage {
	
	private Button[] radios = new Button[2];
	
	protected MainPage(String pageName) {
		super(pageName);
		setTitle("New Cinco Product Project");
		setDescription("Create new project from scratch or as example.");
	}

	@Override
	public void createControl(Composite parent) {
		Composite comp = new Composite(parent, SWT.NONE); 
		comp.setLayout(new GridLayout(2, false));
		
		Label lblChooseMode = new Label(comp, SWT.NONE);
		lblChooseMode.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblChooseMode.setText("Choose wizard mode");

	    radios[0] = new Button(comp, SWT.RADIO);
	    radios[0].setSelection(true);
	    radios[0].setText("Start New Cinco Product Project");
		radios[0].setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 2, 1));

	    radios[1] = new Button(comp, SWT.RADIO);
	    radios[1].setText("Initialize Example Project (Feature Showcase)");
		radios[1].setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 2, 1));
		
		//addListeners();
		initContents();
		setControl(comp);
		
	}

	private void initContents() {
		dialogChanged();
	}
	
	private void updateStatus(String msg) {
		setErrorMessage(msg);
		if (getContainer().getCurrentPage() != null) {
			getWizard().getContainer().updateMessage();
			getWizard().getContainer().updateButtons();
		}
		setPageComplete(getErrorMessage() == null);
	}
	
	private void dialogChanged() {
		updateStatus(null);
	}
	
	public boolean isCreateExample() {
		return radios[1].getSelection();
	}
	
}
