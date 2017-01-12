package de.jabc.cinco.meta.core.ui.templates

import productDefinition.CincoProduct

class NewProjectWizardGenerator {

def static generateWizardJavaCode(CincoProduct cp, String pName) '''
		
package «pName»;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.wizard.Wizard;
import org.eclipse.jface.wizard.WizardPage;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchWizard;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.WorkbenchException;

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator;

public class «cp.name»ProjectWizard extends Wizard implements IWorkbenchWizard {

	CreateNewProjectPage newProjectPage = new CreateNewProjectPage("newProjectPage");

	@Override
	public void addPages() {		
		addPage(newProjectPage);
		super.addPages();
	}
		
	@Override
	public boolean canFinish() {
		return newProjectPage.isPageComplete();
	}
	
	@Override
	public boolean performFinish() {
				
		String projectName = newProjectPage.getProjectName();
		

		ProjectCreator.createPlainProject(
				projectName, 
				getNatures(), 
				new NullProgressMonitor(),
				Collections.emptyList(),
				true
				);		
		
		IWorkbench workbench = PlatformUI.getWorkbench();
		try {
			«IF (cp.defaultPerspective.nullOrEmpty)»
				workbench.showPerspective("«pName».«cp.name.toLowerCase»perspective", workbench.getActiveWorkbenchWindow());
			«ELSE»
				workbench.showPerspective("«cp.defaultPerspective»", workbench.getActiveWorkbenchWindow());
			«ENDIF»
		} catch (WorkbenchException e) {
			e.printStackTrace();
		}

		return true;		
		
	}
	
	private List<String> getNatures() {
		List<String> natures = new ArrayList<String>();
		natures.add("org.eclipse.xtext.ui.shared.xtextNature");
		return natures;
	}
	
	@Override
	public void init(IWorkbench workbench, IStructuredSelection selection) {
		setWindowTitle("New «cp.name» Project");
	}

	
	private class CreateNewProjectPage extends WizardPage {
		
		private Text txtProjectName;		
		
		protected CreateNewProjectPage(String pageName) {
			super(pageName);
			setTitle("New «cp.name» Project");
			setDescription("Initialize an empty «cp.name» project and switch to correct perspective");
			setPageComplete(false);
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
			

			
			addListeners();
			initContents();
			setControl(comp);
			
		}

		private void initContents() {			
			txtProjectName.setText("myProject");			
			dialogChanged();
		}
		
		private void addListeners() {			
			KeyListener pageCompleteValidationListener = new KeyListener() {
				
				@Override
				public void keyReleased(KeyEvent e) {
					dialogChanged();
				}
				
				@Override
				public void keyPressed(KeyEvent e) {
					// do nothing. wait for release.
				}
			};			
			
			txtProjectName.addKeyListener(pageCompleteValidationListener);
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
			String projectNameError = validateProjectName(txtProjectName.getText());			
			if (projectNameError != null)
				updateStatus(projectNameError);			
			else updateStatus(null);
		}
		
		public String getProjectName() {
			return txtProjectName.getText();
		}
		
		private String validateProjectName(String projectName) {
			if (projectName.isEmpty())
				return "Enter project name";
			IProject[] projects = ResourcesPlugin.getWorkspace().getRoot()
					.getProjects();
			for (IProject p : projects) {
				if (p.getName().equals(projectName))
					return "Project: " + projectName + " already exists";
			}
			if (projectName.matches(".*[:/\\\\\"&<>\\?#,;].*")) {
				return "The project name contains illegal characters (:/\"&<>?#,;)";
			}
			return null;
		}
		
		
	}
	
}
'''
	
	def static generateNewWizardXML(CincoProduct cp, String pName, String idString)'''
		<extension
			point="org.eclipse.ui.newWizards">
		«idString»
		<wizard
			category="de.jabc.cinco.meta.core.wizards.category.cinco"
			class="«pName».«cp.name»ProjectWizard"
			id="«pName».wizard.«cp.name.toLowerCase»project"
			«IF !cp.image16.isNullOrEmpty»
				icon=«cp.image16»
			«ENDIF»
			name="New «cp.name» Project">
		</wizard>
		</extension>
		'''
	
	def static generateNavigatorXML(CincoProduct cp, String pName, String idString)'''
	<extension
		point="org.eclipse.ui.navigator.navigatorContent">
	«idString»		
	<commonWizard
		menuGroupId="mgl"
		type="new"
		wizardId="«pName».wizard.«cp.name.toLowerCase»project">
		<enablement></enablement>
	</commonWizard>
	</extension>
	'''
	
}