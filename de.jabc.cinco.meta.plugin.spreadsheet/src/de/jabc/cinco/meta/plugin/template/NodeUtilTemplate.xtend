package de.jabc.cinco.meta.plugin.template

import de.jabc.cinco.meta.plugin.spreadsheet.ResultNode
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.spreadsheet.CalculatingEdge

class NodeUtilTemplate {
	def create(String projectPath,String packageName,ArrayList<ResultNode> nodes, ArrayList<CalculatingEdge> edges)'''
	package «packageName»;

import graphmodel.Node;
«FOR n :nodes»
import «projectPath».«n.nodeName»;
«ENDFOR»
«FOR e :edges»
import «projectPath».«e.name»;
«ENDFOR»

import java.util.HashMap;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.eclipse.emf.ecore.EStructuralFeature;


public class NodeUtil {
	public static ArrayList<Node> getTransitionedNodes(Node eobject){
		ArrayList<Node> nodes = new ArrayList<>();
		«FOR n :  nodes»
		«printResultNode(n,edges)»
		«ENDFOR»
		return nodes;
	}
	
	public static String getNodeId(Node node)
	{
		return node.getX()+""+node.getY();//TODO ID-Change
	}
	public static String getSheetMapFileName(String resultNodeId)
	{
		return "rn"+resultNodeId+".rsltnd";
	}
	public static String getSheetFileName(String sheetName,String resultNodeId)
	{
		return sheetName+resultNodeId+".xls";
	}
	
	
	public static ArrayList<VersionNode> getVersionNodes(HSSFSheet sheet, ArrayList<Node> newNodes) {
		ArrayList<VersionNode> vns = new ArrayList<>();
		if(newNodes.isEmpty())return vns;
		
		//Put the new Nodes in a Hashmap based on their id
		HashMap<String, Node> hashedNodes = new HashMap<String,Node>();
		for (Node node : newNodes) {
			hashedNodes.put(NodeUtil.getNodeId(node), node);
		}

		//Search for old, removed and updated Nodes
		Iterator<Row> rows = sheet.rowIterator();
		while(rows.hasNext()){
			VersionNode vn = new VersionNode();
			Row row = rows.next();
			if(row.getCell(0)==null){
				continue;
			}
			Cell idCell = row.getCell(0);
			if(idCell.getCellType()==Cell.CELL_TYPE_NUMERIC){
				
				String id = new Double(idCell.getNumericCellValue()).intValue()+"";
				
				if(hashedNodes.containsKey(id)){ //TODO ID-Change
					//Node is Found in XLS
					vn.node = hashedNodes.get(id);
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
								int attrInt = Integer.parseInt(attrValue);
								if(attrInt != new Double(attrCell.getNumericCellValue()).intValue())updated=true;
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
						vn.status = NodeStatus.OLD;
					}
					vns.add(vn);
				}
				else
				{
					Node missingNode = getNode(((graphmodel.GraphModel)newNodes.get(0).getContainer()), id);
					System.out.println(missingNode);
					//If the node is still in the Graphmodel and has not been found yet
					if(missingNode!=null && !vns.contains(missingNode)) {
						vn.node = missingNode;
						vn.status = NodeStatus.REMOVED;
						vns.add(vn);
					}
					
				}
			}
		}
		//Take the left, new nodes
		for(Node node: hashedNodes.values()){
			VersionNode vn = new VersionNode();
			vn.node = node;
			vn.status = NodeStatus.NEW;
			vns.add(vn);
		}
		return vns;
	}
	
	public static Node getNode(graphmodel.GraphModel graph,String id) {
		for(Node node : graph.getAllNodes()) {
			if(id.equals(NodeUtil.getNodeId(node))){
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
			if(idCell.getCellType()==Cell.CELL_TYPE_NUMERIC){
				try{
					int id = new Double(idCell.getNumericCellValue()).intValue();
					int rowIndex = idCell.getRowIndex() + 1; //Because Formular-Cell-Refs beginn at 1
					cellRefs.put(id, rowIndex);
				}catch(NumberFormatException ex){
					
				}
				
			}
		}
		return cellRefs;
	}
	public static String rereferenceFormular(String formular,HashMap<Integer, Integer> oldRefs ,HashMap<Integer, Integer> newRefs)
	{
		HashMap<Integer, Integer> rowRearange = new HashMap<Integer, Integer>();
		//Clone the formular
		String refreshedFormular = new String(formular);
		//Join the old and new CellReferences depending on the node-ids
		for(int id : oldRefs.keySet())
		{
			if(newRefs.get(id)!=null) {
				rowRearange.put(oldRefs.get(id), newRefs.get(id));
			}
		}
		//replace the Cell references in the formular with the new Cell References
		Pattern pattern = Pattern.compile("[a-zA-Z]+[0-9]+");
		//Sreach for the given cellRow in the Formular
		Matcher matcher = pattern.matcher(formular);
		while(matcher.find()) {
			String cellRef = matcher.group().toUpperCase();
			String cellCol = cellRef.replaceAll("\\d", "");
			String cellRow = cellRef.replaceAll("\\D+","");
			if(rowRearange.get(Integer.parseInt(cellRow))!=null) {
				System.out.println("Replacing: "+cellRef+" with "+cellCol+" "+rowRearange.get(Integer.parseInt(cellRow)));
				refreshedFormular = refreshedFormular.replaceAll(cellRef, cellCol+rowRearange.get(Integer.parseInt(cellRow)));
			}
		}
		return refreshedFormular;
		
	}
}
	
	'''
	def printResultNode(ResultNode node, ArrayList<CalculatingEdge> edges)'''
			if(eobject instanceof «node.nodeName»){
				«node.nodeName» node = («node.nodeName») eobject;
				for(graphmodel.Edge e:node.getOutgoing()){
					if(
					«FOR e : edges »
						e instanceof «e.name» ||
					«ENDFOR»
					false
					)
					{
						nodes.add((Node) e.getTargetElement());
					}
					
				}
			}'''
	
	def printEdgeCondition(String edgeName)'''
	e instanceof «edgeName»
	'''
}