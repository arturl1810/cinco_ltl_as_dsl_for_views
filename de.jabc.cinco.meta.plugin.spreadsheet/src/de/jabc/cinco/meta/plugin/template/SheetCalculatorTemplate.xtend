package de.jabc.cinco.meta.plugin.template

import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode
import de.jabc.cinco.meta.plugin.spreadsheet.CalculatingEdge
import mgl.Node

class SheetCalculatorTemplate {

def create(String projectPath,String packageName,ArrayList<ResultNode> nodes, ArrayList<CalculatingEdge> edges,ArrayList<Node> allNodes,String graphName)
'''
package «packageName»;

import graphmodel.Edge;
import graphmodel.Node;

«FOR n :nodes»
import «projectPath».«n.nodeName.toFirstUpper»;
«ENDFOR»
«FOR e :edges»
import «projectPath».«e.name.toFirstUpper»;
«ENDFOR»

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.usermodel.Cell;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.widgets.Display;

public class SheetCalculator {
	/**
	 * Recursively Calculate all result-nodes depending on the initial node actNode
	 * @param actNode
	 * @param knownNodes
	 * @throws CalculationException
	 */
	public void topologicCalc(Node actNode,ArrayList<String> knownNodes) throws CalculationException
	{
		
		//Abbruch bedingung
		//Wenn ich keine Resultnode bin
		if(!(
			«FOR n : nodes»
			actNode instanceof «n.nodeName.toFirstUpper» ||
			«ENDFOR»
			false
			))
		{
			return;
		}
		
		//Oder wenn ich bereits bekannt bin
		if(knownNodes.contains(NodeUtil.getId(actNode))) {
			return;
		}
		
		knownNodes.add(NodeUtil.getId(actNode));
		//Für jede ausgehende Calculating Edge
		for(Edge edge : actNode.getOutgoing()) {
			«FOR e : edges»
			if(edge instanceof «e.name.toFirstUpper») {
				topologicCalc(edge.getTargetElement(), knownNodes);
				continue;
			}
			«ENDFOR»
		}
		//When all Traget-Nodes are calculated
		//Calculat myself
		calculateNode(actNode,null);
		
	}
	
	/**
	 * Calculates all result Attributes of the given 
	 * @param source
	 * @param resultAttrs
	 * @return 
	 * @throws CalculationException 
	 */
	public HashMap<String, Double> calculateNode(final Node source,String sheetName) throws CalculationException
	{
		String resultNodeId = NodeUtil.getId(source);
		//Get Sheetname
		ArrayList<String> sheetNames = SheetHandler.getSheetNames(resultNodeId);
		if(sheetNames.isEmpty()){
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("For the Node: "+source+"\nNo Sheet is available.");
			throw ex;
		}
		if(sheetName==null){
			sheetName = sheetNames.get(0);
		}
		final ArrayList<String> resultAttrs = new ArrayList<String>();
		/**
		 * For every result Node
		 */
		«FOR n : nodes»
		if(source instanceof «n.nodeName.toFirstUpper») {
			«FOR attr : n.resultAttrNames»
			resultAttrs.add("«attr.toLowerCase»");
			«ENDFOR»
		}
		«ENDFOR»
		/**
		 *
		 */
		
		
		if(sheetName==null) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("For the Node: "+source+"\nNo sheet is generated");
			throw ex;
		}
		//Save the Formula and the Cell References from the sheet
		HashMap<String, String> formulas = importFormula(sheetName,resultNodeId,resultAttrs);
		if(formulas.isEmpty())
		{
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("For the Node: "+source+"\nFormula can not be read.");
			throw ex;
		}
		
		HashMap<Integer,Integer> oldCellReferences = importCellReferences(sheetName,resultNodeId);
		
		//Refresh the sheet and write it
		ArrayList<VersionNode> nodes = refreshSheet(source, sheetName,NodeUtil.getFormulaReferencedRows(new ArrayList<String>(formulas.values()),this.getUserCells(sheetName, resultNodeId)));
		
		exportSheet(nodes, sheetName, resultNodeId, formulas);
		//Import the new Cell References in the refreshed sheet
		HashMap<Integer,Integer> newCellReferences = importCellReferences(sheetName,resultNodeId);
		
		//Re-reference the formula
		formulas = NodeUtil.rereferenceFormula(formulas, oldCellReferences, newCellReferences,0,0);
		
		HashMap<Integer, Integer> rowRefs = NodeUtil.getRowRereferences(oldCellReferences,newCellReferences);
		
		//Export the re-referenced Formula to the sheet
		exportFormula(formulas,resultNodeId, sheetName,rowRefs);
		
		//Try to calculate the spreadsheet if it exists
		final HashMap<String,Double> results = calculateSheet(resultNodeId,sheetName,resultAttrs);
		if(results.isEmpty()) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("For the Node: "+source+"\nRereferenced Formula could not be exported");
			throw ex;
		}
		

		TransactionalEditingDomain domain = TransactionUtil.getEditingDomain(source);
				domain.getCommandStack().execute(new RecordingCommand(domain) {
					
					@Override
					protected void doExecute() {
						«FOR n : nodes»
						if(source instanceof «n.nodeName.toFirstUpper») {
						«FOR attr : n.resultAttrNames»
							((«n.nodeName.toFirstUpper») source).set«attr.toFirstUpper»(results.get("«attr.toLowerCase»"));
						«ENDFOR»
						}
						«ENDFOR»
						try {
							source.eResource().save(null);
						} catch (IOException e) {
							System.err.println("For the Node: "+source+"\nResult attributes could not been saved.");
						}
					}
				});
		return results;
	}
	
	private ArrayList<VersionNode> refreshSheet(Node node,String sheetname, ArrayList<Integer> cellReferencedRows) throws CalculationException{
		//Get Sheet
		HSSFSheet sheet = null;
		try {
			sheet = Spreadsheetimporter.importSheet(sheetname,NodeUtil.getId(node));
		} catch (ClassNotFoundException | ClassCastException | IOException e) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Sheet error.\nSheet could not been importet for refreshing.");
			throw ex;
		}
		//Get selected Nodes
		ArrayList<VersionNode> nodes = NodeUtil.getTransitionedNodes(node);
		return NodeUtil.getVersionNodes(sheet, nodes, node, cellReferencedRows);
	}

	private HashMap<String,String> importFormula(String sheetName, String resultNodeId,ArrayList<String> resultNodeAttributes) throws CalculationException
	{
		HashMap<String,String> formulas = new HashMap<String,String>();
		try {
			formulas = Spreadsheetimporter.importFormula(sheetName,resultNodeId,resultNodeAttributes);
		} catch (IOException | CalculationException | ClassNotFoundException | ClassCastException e1) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Formula error.\nFormula could not be read.");
			throw ex;
		}
		return formulas;
	}

	private HashMap<Integer, Integer> importCellReferences(String sheetName, String resultNodeId) throws CalculationException
	{
		HashMap<Integer, Integer> cellReferences = new HashMap<Integer,Integer>();
		try {
			cellReferences = NodeUtil.getCellReferences(Spreadsheetimporter.importSheet(sheetName,resultNodeId));
		} catch (IOException | ClassNotFoundException | ClassCastException e1) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Formula error.\nFormula cell references could not be read.");
			throw ex;
		}
		return cellReferences;
	}

	private void exportSheet(ArrayList<VersionNode> nodes, String sheetName,String resultNodeId, HashMap<String,String> formulas) throws CalculationException
	{
		try {
			SheetHandler.writeSheet(Spreadsheetexporter.export(nodes,formulas,Spreadsheetimporter.importUserCells(sheetName, resultNodeId)), resultNodeId, sheetName,true);
		} catch (IOException | ClassCastException | ClassNotFoundException e) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Sheet Error.\n Sheet could not been exportet.");
			throw ex;
		}
	}

	private void exportFormula(HashMap<String,String> formulas,String resultNodeId, String sheetName, HashMap<Integer, Integer> rowRefs) throws CalculationException
	{
		try {
			Spreadsheetexporter.writeFormula(resultNodeId,sheetName, formulas, rowRefs);
		} catch (IOException | ClassNotFoundException | ClassCastException e) {
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Formula Error.\nRe-Referenced Formula could not be written.\nFormula re-referencing failed.");
			throw ex;
		}
	}

	private HashMap<String,Double> calculateSheet(String resultNodeId, String sheetName,ArrayList<String> resultAttrNames) throws CalculationException
	{
		try{
			return Spreadsheetimporter.calculate(sheetName,resultNodeId,resultAttrNames);

		}catch(IOException | ClassNotFoundException | ClassCastException e){
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Calculation Error.\nSpreadsheet is not known.\nPlease generate a spreadsheet first.");
			throw ex;
		}catch(CalculationException ce){
			CalculationException ex =  (CalculationException) new CalculationException();
			ex.setMessage("Calculation Error.\nCalculation failed.\nPlease check your Formula.");
			throw ex;
		}
	}
	
	private ArrayList<Cell> getUserCells(String sheetName, String resultNodeId)
	{
		try {
			return Spreadsheetimporter.importUserCells(sheetName, resultNodeId);
		} catch (ClassNotFoundException | ClassCastException | IOException e) {
			MessageDialog.openError(Display.getCurrent().getActiveShell(), 
					"Error", 
					"Sheet error.\nUser written cells could not be importet.");
		}
		return new ArrayList<Cell>();
	}
}
'''
}