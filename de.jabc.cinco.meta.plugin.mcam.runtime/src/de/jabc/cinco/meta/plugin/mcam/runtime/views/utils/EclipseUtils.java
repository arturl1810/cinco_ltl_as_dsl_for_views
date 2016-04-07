package de.jabc.cinco.meta.plugin.mcam.runtime.views.utils;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.swt.custom.BusyIndicator;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.wizards.IWizardDescriptor;

public class EclipseUtils {

	public static Display getDisplay() {
		Display display = Display.getCurrent();
		// may be null if outside the UI thread
		if (display == null)
			display = Display.getDefault();
		return display;
	}

	public static IWizard getWizard(String id) {
		// First see if this is a "new wizard".
		IWizardDescriptor descriptor = PlatformUI.getWorkbench()
				.getNewWizardRegistry().findWizard(id);
		// If not check if it is an "import wizard".
		if (descriptor == null) {
			descriptor = PlatformUI.getWorkbench().getImportWizardRegistry()
					.findWizard(id);
		}
		// Or maybe an export wizard
		if (descriptor == null) {
			descriptor = PlatformUI.getWorkbench().getExportWizardRegistry()
					.findWizard(id);
		}
		try {
			// Then if we have a wizard, open it.
			if (descriptor != null) {
				IWizard wizard = descriptor.createWizard();
				return wizard;
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	public static void runBusy(Runnable runnable){
		BusyIndicator.showWhile(EclipseUtils.getDisplay(), runnable);
	}
	
	public static IFile getIFile(IEditorPart editor) {
		return (IFile) editor.getEditorInput().getAdapter(IFile.class);
	}
	
	public static Resource getResource(IEditorPart editor) {
		Resource res = null;
		if (editor instanceof DiagramEditor) {
			DiagramEditor deditor = (DiagramEditor) editor;
			TransactionalEditingDomain ed = deditor.getEditingDomain();	
			ResourceSet rs = ed.getResourceSet();
			res = rs.getResources().get(0);
		}
		return res;
	}
	
	public static File getFile(IFile iFile) {
		String path = iFile.getRawLocation().toOSString();
		return new File(path);
	}
	
	public static Resource getResource(IFile iFile) {
		java.io.File file = EclipseUtils.getFile(iFile);

		// Obtain a new resource set
		ResourceSet resSet = new ResourceSetImpl();

		// Get the resource
		Resource resource = resSet.getResource(
				URI.createFileURI(file.getAbsolutePath()), true);

		return resource;
	}
	
}