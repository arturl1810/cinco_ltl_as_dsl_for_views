package de.jabc.cinco.meta.core.wizards.project;

import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;

import de.jabc.cinco.meta.core.wizards.CincoWizardUtils;

public class CreateNewProjectPage extends WizardPage {
	
	private Button btnProjectAsPkg;

	private Text txtProjectName;
	private Text txtPackageName;
	private Text txtModelName;
	
	protected CreateNewProjectPage(String pageName) {
		super(pageName);
		setTitle("Start New Cinco Product Project");
		setDescription("Create new Cinco Product project with minimal required files");
	}

	@Override
	public void createControl(Composite parent) {
		Composite comp = new Composite(parent, SWT.NONE); 
		comp.setLayout(new GridLayout(2, false));
		
		Label lblProjectName = new Label(comp, SWT.NONE);
		lblProjectName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblProjectName.setText("&Project Name");
		
		txtProjectName = new Text(comp, SWT.BORDER);
		txtProjectName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		btnProjectAsPkg = new Button(comp, SWT.CHECK);
		btnProjectAsPkg.setSelection(true);
		btnProjectAsPkg.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnProjectAsPkg.setText("Use project name as package name");
		
		Label lblPackageName = new Label(comp, SWT.NONE);
		lblPackageName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblPackageName.setText("Package Name");
		
		txtPackageName = new Text(comp, SWT.BORDER);
		txtPackageName.setEnabled(false);
		txtPackageName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Label modelName = new Label(comp, SWT.NONE);
		modelName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		modelName.setText("Model &Name");
		
		txtModelName = new Text(comp, SWT.BORDER);
		txtModelName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		addListeners();
		initContents();
		setControl(comp);
		
	}

	private void initContents() {
		txtModelName.setText("SomeGraph");
		txtProjectName.setText("info.scce.cinco.product.somegraph");
		txtPackageName.setText("info.scce.cinco.product.somegraph");
		dialogChanged();
	}
	
	private void addListeners() {
		SelectionListener btnSelLis = new SelectionListener() {
			
			@Override
			public void widgetSelected(SelectionEvent e) {
				if (btnProjectAsPkg.getSelection()) {
					if (txtProjectName.getText() != null) {
						txtPackageName.setText(txtProjectName.getText());
					}
				}
				txtPackageName.setEnabled(!btnProjectAsPkg.getSelection());
			}
			
			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
				
			}
		};
		
		KeyListener txtProjectNameListener = new KeyListener() {
			
			@Override
			public void keyReleased(KeyEvent e) {
				if (btnProjectAsPkg.getSelection()) {
					txtPackageName.setText(txtProjectName.getText());
				}
			}
			
			@Override
			public void keyPressed(KeyEvent e) {
				// TODO Auto-generated method stub
				
			}
		};
		
		KeyListener pageCompleteValidationListener = new KeyListener() {
			
			@Override
			public void keyReleased(KeyEvent e) {
				dialogChanged();
			}
			
			@Override
			public void keyPressed(KeyEvent e) {
				// TODO Auto-generated method stub
				
			}
		};
		
		btnProjectAsPkg.addSelectionListener(btnSelLis);
		txtProjectName.addKeyListener(txtProjectNameListener);
		txtPackageName.addKeyListener(pageCompleteValidationListener);
		txtProjectName.addKeyListener(pageCompleteValidationListener);
		txtModelName.addKeyListener(pageCompleteValidationListener);
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
		String projectNameError = CincoWizardUtils.validateProjectName(txtProjectName.getText());
		String packageNameError = CincoWizardUtils.validatePackageName(txtPackageName.getText());
		String modelNameError = CincoWizardUtils.validateModelName(txtModelName.getText());
		if (projectNameError != null)
			updateStatus(projectNameError);
		else if (packageNameError != null)
			updateStatus(packageNameError);
		else if (modelNameError != null)
			updateStatus(modelNameError);
		else updateStatus(null);
	}
	
	public String getProjectName() {
		return txtProjectName.getText();
	}

	public String getPackageName() {
		return txtPackageName.getText();
	}

	public String getModelName() {
		return txtModelName.getText();
	}
	
}
