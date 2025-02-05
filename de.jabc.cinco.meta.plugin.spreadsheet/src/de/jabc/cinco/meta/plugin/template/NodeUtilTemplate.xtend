package de.jabc.cinco.meta.plugin.template

import de.jabc.cinco.meta.plugin.spreadsheet.CalculatingEdge
import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode
import java.util.ArrayList
import mgl.Node

import static extension de.jabc.cinco.meta.plugin.template.SpreadsheetUtil.getType

class NodeUtilTemplate {
	def create(String projectPath,String packageName,ArrayList<ResultNode> nodes, ArrayList<CalculatingEdge> edges,ArrayList<Node> allNodes,String graphName)'''
package «packageName»;

import graphmodel.Node;
import graphmodel.ModelElement;
«FOR n :allNodes»
import «projectPath».«n.name»;
«ENDFOR»
«FOR e :edges»
import «projectPath».«e.name»;
«ENDFOR»
import «projectPath».impl.«graphName.toLowerCase.toFirstUpper»FactoryImpl;

import java.util.HashMap;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.eclipse.emf.ecore.EStructuralFeature;


public class NodeUtil {
	public static ArrayList<VersionNode> getTransitionedNodes(Node eobject){
		ArrayList<VersionNode> nodes = new ArrayList<VersionNode>();
		«FOR n :  nodes»
		«printResultNode(n,edges)»
		«ENDFOR»
		return nodes;
	}
	
	public static String getId(ModelElement element)
	{
		return element.getId().hashCode()+"";
	}
	public static String getSheetMapFileName(String resultNodeId)
	{
		return "sheetmap.properties";
	}
	public static String getSheetFileName(String sheetName,String resultNodeId,int counter)
	{
		if(counter<=0){
			return sheetName+".xls";
		}
		return sheetName+"_"+counter+".xls";
	}
	
	public static ArrayList<VersionNode> getVersionNodes(HSSFSheet sheet, ArrayList<VersionNode> newNodes, Node resultNode, ArrayList<Integer> referencedRows) {
	ArrayList<VersionNode> vns = new ArrayList<>();
	
	//Put the new Nodes in a Hashmap based on their id
	HashMap<String, VersionNode> hashedNodes = new HashMap<String,VersionNode>();
	for (VersionNode vnode : newNodes) {
		hashedNodes.put(NodeUtil.getId(vnode.node), vnode);
	}

	//Search for old, removed and updated Nodes
	Iterator<Row> rows = sheet.rowIterator();
	
	String nodeName = null;
	
	while(rows.hasNext()){
		VersionNode vn = new VersionNode();
		Row row = rows.next();
		if(row.getCell(0)==null){
			continue;
		}
		Cell idCell = row.getCell(0);
		if(idCell.getCellType()==Cell.CELL_TYPE_STRING) {
			nodeName=idCell.getStringCellValue();
		}
		
		if(idCell.getCellComment()!=null){	
			
			String [] comment = idCell.getCellComment().getString().toString().split(":");
    		if(!comment[0].equals(Spreadsheetexporter.NodeId)) {
    			continue;
    		}
			
			String id = comment[1];
			
			if(hashedNodes.containsKey(id)){
				//Node is Found in XLS
				vn.node = hashedNodes.get(id).node;
				vn.edge = hashedNodes.get(id).edge;
				
				//Resultnodes 
				if(hashedNodes.get(id).status==NodeStatus.RESULT) {
					vn.status = NodeStatus.RESULT;
					vns.add(vn);
					hashedNodes.remove(id);
					continue;
				}
				//remove Node from the new Nodes list
				hashedNodes.remove(id);
				
				
				boolean updated = false;
				int attrCounter = 1;
				//Loop over all attributes of the Node
				for(EStructuralFeature eNode : vn.node.eClass().getEStructuralFeatures()){
					
					if(eNode.getName().equals("fixAttributes"))continue;
					
					String attrValue = vn.node.eGet(eNode).toString();
					Cell attrCell = row.getCell(attrCounter);
					//Check whether node attribute value has been updated
					if(attrCell.getCellType()==Cell.CELL_TYPE_BLANK) {
						if(!attrValue.isEmpty())updated=true;
					}
					if(attrCell.getCellType()==Cell.CELL_TYPE_BOOLEAN)
					{
						if(attrCell.getBooleanCellValue()!=Boolean.valueOf(attrValue))updated=true;
					}
					if(attrCell.getCellType()==Cell.CELL_TYPE_FORMULA)continue;
					if(attrCell.getCellType()==Cell.CELL_TYPE_ERROR)continue;
					if(attrCell.getCellType()==Cell.CELL_TYPE_NUMERIC) {
						try{
							double attrDouble = Double.parseDouble(attrValue);
							if(attrDouble != attrCell.getNumericCellValue())updated=true;
						}catch(NumberFormatException ex)
						{
							try{
								int attrInt = Integer.parseInt(attrValue);
								if(attrInt != new Double(attrCell.getNumericCellValue()).intValue())updated=true;
							}catch(NumberFormatException ex2){
								continue;
							}
						}
					}
					if(attrCell.getCellType()==Cell.CELL_TYPE_STRING) {
						if(!(attrValue.equals(attrCell.getStringCellValue())))updated=true;
					}
					
					attrCounter++;
				}
				
				if(updated){
					vn.status = NodeStatus.UPDATED;
				}
				else{
					//Check wheter Edge-Attributes has changed
					boolean edgeUpdated = false;
					attrCounter++;
					//Loop over all attributes of the Edge
					for(EStructuralFeature eEdge : vn.edge.eClass().getEStructuralFeatures()){
						
						if(eEdge.getName().equals("fixAttributes"))continue;
						if(vn.edge.eGet(eEdge)==null)continue;
						String attrValue = vn.edge.eGet(eEdge).toString();
						Cell attrCell = row.getCell(attrCounter);
						//Check whether node attribute value has been updated
						if(attrCell.getCellType()==Cell.CELL_TYPE_BLANK) {
							if(!attrValue.isEmpty())edgeUpdated=true;
						}
						if(attrCell.getCellType()==Cell.CELL_TYPE_BOOLEAN)
						{
							if(attrCell.getBooleanCellValue()!=Boolean.valueOf(attrValue))edgeUpdated=true;
						}
						if(attrCell.getCellType()==Cell.CELL_TYPE_FORMULA)continue;
						if(attrCell.getCellType()==Cell.CELL_TYPE_ERROR)continue;
						if(attrCell.getCellType()==Cell.CELL_TYPE_NUMERIC) {
							try{
								double attrDouble = Double.parseDouble(attrValue);
								if(attrDouble != attrCell.getNumericCellValue())edgeUpdated=true;
							}catch(NumberFormatException ex)
							{
								try{
								int attrInt = Integer.parseInt(attrValue);
								if(attrInt != new Double(attrCell.getNumericCellValue()).intValue())edgeUpdated=true;
								}catch(NumberFormatException ex2){
									continue;
								}
							}
						}
						if(attrCell.getCellType()==Cell.CELL_TYPE_STRING) {
							if(!(attrValue.equals(attrCell.getStringCellValue())))edgeUpdated=true;
						}
						
						attrCounter++;
					}
					if(edgeUpdated) {
						vn.status = NodeStatus.UPDATED;
					}
					else{
						vn.status = NodeStatus.OLD;
					}
				}
				vns.add(vn);
			}
			else
			{
				//Check wheter a missing node is no longer referenced by another cell formula
				if(referencedRows.contains(idCell.getRowIndex()+1)) {					
					Node missingNode = getNode(((graphmodel.GraphModel)resultNode.getContainer()), id);
					//System.out.println(missingNode);
					//Note is not in the Canvas and has to be read from the sheet
					if(missingNode==null) {
						missingNode=createNodeFromSheetRow(nodeName, row);
					}
					//If the node is still in the Graphmodel and has not been found yet
					if(missingNode!=null && !vns.contains(missingNode)) {
						vn.node = missingNode;
						vn.status = NodeStatus.REMOVED;
						vn.edge = null;
						vns.add(vn);
						
					}
				}
			}
		}
	}
	//Take the left, new nodes
	for(VersionNode vnode: hashedNodes.values()){
		VersionNode vn = new VersionNode();
		vn.node = vnode.node;
		vn.status = NodeStatus.NEW;
		vn.edge = vnode.edge;
		vns.add(vn);
	}
	return vns;
}
	
public static Node getNode(graphmodel.GraphModel graph,String id) {
	for(Node node : graph.getAllNodes()) {
		if(id.equals(NodeUtil.getId(node))){
			return node;
		}
	}
	return null;
}

public static HashMap<Integer, Integer> getCellReferences(HSSFSheet sheet)
{
	HashMap<Integer, Integer> cellRefs = new HashMap<Integer,Integer>();
	Iterator<Row> rows = sheet.rowIterator();
	while(rows.hasNext()){
		
		Row row = rows.next();
		if(row.getCell(0)==null){
			continue;
		}
		Cell idCell = row.getCell(0);
		if(idCell.getCellComment()!=null){
			String [] comment = idCell.getCellComment().getString().toString().split(":");
    		if(comment[0].equals(Spreadsheetexporter.NodeId)) {
				try{
					int id = Integer.parseInt(comment[1]);
					int rowIndex = idCell.getRowIndex() + 1; //Because Formula-Cell-Refs beginn at 1
					cellRefs.put(id, rowIndex);
				}catch(NumberFormatException ex){
					
				}
    		}
			
		}
	}
	return cellRefs;
}

/**
 * 
 * @param formulas
 * @param oldRefs
 * @param newRefs
 * @param pre
 * @param post
 * @return
 */
public static HashMap<String, String> rereferenceFormula(HashMap<String, String> formulas,HashMap<Integer, Integer> oldRefs ,HashMap<Integer, Integer> newRefs, int pre, int post)
{
	HashMap<Integer, Integer> rowRearange = new HashMap<Integer, Integer>();
	HashMap<String, String> rereferencedFormulas = new HashMap<String,String>();
	//Clone the formula
	for(Entry<String,String> formula: formulas.entrySet()) {
		StringBuffer refreshedFormula = new StringBuffer(formula.getValue());
		//Join the old and new CellReferences depending on the node-ids
		for(int id : oldRefs.keySet())
		{
			if(newRefs.get(id)!=null) {
				rowRearange.put(oldRefs.get(id), newRefs.get(id));
			}
		}
		//replace the Cell references in the formula with the new Cell References
		Pattern pattern = Pattern.compile("[a-zA-Z]+[0-9]+");
		//Sreach for the given cellRow in the Formula
		Matcher matcher = pattern.matcher(formula.getValue());
		int colOffset = 0;
		int offset = post-pre;
		while(matcher.find()) {
			int start = matcher.start();
			int end = matcher.end();
			String cellRef = matcher.group().toUpperCase();
			String cellCol = cellRef.replaceAll("\\d", "");
			String cellRow = cellRef.replaceAll("\\D+","");
			
			
			int row = Integer.parseInt(cellRow);
			
			//For usercell references
			if(row >= pre)
			{
				
				row += offset;
				refreshedFormula = refreshedFormula.replace(start+colOffset,end+colOffset,cellCol+row);
				if(cellRow.length() != new String(row+"").length()) {
					colOffset += new String(row+"").length() - cellRow.length();
				}
				
			}
			else
			{
				if(rowRearange.get(Integer.parseInt(cellRow))!=null) {
					refreshedFormula = refreshedFormula.replace(start+colOffset,end+colOffset,cellCol+rowRearange.get(Integer.parseInt(cellRow)));
				}
				if(cellRow.length() != new String(rowRearange.get(Integer.parseInt(cellRow))+"").length()) {
					colOffset += new String(rowRearange.get(Integer.parseInt(cellRow))+"").length() - cellRow.length();
				}
			}
			
			
		}
		
		rereferencedFormulas.put(formula.getKey(), refreshedFormula.toString());
		
	}
	
	return rereferencedFormulas;
	
}

/**
 * Returns a new Node for the given row in the sheet
 * @param nodeName
 * @param row
 * @return
 */
public static Node createNodeFromSheetRow(String nodeName,Row row) {
	«printNodes(allNodes,graphName)»
	return null;
}

/**
 * 
 * @param formula
 * @param offset
 * @param rowIndex 
 * @return
 */
public static String offsetFormula(String formula,int offset, int rowIndex,int preOffset)
{
	StringBuffer offsetFormula = new StringBuffer(formula);
	Pattern pattern = Pattern.compile("[a-zA-Z]+[0-9]+");
	//Sreach for the given cellRow in the Formula
	Matcher matcher = pattern.matcher(formula);
	int colOffset = 0;
	while(matcher.find()) {
		int start = matcher.start();
		int end = matcher.end();
		String cellRef = matcher.group().toUpperCase();
		String cellCol = cellRef.replaceAll("\\d", "");
		String cellRow = cellRef.replaceAll("\\D+","");
		int row = Integer.parseInt(cellRow);
		if(row >= preOffset) {
			row += offset;
			offsetFormula = offsetFormula.replace(start+colOffset,end+colOffset,cellCol+row);
			if(cellRow.length() != new String(row+"").length()) {
				colOffset += new String(row+"").length() - cellRow.length();
			}
		}

	}
	//System.out.println("Pre: "+formula);
	
	//System.out.println("Post: "+offsetFormula);
	return offsetFormula.toString();
}


/**
 * 
 * @param oldCellReferences
 * @param newCellReferences
 * @return
 */
public static HashMap<Integer,Integer> getRowRereferences(HashMap<Integer, Integer> oldCellReferences, HashMap<Integer, Integer> newCellReferences)
{
	HashMap<Integer,Integer> refs = new HashMap<Integer,Integer>();
	
	for(Entry<Integer, Integer> oldEntry : oldCellReferences.entrySet()) {
		if(newCellReferences.containsKey(oldEntry.getKey())) {
			refs.put(oldEntry.getValue(), newCellReferences.get(oldEntry.getKey()));
		}
	}
	
	return refs;
}

/**
 * 
 * @param formulas
 * @param userCells
 * @return
 */
public static ArrayList<Integer> getFormulaReferencedRows(ArrayList<String> formulas,ArrayList<Cell> userCells)
{
	//Add user Cell formulas to the List of formulas
	for(Cell cell : userCells) {
		if(cell.getCellType() == Cell.CELL_TYPE_FORMULA) {
			formulas.add(cell.getCellFormula());
		}
	}
	
	ArrayList<Integer> rows = new ArrayList<Integer>();
	
	Pattern pattern = Pattern.compile("[a-zA-Z]+[0-9]+");
	//Sreach for the given cellRow in the Formula
	for(String formula : formulas) {		
		Matcher matcher = pattern.matcher(formula);
		while(matcher.find()) {
			String cellRef = matcher.group().toUpperCase();
			String cellRow = cellRef.replaceAll("\\D+","");
			int row = Integer.parseInt(cellRow);
			if(!rows.contains(row)) {
				rows.add(row);
			}
		}
	}
	return rows;
}
}
	
	'''
	def printNodes(ArrayList<Node> nodes,String graphName)'''
	«FOR n : nodes»
	if(nodeName.equals("«n.name.toFirstUpper»"))
		{
			«n.name.toFirstUpper» node = new «graphName.toLowerCase.toFirstUpper»FactoryImpl().create«n.name.toFirstUpper»();
			node.setId(row.getCell(0).getCellComment().getString().toString());
			«var i = 1»
			«FOR attr: n.attributes»
			«IF !attr.getName().equals("fixAttributes")»
			«IF attr.type.equals("EInt") »
			node.set«attr.getName().toFirstUpper»(new Double(row.getCell(«i»).getNumericCellValue()).intValue());
			«ENDIF»
			«IF attr.type.equals("EDouble")»
			node.set«attr.getName().toFirstUpper»(row.getCell(«i»).getNumericCellValue());
			«ENDIF»
			«IF attr.type.equals("EBoolean")»
			node.set«attr.getName().toFirstUpper»(row.getCell(«i»).getBooleanCellValue());
			«ENDIF»
			«IF attr.type.equals("EString")»
			node.set«attr.getName().toFirstUpper»(row.getCell(«i»).getStringCellValue());
			«ENDIF»
			«ENDIF»
			«{i = i +1 ''}»
			«ENDFOR»
			return node;
		}
	«ENDFOR»
	'''
	
	def printResultNode(ResultNode node, ArrayList<CalculatingEdge> edges)'''
			if(eobject instanceof «node.nodeName»){
				«node.nodeName» node = («node.nodeName») eobject;
				VersionNode resVn = new VersionNode();
				resVn.edge=null;
				resVn.node=node;
				resVn.formulas = new HashMap<String,String>();
				resVn.status = NodeStatus.RESULT;
				nodes.add(resVn);
				for(graphmodel.Edge e:node.getOutgoing()){
					if(
					«FOR e : edges »
						e instanceof «e.name» ||
					«ENDFOR»
					false
					)
					{
						VersionNode vn = new VersionNode();
						vn.edge = e;
						vn.status = NodeStatus.OLD;
						vn.node = (Node) e.getTargetElement();
						nodes.add(vn);
					}
					
				}
			}'''
	
	def printEdgeCondition(String edgeName)'''
	e instanceof «edgeName»
	'''
}