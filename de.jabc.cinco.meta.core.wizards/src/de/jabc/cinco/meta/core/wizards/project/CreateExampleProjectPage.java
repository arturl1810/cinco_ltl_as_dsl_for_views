package de.jabc.cinco.meta.core.wizards.project;

import java.util.EnumSet;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

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

public class CreateExampleProjectPage extends WizardPage {
	
	private Button btnProjectAsPkg;
	private Map<ExampleFeature, Button> featureButtons;
	
	private Text txtProjectName;
	private Text txtPackageName;
	private Text txtModelName;
	
	protected CreateExampleProjectPage(String pageName) {
		super(pageName);
		setTitle("Initialize Showcase Project with Examples");
		setDescription("Create FlowGraph feature showcase project. Please read README.txt after project creation.");
		setPageComplete(false);
	}

	@Override
	public void createControl(Composite parent) {
		Composite comp = new Composite(parent, SWT.NONE); 
		comp.setLayout(new GridLayout(2, false));
		
		Label lblProjectName = new Label(comp, SWT.NONE);
		lblProjectName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblProjectName.setText("Project Name");
		
		txtProjectName = new Text(comp, SWT.BORDER);
		txtProjectName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		btnProjectAsPkg = new Button(comp, SWT.CHECK);
		btnProjectAsPkg.setSelection(true);
		btnProjectAsPkg.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		btnProjectAsPkg.setText("Use project name as package name");
		//FIXME: this is a temporary hack, as different project names and package names cause errors
		btnProjectAsPkg.setEnabled(false);
		
		Label lblPackageName = new Label(comp, SWT.NONE);
		lblPackageName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		lblPackageName.setText("Package Name");
		
		txtPackageName = new Text(comp, SWT.BORDER);
		txtPackageName.setEnabled(false);
		txtPackageName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Label modelName = new Label(comp, SWT.NONE);
		modelName.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, false, false, 1, 1));
		modelName.setText("Model name");
		
		txtModelName = new Text(comp, SWT.BORDER);
		txtModelName.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false, 1, 1));
		
		Label spacer = new Label(comp, SWT.SEPARATOR | SWT.HORIZONTAL);
		spacer.setLayoutData(new GridData(SWT.FILL, SWT.LEFT, true, false, 2,1));
		
		Label additionalsSection = new Label(comp, SWT.NONE);
		additionalsSection.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
		additionalsSection.setText("Include additional features");
		
		featureButtons = new HashMap<ExampleFeature, Button>();
		
		Button featureButton;
		for (ExampleFeature feature : ExampleFeature.values()) {
			featureButton = new Button(comp, SWT.CHECK);
			featureButton.setSelection(false);
			featureButton.setLayoutData(new GridData(SWT.LEFT, SWT.CENTER, true, false, 2, 1));
			featureButton.setText(feature.getLabel());
			featureButtons.put(feature, featureButton);
		}
		
		addListeners();
		initContents();
		setControl(comp);
		
	}

	private void initContents() {
		txtModelName.setText("FlowGraph");
		txtModelName.setEnabled(false);
		txtProjectName.setText("info.scce.cinco.product.flowgraph");
		txtPackageName.setText("info.scce.cinco.product.flowgraph");
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
	
	public boolean isFeatureSelected(ExampleFeature feature) {
		if (featureButtons.containsKey(feature)) {
			return featureButtons.get(feature).getSelection();
		}
		else {
			throw new IllegalArgumentException("no button for feature " + feature.toString() + " defined");
		}
	}
	
	public Set<ExampleFeature> getSelectedFeatures() {
		Set<ExampleFeature> selectedFeatures = EnumSet.noneOf(ExampleFeature.class);
		for (Entry<ExampleFeature, Button> buttonEntry : featureButtons.entrySet()) {
			ExampleFeature feature = buttonEntry.getKey();
			Button button = buttonEntry.getValue();
			if (button.getSelection()) {
				selectedFeatures.add(feature);
			}
		}
		return selectedFeatures;
	}
	
}
