package de.jabc.cinco.meta.core.wizards.project;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.wizard.IWizardContainer;
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

public class NewMGLProjectWizardPage extends WizardPage {
	
	private Button btnProjectAsPkg;
	private Button btnGenerateAppearanceProvider;
	private Button btnGenerateCustomFeature;
	private Button btnGenerateCodeGenerator;
	private Button btnGenerateContainers;
	

	private Text txtProjectName;
	private Text txtPackageName;
	private Text txtModelName;
	
	protected NewMGLProjectWizardPage(String pageName) {
		super(pageName);
		setTitle("New MGL Project");
		setDescription("Create new MGL project with initial dummy model");
	}

	@Override
	public void createControl(Composite parent) {
		Composite comp = new Composite(parent, SWT.NONE); 
		comp.setLayout(new GridLayout(2, false));
		
		Label lblProjectName = new Label(comp, SWT.NONE);
		lblProjectName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblProjectName.setText("&Project Name:");
		
		txtProjectName = new Text(comp, SWT.BORDER);
		txtProjectName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		btnProjectAsPkg = new Button(comp, SWT.CHECK);
		btnProjectAsPkg.setSelection(true);
		btnProjectAsPkg.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnProjectAsPkg.setText("Use project name as package name");
		
		Label lblPackageName = new Label(comp, SWT.NONE);
		lblPackageName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblPackageName.setText("Package Name:");
		
		txtPackageName = new Text(comp, SWT.BORDER);
		txtPackageName.setEnabled(false);
		txtPackageName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Label modelName = new Label(comp, SWT.NONE);
		modelName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		modelName.setText("Model &Name");
		
		txtModelName = new Text(comp, SWT.BORDER);
		txtModelName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Label spacer = new Label(comp, SWT.SEPARATOR | SWT.HORIZONTAL);
		spacer.setLayoutData(new GridData(SWT.FILL, SWT.LEFT, true, false, 2,1));
		
		Label additionalsSection = new Label(comp, SWT.NONE);
		additionalsSection.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		additionalsSection.setText("Include additional example code snippets");
		
		btnGenerateContainers = new Button(comp, SWT.CHECK);
		btnGenerateContainers.setSelection(false);
		btnGenerateContainers.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnGenerateContainers.setText("&Container");
		
		btnGenerateAppearanceProvider = new Button(comp, SWT.CHECK);
		btnGenerateAppearanceProvider.setSelection(false);
		btnGenerateAppearanceProvider.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnGenerateAppearanceProvider.setText("&Appearance provider");
		
		btnGenerateCustomFeature = new Button(comp, SWT.CHECK);
		btnGenerateCustomFeature.setSelection(false);
		btnGenerateCustomFeature.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnGenerateCustomFeature.setText("Custom &feature");
		
		btnGenerateCodeGenerator = new Button(comp, SWT.CHECK);
		btnGenerateCodeGenerator.setSelection(false);
		btnGenerateCodeGenerator.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnGenerateCodeGenerator.setText("Code &generator");
		
		
		
		
		
		
		addListeners();
		initContents();
		setControl(comp);
		
	}

	private void initContents() {
		txtModelName.setText("SomeGraph");
		txtProjectName.setText("de.test.project");
		txtPackageName.setText("de.test.project");
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
	

	private String validateModelName() {
		if (txtModelName.getText() != null) {
			String modelName = txtModelName.getText();
			if (!modelName.isEmpty()) {
				if (modelName.contains(".") && !modelName.endsWith("mgl")) {
					return "Model name must end with \".mgl\"";
				}
			} else {
				return "Model name required!";
			}
		}
		return null;
	}



	private String validatePackageName() {
		if (txtPackageName != null) {
			String packageName = txtPackageName.getText();
			if (packageName.isEmpty())
				return "Enter package name";
		}
		return null;
	}



	private String validateProjectName() {
		if (txtProjectName != null) {
			String projectName = txtProjectName.getText();
			if (projectName.isEmpty())
				return "Enter project name";
			IProject[] projects = ResourcesPlugin.getWorkspace().getRoot()
					.getProjects();
			for (IProject p : projects) {
				if (p.getName().equals(projectName))
					return "Project: " + projectName + " already exists";
			}
			return null;
		}
		return null;
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
		String projectNameError = validateProjectName();
		String packageNameError = validatePackageName();
		String modelNameError = validateModelName();
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
