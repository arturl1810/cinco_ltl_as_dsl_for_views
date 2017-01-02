package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import org.eclipse.jface.wizard.Wizard
import org.eclipse.ui.INewWizard
import org.eclipse.jface.wizard.IWizardPage
import org.eclipse.jface.viewers.IStructuredSelection
import org.eclipse.ui.IWorkbench
import org.eclipse.jface.operation.IRunnableWithProgress
import org.eclipse.core.runtime.IProgressMonitor
import java.lang.reflect.InvocationTargetException
import org.eclipse.ui.WorkbenchException
import org.eclipse.core.resources.IWorkspaceRoot
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.resources.IResource
import org.eclipse.core.runtime.Path
import org.eclipse.core.resources.IContainer
import org.eclipse.core.runtime.IPath
import org.eclipse.core.resources.IFile
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.ui.IWorkbenchPage
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.ide.IDE
import java.io.IOException
import org.eclipse.ui.PartInitException
import org.eclipse.swt.widgets.Composite

class NewDiagramWizardTmpl extends GeneratorUtils{
	
/**
 * Generates the {@link Wizard} class code for the {@link GraphModel}.
 * 
 * @param gm The processed {@link GraphModel}
 */	
def generateNewDiagramWizard(GraphModel gm)
'''package «gm.packageName».wizard;

public class «gm.fuName»DiagramWizard extends «Wizard.name» implements «INewWizard.name» {

	private «IWizardPage.name» page;

	private «IStructuredSelection.name» ssel;
	
	public «gm.fuName»DiagramWizard() {
	}

	@Override
	public void addPages() {
		page = new «gm.fuName»DiagramWizardPage("new«gm.fuName»");
		addPage(page);
		
		super.addPages();
	}
	
	@Override
	public void init(«IWorkbench.name» workbench, «IStructuredSelection.name» selection
	) {
		ssel = selection;
	}

	@Override
	public boolean performFinish() {
		if (page instanceof «gm.fuName»DiagramWizardPage) {
			«gm.fuName»DiagramWizardPage p = («gm.fuName»DiagramWizardPage) page;
			final «String.name» dir = p.getDirectory();
			final «String.name» fileName = p.getFileName();
			«IRunnableWithProgress.name» operation = new «IRunnableWithProgress.name»() {
				
				@Override
				public void run(«IProgressMonitor.name» monitor) throws «InvocationTargetException.name»,
						«InterruptedException.name» {
					createDiagram(dir, fileName);
				}
			};
			
			try {
				getContainer().run(false, false, operation);
«««				//IWorkbenchWindow window = PlatformUI.getWorkbench().getActiveWorkbenchWindow(); 
«««				//PlatformUI.getWorkbench().showPerspective(SomeGraphPerspectiveFactory.ID_PERSPECTIVE, window);
			} catch («InvocationTargetException.name» | «InterruptedException.name» e) {
				e.printStackTrace();
				return false;
			}/* catch («WorkbenchException.name» e) {
				e.printStackTrace();
				return false;
			}*/
		}
		return true;
	}

	
	private void createDiagram(«String.name» dir, «String.name» fName) {
		«String.name» extension = "«gm.name.toLowerCase»";
		«String.name» fNameWithExt = (fName.contains(".")) ? fName : fName.concat("." + extension);
		«String.name» dName = fNameWithExt.split("\\.")[0];
		
		«IWorkspaceRoot.name» root = «ResourcesPlugin.name».getWorkspace().getRoot();
		«IResource.name» containerResource = root.getContainerForLocation(new «Path.name»(dir));
		if (containerResource instanceof «IContainer.name») {
			«IPath.name» filePath = new «Path.name»(containerResource.getFullPath().append(fNameWithExt).toOSString());
			«IFile.name» file = root.getFile(filePath);
			«URI.name» resUri = «URI.name».createPlatformResourceURI(filePath.toOSString() ,true);
			«Resource.name» res = new «ResourceSetImpl.name»().createResource(resUri);
			«Diagram.name» diagram = 
				«Graphiti.name».getPeService().createDiagram("«gm.fuName»", dName, true);
			«gm.beanPackage».«gm.fuName» graph = «gm.beanPackage».«gm.name.toLowerCase.toFirstUpper»Factory.eINSTANCE.create«gm.fuName»();
			graph.setId(«EcoreUtil.name».generateUUID());
			try {
				res.unload();
				res.getContents().add(diagram);
				res.getContents().add(graph);
				res.save(null);
				
				«IDiagramTypeProvider.name» dtp = «GraphitiUi.name».getExtensionManager().createDiagramTypeProvider(diagram, "«gm.packageName».«gm.fuName»DiagramTypeProvider");
«««				«gm.fuName»GraphitiUtils.addToResource(diagram, dtp.getFeatureProvider());
				dtp.getFeatureProvider().link(diagram, graph);


				res.save(null);

				«IWorkbenchPage.name» page = «PlatformUI.name».getWorkbench().getActiveWorkbenchWindow().getActivePage();
				
				«IDE.name».openEditor(page, file,"«gm.packageName».«gm.fuName»Editor", true);
				
			} catch («IOException.name» e) {
				e.printStackTrace();
			} catch («PartInitException.name» e) {
				e.printStackTrace();
			}
		}
		
	}
	
	public «IStructuredSelection.name» getSelection() {
		return this.ssel;
	}

	@Override
	public void createPageControls(«Composite.name» pageContainer) {
		super.createPageControls(pageContainer);
	}
	
	@Override
	public boolean canFinish() {
		return page.isPageComplete(); 
	}
		
}
'''
	
}