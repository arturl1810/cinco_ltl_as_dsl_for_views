package de.jabc.cinco.meta.plugin.ocl.service;

import graphmodel.ModelElement;

import java.io.IOException;
import java.util.ArrayList;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.BasicDiagnostic;
import org.eclipse.emf.common.util.Diagnostic;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.edit.ui.action.ValidateAction;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart;
import org.eclipse.graphiti.ui.internal.parts.DiagramEditPart;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.ui.IEditorReference;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;

@SuppressWarnings("restriction")
public class OCLValidateAction extends ValidateAction {
	
	public static String EcoreEditorID = "org.eclipse.emf.ecore.presentation.EcoreEditorID";
	
	private Diagnostic diagnostic;
	private IFile file;
	
	@Override
	public boolean updateSelection(IStructuredSelection selection){
		
		selectedObjects = new ArrayList<EObject>();
		
		if(selection instanceof TreeSelection) {
			TreeSelection ts = (TreeSelection) selection;
			IFile file = (IFile) ts.getFirstElement();
			URI createPlatformResourceURI = URI.createPlatformResourceURI(file.getFullPath().toOSString(), true);
			
			ResourceSet resSet = new ResourceSetImpl();
			Resource res = resSet.createResource(createPlatformResourceURI);
			try {
				res.load(null);
				selectedObjects.addAll(res.getContents());
				selectedObjects = EcoreUtil.filterDescendants(selectedObjects);
			} catch (IOException e) {
				return false;
			}
		return true;
		}
		
		if(selection.getFirstElement() instanceof ContainerShapeEditPart) {
			
			if(selection.getFirstElement() instanceof DiagramEditPart) {
				DiagramEditPart dep = (DiagramEditPart) selection.getFirstElement();
				for(PictogramElement pe : dep.getModelChildren()) {
					this.addLinkedPictogramElement(pe);
				}
				return true;
			}
			else {
				ContainerShapeEditPart cs = (ContainerShapeEditPart) selection.getFirstElement();
				this.addLinkedPictogramElement(cs.getPictogramElement());
				return true;
				
			}
		}
		return false;
	}
	
	private void addLinkedPictogramElement(PictogramElement pe){
		EObject eobject=Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
		selectedObjects.add(eobject);
	}
	
	@Override
	public void setActiveWorkbenchPart(IWorkbenchPart workbenchPart)
	{
		ISelection selection = workbenchPart.getSite().getPage().getSelection();
		IWorkbench iwb = workbenchPart.getSite().getWorkbenchWindow().getWorkbench();
		file = null;
		if(selection instanceof TreeSelection) {
			TreeSelection ts = (TreeSelection) selection;
			file = (IFile) ts.getFirstElement();
			
		}
		else if(selection instanceof IStructuredSelection) {
			IStructuredSelection iss = (IStructuredSelection) selection;
			if(iss.getFirstElement() instanceof DiagramEditPart || iss.getFirstElement() instanceof ContainerShapeEditPart) {
				DiagramEditor diagramEditor = (DiagramEditor) workbenchPart;
					
					if (diagramEditor.getDiagramEditorInput().getUri().isPlatformResource()) {
						String platformString = diagramEditor.getDiagramEditorInput().getUri().toPlatformString(true);
						file = (IFile) ResourcesPlugin.getWorkspace().getRoot().findMember(platformString);
					}
				
			}
		}
		if(file == null) {
			return;
		}
		IWorkbenchPart editorPart = getEcoreEditor(workbenchPart.getSite().getPage().getEditorReferences(),iwb,file);
		deleteAllMarkers();
		super.setActiveWorkbenchPart(editorPart);
	}
	
	private void deleteAllMarkers(){
		int depth = IResource.DEPTH_INFINITE;
		   try {
			   if(file.isAccessible()){
				   file.deleteMarkers(IMarker.PROBLEM, true, depth);				   
			   }
		   } catch (CoreException e) {
		      // something went wrong
		   }
	}
	
	private IWorkbenchPart getEcoreEditor(IEditorReference[] editorReferences,IWorkbench iwb,IFile file) {
		for(IEditorReference ier : editorReferences) {
			if(ier.getId().equals(EcoreEditorID)){
				return ier.getPart(true);
			}
		}
		try {
			return IDE.openEditor(iwb.getActiveWorkbenchWindow().getActivePage(), file, EcoreEditorID);
		
		} catch (PartInitException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	@Override
	public void handleDiagnostic(Diagnostic diagnostic) {
		setDiagnostic(diagnostic);
		if(diagnostic == null){
			//Internal Error
		}
		if(selectedObjects.size() == 1){
			String id = ((ModelElement) selectedObjects.get(0)).getId();
			//One Element is validated
			for(Diagnostic dia :diagnostic.getChildren()) {
				if(dia.getData().size() > 1) {
					ModelElement modelElement = (ModelElement) dia.getData().get(0);
					if(modelElement.getId().equals(id)){
						markError(modelElement,(BasicDiagnostic) dia);
					}
				}
			}
		}
		else{
			for(Diagnostic dia :diagnostic.getChildren()) {
				if(dia.getData().size() > 1) {
					ModelElement modelElement = (ModelElement) dia.getData().get(0);
					markError(modelElement,(BasicDiagnostic) dia);
				}
			}
		}
	}
	
	private synchronized void markError(ModelElement modelElement, BasicDiagnostic basicDiagnostic){
		System.out.println("modelFound");
		String ressource = modelElement.getClass().getSimpleName().replaceFirst("Impl", "");
		String description = ressource+ ": "+basicDiagnostic.getMessage();
		String location = basicDiagnostic.getException().getLocalizedMessage();
		try {
			IMarker marker = file.createMarker(IMarker.PROBLEM);
			marker.setAttribute(IMarker.MARKER, "OCL");
			marker.setAttribute(IMarker.USER_EDITABLE, false);
			marker.setAttribute(IMarker.MESSAGE, description);
	        marker.setAttribute(IMarker.LOCATION, location);
	        marker.setAttribute(IMarker.SEVERITY,IMarker.SEVERITY_ERROR);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}

	public Diagnostic getDiagnostic() {
		return diagnostic;
	}

	public void setDiagnostic(Diagnostic diagnostic) {
		this.diagnostic = diagnostic;
	}
	
	
}

