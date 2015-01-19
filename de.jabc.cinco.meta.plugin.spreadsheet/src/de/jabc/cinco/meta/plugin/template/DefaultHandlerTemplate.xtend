package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.CalculatingEdge
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode

class GenerationHandlerTemplate {
	def create(String projectPath,String packageName,String className,String sheetName,String fileName,ArrayList<ResultNode> nodes, ArrayList<CalculatingEdge> edges,boolean multiple)
	'''
package «packageName»;

import graphmodel.Node;

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

««««FOR e :edges»
«««import «projectPath».«e.name»;
««««ENDFOR»
«FOR n :nodes»
import «projectPath».«n.nodeName»;
«ENDFOR»

import java.io.IOException;
import java.util.ArrayList;

/**
 * Auto-generated Class
 * @author zweihoff
 *
 */
 @SuppressWarnings("restriction")
public class «className» implements IHandler {

@Override
public void addHandlerListener(IHandlerListener handlerListener) {

}

@Override
public void dispose() {

}

@Override
public Object execute(ExecutionEvent event) throws ExecutionException {
	IStructuredSelection selection = (IStructuredSelection) HandlerUtil.getActiveSite(event).getSelectionProvider().getSelection();
	
	
	if(selection == null){
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"No Nodes selected. Please select a Node.");
		return null;
	}
	if(!(selection.getFirstElement() instanceof ContainerShapeEditPart)){
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"No Nodes selected. Please select a Node.");
		return null;
	}
	ArrayList<VersionNode> nodes = new ArrayList<VersionNode>();
	
	String sheetName="";
	String resultNodeId=null;
	
	if(selection.getFirstElement() instanceof ContainerShapeEditPart){
			ContainerShapeEditPart cs = (ContainerShapeEditPart) selection.getFirstElement();
			EObject eobject=Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(cs.getPictogramElement());
	
	«FOR node : nodes»
	
	«printResultNode(node,edges,multiple)»
	
	«ENDFOR»
	
	}
	if(nodes.isEmpty()){
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"No Nodes selected. Please select a Node.");
		return null;
	}
	
	try {
		SheetHandler.writeSheet(Spreadsheetexporter.export(nodes,null), resultNodeId, sheetName);
	} catch (ClassNotFoundException | ClassCastException
			| IOException e1) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Sheet could not been generated");
		e1.printStackTrace();
	}
	
	try {
		
		Spreadsheetexporter.openFile(resultNodeId,sheetName);
	} catch (ClassNotFoundException | ClassCastException | IOException e) {
		MessageDialog.openError(Display.getCurrent().getActiveShell(), 
				"Error", 
				"Sheet could not been opend");
		e.printStackTrace();
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
}
	'''
	def printResultNode(ResultNode node, ArrayList<CalculatingEdge> edges, boolean multiple)'''
	if(eobject instanceof «node.nodeName»){
		final «node.nodeName» node = («node.nodeName») eobject;
		resultNodeId = NodeUtil.getId(node);
		sheetName = UserInteraction.getSheetNameForGeneration(node,«multiple»);
		if(sheetName == null || sheetName.isEmpty()){
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					"Please select a Sheetname.");
			return null;
		}
		nodes = NodeUtil.getTransitionedNodes((Node) eobject);
	}'''
	
}