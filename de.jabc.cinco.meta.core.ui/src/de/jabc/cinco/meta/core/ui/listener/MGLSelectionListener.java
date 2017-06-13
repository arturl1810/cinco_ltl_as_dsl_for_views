package de.jabc.cinco.meta.core.ui.listener;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IWorkbenchPart;
import productDefinition.CincoProduct;

public class MGLSelectionListener implements ISelectionListener{

	ISelection selection = null;
	IWorkbenchPart part = null;
	IFile selectedFile = null;
	private IFile selectedMGLFile = null;
	private CincoProduct selectedCPD;
	
	public static MGLSelectionListener INSTANCE = new MGLSelectionListener(); 
		
	private MGLSelectionListener(){}
	
	@Override
	public void selectionChanged(IWorkbenchPart part, ISelection selection) {
		if(selection instanceof IStructuredSelection && ((IStructuredSelection)selection).getFirstElement() instanceof IFile){
			if(((IFile)((IStructuredSelection)selection).getFirstElement()).getFileExtension().equals("cpd")){
				this.part = part;
				this.selection = (IStructuredSelection)selection;
				this.selectedFile = (IFile)((IStructuredSelection)selection).getFirstElement();
			}
		}
		
		if(selection==null){
			this.part = null;
			this.selection = null;
			this.selectedFile = null;
		}
		
	}
	
	public IFile getCurrentMGLFile(){
		return this.selectedMGLFile;
	}
	
	public void putMGLFile(IFile iFile){
		if(iFile.getFileExtension().equals("mgl"))
			this.selectedMGLFile = iFile;
	}
	
	public IFile getSelectedCPDFile(){
		return this.selectedFile;
	}
	
	
	public CincoProduct getSelectedCPD(){
		return this.selectedCPD;
	}

	public void setCurrentCPD(CincoProduct cpd) {
		this.selectedCPD = cpd;
		
	}
	
}