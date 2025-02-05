package de.jabc.cinco.meta.plugin.mcam.runtime.views.utils;

import graphmodel.GraphModel;

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.edit.domain.EditingDomain;
import org.eclipse.emf.edit.domain.IEditingDomainProvider;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.jface.wizard.IWizard;
import org.eclipse.swt.custom.BusyIndicator;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.ide.IDE;
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
	
	public static IEditorPart openEditor(GraphModel model) {
		IEditorPart iEditor = null;
		
		URI uri = EcoreUtil.getURI(model);
//		URI uri2 = model.eResource().getURI();
		
//		System.out.println("----------------------------------------------");
//		
//		System.out.println("uri1: " + uri);
//		System.out.println("filestring: " + uri.toFileString());
//		System.out.println("platformstring: " + uri.toPlatformString(true));
//		
//		System.out.println("uri2: " + uri2);
//		System.out.println("filestring: " + uri2.toFileString());
//		System.out.println("platformstring: " + uri2.toPlatformString(true));
		
		IFile iFile = null;
		Path path = null;
		if (uri.toPlatformString(true) != null) {
			path = new Path(uri.toPlatformString(true));
		} 
		if (uri.toFileString() != null) {
			IFile newFile = ResourcesPlugin.getWorkspace().getRoot().getFileForLocation(new Path(uri.toFileString()));
			path = new Path(newFile.getFullPath().toOSString());
		}
			
		if (path != null)
			iFile = ResourcesPlugin.getWorkspace().getRoot().getFile(path);
		
//		System.out.println(iFile);
		
		IWorkbenchPage page = PlatformUI.getWorkbench()
				.getActiveWorkbenchWindow().getActivePage();
		try {
			iEditor = IDE.openEditor(page, iFile);
		} catch (PartInitException e) {
			e.printStackTrace();
		}
		return iEditor;
	}
	
	public static void runBusy(Runnable runnable){
		BusyIndicator.showWhile(EclipseUtils.getDisplay(), runnable);
	}
	
	public static IFile getIFile(IEditorPart editor) {
		return (IFile) editor.getEditorInput().getAdapter(IFile.class);
	}
	
	public static Resource getResource(IEditorPart editor) {
		EditingDomain ed = getEditingDomain(editor);
		if (ed != null)
			return ed.getResourceSet().getResources().get(0);
		else return null;
	}
	
	public static EditingDomain getEditingDomain(IEditorPart editor) {
		return editor instanceof DiagramEditor
			? ((DiagramEditor) editor).getEditingDomain()
			: editor instanceof IEditingDomainProvider 
				? ((IEditingDomainProvider) editor).getEditingDomain()
				: null;
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