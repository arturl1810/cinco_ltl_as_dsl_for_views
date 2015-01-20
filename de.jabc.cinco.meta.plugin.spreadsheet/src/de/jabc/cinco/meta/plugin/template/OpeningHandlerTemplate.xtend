package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class OpeningHandlerTemplate {
		def  create(String projectPath,String packageName,String className,String sheetName,String fileName,ArrayList<ResultNode> nodes)'''
package «packageName»;
	
import org.apache.poi.hssf.usermodel.HSSFSheet;
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

import graphmodel.Node;
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
public class OpeningHandler implements IHandler {

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
	
	String sheetName="";
	String resultNodeId = null;
	
	if(selection.getFirstElement() instanceof ContainerShapeEditPart){
			ContainerShapeEditPart cs = (ContainerShapeEditPart) selection.getFirstElement();
			EObject eobject=Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(cs.getPictogramElement());
			
			HashMap<Integer, Integer> oldCellReferences;
			HashMap<Integer, Integer> newCellReferences;
			
			ArrayList<VersionNode> nodes;
			HashMap<String,String> formulas;
			
			«FOR n : nodes»
			«printNodeCalculator(n)»
			«ENDFOR»
	}
	
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


private ArrayList<VersionNode> refreshSheet(Node node,String sheetname) throws IOException{
	//Get Sheet
	HSSFSheet sheet = null;
	try {
		sheet = Spreadsheetimporter.importSheet(sheetname,NodeUtil.getId(node));
	} catch (ClassNotFoundException | ClassCastException e) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Sheet error.\nSheet could not been importet for refreshing.");
	}
	//Get selected Nodes
	ArrayList<VersionNode> nodes = NodeUtil.getTransitionedNodes(node);
	return NodeUtil.getVersionNodes(sheet, nodes, node);
}

private HashMap<String,String> importFormular(String sheetName, String resultNodeId,ArrayList<String> resultNodeAttributes)
{
	HashMap<String,String> formulars = new HashMap<String,String>();
	try {
		formulars = Spreadsheetimporter.importFormular(sheetName,resultNodeId,resultNodeAttributes);
	} catch (IOException | CalculationException | ClassNotFoundException | ClassCastException e1) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Formular error.\nFormular could not be read.");
		return null;
	}
	return formulars;
}

private HashMap<Integer, Integer> importCellReferences(String sheetName, String resultNodeId)
{
	HashMap<Integer, Integer> cellReferences = null;
	try {
		cellReferences = NodeUtil.getCellReferences(Spreadsheetimporter.importSheet(sheetName,resultNodeId));
	} catch (IOException | ClassNotFoundException | ClassCastException e1) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Formular error.\nFormular cell references could not be read.");
		e1.printStackTrace();
		return null;
	}
	return cellReferences;
}

private ArrayList<VersionNode> getVersionNodes(Node node, String sheetName)
{
	ArrayList<VersionNode> nodes = null;
	try {
		nodes = refreshSheet(node, sheetName);
	} catch (IOException e) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Sheet Error.\n Nodes could not been read for versioning.");
		e.printStackTrace();
		return null;
	}
	return nodes;
}

private boolean exportSheet(ArrayList<VersionNode> nodes, String sheetName,String resultNodeId, HashMap<String,String> formulars)
{
	try {
		SheetHandler.writeSheet(Spreadsheetexporter.export(nodes,formulars), resultNodeId, sheetName);
	} catch (IOException | ClassCastException | ClassNotFoundException e) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Sheet Error.\n Sheet could not been exportet.");
		e.printStackTrace();
		return false;
	}
	return true;
}

private boolean exportFormular(HashMap<String,String> formulas,String resultNodeId, String sheetName)
{
	try {
		Spreadsheetexporter.writeFormular(resultNodeId,sheetName, formulas);
	} catch (IOException | ClassNotFoundException | ClassCastException e) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Formular Error.\nRe-Referenced Formular could not be written.\nFormular re-referencing failed.");
		e.printStackTrace();
		return false;
	}
	return true;
}

}
	'''
	
	def printNodeCalculator(ResultNode node)'''
	if(eobject instanceof «node.nodeName»){
		final «node.nodeName» node = («node.nodeName») eobject;
		resultNodeId = NodeUtil.getId(node);
		sheetName = UserInteraction.getSheetNameForCalculation(node);
		
		if(sheetName==null) {
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					"No Sheets for this resultnode.\n Please generate a sheet first.");
			return null;
		}
		ArrayList<String> resultAttrs = new ArrayList<String>();
		resultAttrs.add("cost");
		
		//Save the Formular and the Cell References from the sheet
		formulas = importFormular(sheetName,resultNodeId,resultAttrs);
		if(formulas.isEmpty())
		{
			openSheet(resultNodeId, sheetName);
			return null;
		}
		
		oldCellReferences = importCellReferences(sheetName,resultNodeId);
		
		//Refresh the sheet and write it
		nodes = getVersionNodes(node, sheetName);
		if(!exportSheet(nodes, sheetName, resultNodeId, formulas))
		{
			return null;
		}
		//Import the new Cell References in the refreshed sheet
		newCellReferences = importCellReferences(sheetName,resultNodeId);
		
		//Re-reference the formular
		formulas = NodeUtil.rereferenceFormular(formulas, oldCellReferences, newCellReferences);
		
		//Export the re-referenced Formular to the sheet
		if(!exportFormular(formulas,resultNodeId, sheetName))
		{
			return null;
		}
		openSheet(resultNodeId, sheetName);
	}
	'''
}