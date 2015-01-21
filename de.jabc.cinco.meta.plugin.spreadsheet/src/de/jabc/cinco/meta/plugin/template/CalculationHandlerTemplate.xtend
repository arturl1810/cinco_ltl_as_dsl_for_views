package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class CalculationHandlerTemplate {
	def  create(String projectPath,String packageName,String className,String sheetName,String fileName,ArrayList<ResultNode> nodes,boolean multiple)'''
package «packageName»;


import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.commands.IHandlerListener;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.handlers.HandlerUtil;

«FOR n :nodes»
import «projectPath».«n.nodeName»;
«ENDFOR»

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Auto-generated Class
 * @author zweihoff
 *
 */
 @SuppressWarnings("restriction")
public class CalculatingHandler implements IHandler {

	@Override
	public void addHandlerListener(IHandlerListener handlerListener) {
	
	}
	
	@Override
	public void dispose() {
	
	}
	
	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
	IStructuredSelection selection = (IStructuredSelection) HandlerUtil.getActiveSite(event).getSelectionProvider().getSelection();
		
		if(selection == null || !(selection.getFirstElement() instanceof ContainerShapeEditPart)){
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					"No Nodes selected. Please select a Node.");
			return null;
		}
		
		HashMap<String, Double> resulting = new HashMap<String, Double>();
		String sheetName ="";
		if(selection.getFirstElement() instanceof ContainerShapeEditPart){
				ContainerShapeEditPart cs = (ContainerShapeEditPart) selection.getFirstElement();
				EObject eobject=Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(cs.getPictogramElement());
				«FOR n : nodes»
				«printNodeCalculator(n,multiple)»
				«ENDFOR»
		}
		if(resulting.isEmpty()) {
			return null;
		}
«««		MessageDialog.openInformation(Display.getCurrent().getActiveShell(), 
«««				"Info", 
«««				"Spreadsheet: \""+sheetName+".xls\" was succsessfully calculated\nResults are:\n"+resulting.toString());
«««		
		return null;
	}
	@Override
	public boolean isEnabled() {
		return true;
	}
	
	@Override
	public boolean isHandled() {
		return true;
	}
	
	@Override
	public void removeHandlerListener(IHandlerListener handlerListener) {
	
	}
	private void openSheet(String resultNodeId,String sheetName)
	{
		try {
			Spreadsheetexporter.openFile(resultNodeId,sheetName);
		} catch (ClassNotFoundException | ClassCastException | IOException e) {
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					"Sheet Error.\nSheet could not been opend");
			e.printStackTrace();
		}
	}
}
	'''
	
	def printNodeCalculator(ResultNode node,boolean multiple)'''
	if(eobject instanceof «node.nodeName»){
		final «node.nodeName» node = («node.nodeName») eobject;
		sheetName = UserInteraction.getSheetNameForCalculation(node);
		SheetCalculator sc = new SheetCalculator();
		«IF !multiple»
		try {
			sc.topologicCalc(node, new ArrayList<String>());
		} catch (CalculationException e) {
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					e.getMessage());
			return null;
		}
		«ENDIF»
		try {
			«IF multiple»
			resulting = sc.calculateNode(node,sheetName);
			«ELSE»
			resulting = sc.calculateNode(node,null);
			«ENDIF»
		} catch (CalculationException e) {
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					e.getMessage());
			openSheet(NodeUtil.getId(node), sheetName);
			return null;
		}
	}
	'''
}