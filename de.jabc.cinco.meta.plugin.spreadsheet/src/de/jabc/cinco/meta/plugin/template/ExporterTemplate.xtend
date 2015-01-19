package de.jabc.cinco.meta.plugin.template

class ExporterTemplate {
	def create(String packageName,String className,String graphName,String projectName,String fileName,String sheetName)
	'''
package «packageName»;

import graphmodel.ModelElement;

import java.awt.Desktop;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.util.HSSFColor;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.ClientAnchor;
import org.apache.poi.ss.usermodel.Comment;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Drawing;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.eclipse.emf.ecore.EStructuralFeature;

public class Spreadsheetexporter {

public static HSSFWorkbook export(ArrayList<VersionNode> nodes,String formular) throws FileNotFoundException{
	// create a new file
	// create a new workbook
	HSSFWorkbook workbook = new HSSFWorkbook();
	HSSFSheet sheet = workbook.createSheet("Sample sheet");
	
	//define Styles and fonts
	
	//Default FONT
	HSSFFont defaultfont = workbook.createFont();
	//NODE-HEADER FONT
	HSSFFont nodeHeaderfont = workbook.createFont();
	nodeHeaderfont.setColor(HSSFColor.GREY_80_PERCENT.index);
	nodeHeaderfont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	//EDGE-HEADER FONT
	HSSFFont edgeHeaderFont = workbook.createFont();
	edgeHeaderFont.setColor(HSSFColor.GREY_25_PERCENT.index);
	edgeHeaderFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	//ID FONT
	Font idFont = workbook.createFont();
	idFont.setColor(HSSFColor.GREY_25_PERCENT.index);
	
	
	//OLD Style
	HSSFCellStyle oldNodeStyle = workbook.createCellStyle();
	oldNodeStyle.setFont(defaultfont);
	//NEW Style
	HSSFCellStyle newNodeStyle = workbook.createCellStyle();
	newNodeStyle.setFillForegroundColor(HSSFColor.BRIGHT_GREEN.index);
	newNodeStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	newNodeStyle.setFont(defaultfont);
	//UPDATED Style
	HSSFCellStyle updatedNodeStyle = workbook.createCellStyle();
	updatedNodeStyle.setFillForegroundColor(HSSFColor.BLUE.index);
	updatedNodeStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	updatedNodeStyle.setFont(defaultfont);
	//REMOVED Style
	HSSFCellStyle removedNodeStyle = workbook.createCellStyle();
	removedNodeStyle.setFillForegroundColor(HSSFColor.RED.index);
	removedNodeStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	removedNodeStyle.setFont(defaultfont);
	//NODE HERADER Style
	HSSFCellStyle headerStyle = workbook.createCellStyle();
	headerStyle.setBorderBottom(CellStyle.BORDER_THIN);
	headerStyle.setFont(nodeHeaderfont);
	headerStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	headerStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	//EDGE-HEADER Style
	HSSFCellStyle edgeHeaderStyle = workbook.createCellStyle();
	edgeHeaderStyle.setFont(edgeHeaderFont);
	edgeHeaderStyle.setFillForegroundColor(HSSFColor.GREY_80_PERCENT.index);
	edgeHeaderStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	//ID Style
	HSSFCellStyle idStyle = workbook.createCellStyle();
    idStyle.setFont(idFont);
	
	//Create the Cells for the result
	Row row0 = sheet.createRow(0);
	Cell cellA1 = row0.createCell(0);
	cellA1.setCellValue("Result:");
	cellA1.setCellType(Cell.CELL_TYPE_STRING);
	cellA1.setCellStyle(headerStyle);
	Row row1 = sheet.createRow(1);
	Cell cellA2 = row1.createCell(0);
	if(formular!=null){
		cellA2.setCellFormula(formular);
		cellA2.setCellType(Cell.CELL_TYPE_FORMULA);
	}
	else{
		cellA2.setCellValue("Put your math here");
		cellA2.setCellType(Cell.CELL_TYPE_STRING);
	}
	
	
	//Create Drawing Patriarch
	Drawing drawing = sheet.createDrawingPatriarch();
	CreationHelper factory = sheet.getWorkbook().getCreationHelper();
	ClientAnchor anchor = factory.createClientAnchor();
	Comment comment = drawing.createCellComment(anchor);
	comment.setString(factory.createRichTextString("Metaaa"));
	comment.setVisible(true);
	comment.setAuthor("zweihoff");
	
	//Set Meta Info for Result cell
	cellA2.setCellComment(comment);
	
	//Put all nodes in a HashMap depending on its type
	Map<String, HashMap<String, ArrayList<VersionNode>>> orderedNodes = new HashMap<String,HashMap<String,ArrayList<VersionNode>>>();
	
	for(VersionNode vnode : nodes){
		
		String nodeTypeName = vnode.node.eClass().getName();
		//If the Node-type is known
		if(orderedNodes.containsKey(nodeTypeName)){
			//If the node is not missing and has no edge
			if(vnode.edge != null) {
				String edgeTypeName = vnode.edge.eClass().getName();
				//If the edge-type for this node is known
				if(orderedNodes.get(nodeTypeName).containsKey(edgeTypeName))
				{
					orderedNodes.get(nodeTypeName).get(edgeTypeName).add(vnode);
				}
				else
				{
					ArrayList<VersionNode> list = new ArrayList<VersionNode>();
					list.add(vnode);
					orderedNodes.get(nodeTypeName).put(edgeTypeName, list);
				}
			}
			//Node got no edge
			else {
				ArrayList<VersionNode> list = new ArrayList<VersionNode>();
				list.add(vnode);
				orderedNodes.get(nodeTypeName).put(" ", list);
			}
		}
		//Node is not known
		else{
			ArrayList<VersionNode> list = new ArrayList<VersionNode>();
			list.add(vnode);
			HashMap<String, ArrayList<VersionNode>> map= new HashMap<String,ArrayList<VersionNode>>();
			if(vnode.edge != null) {
				map.put(vnode.edge.eClass().getName(), list);
			}
			else {
				map.put(" ", list);
			}
			orderedNodes.put(nodeTypeName, map);
		}
	}
	
	//Create Sheet
	int rowOffset = 3, colOffset = 0, rowCounter = 0, stepOffset = 1, colCount = 2;
	
	/**
	 * CREATE NODE-TYPE AND EDGE-TYPE TABLES
	 */
	//For every node type
	for(Entry<String, HashMap<String, ArrayList<VersionNode>>> nodeList : orderedNodes.entrySet()){
		
		for(Entry<String,ArrayList<VersionNode>> edgeNodeList: nodeList.getValue().entrySet()) {
			//Print tableheader
			Row r = sheet.createRow(rowOffset+rowCounter);
			//Type Cell
			Cell type = r.createCell(colOffset);
			type.setCellValue(nodeList.getKey());
			type.setCellStyle(headerStyle);
			//Attr Names Cells
			int col=1;
			
			//Correct the amount of cols in use
			if(edgeNodeList.getValue().size()>colCount)colCount=edgeNodeList.getValue().size();
			//Node Header
			for(EStructuralFeature eNode : edgeNodeList.getValue().get(0).node.eClass().getEStructuralFeatures()){
				
				String attrname = eNode.getName();
				if(attrname.equals("fixAttributes"))continue;
				Cell attr = r.createCell(colOffset+col);
				attr.setCellStyle(headerStyle);
				attr.setCellType(HSSFCell.CELL_TYPE_STRING);
				attr.setCellValue(attrname);
				col++;
			}
			//Edge name
			Cell edgeType = r.createCell(colOffset+col);
			edgeType.setCellValue(edgeNodeList.getKey());
			edgeType.setCellStyle(edgeHeaderStyle);
			col++;
			//Edge header
			if(edgeNodeList.getValue().get(0).edge!=null) {
				for(EStructuralFeature eEdge : edgeNodeList.getValue().get(0).edge.eClass().getEStructuralFeatures()){
					
					String attrname = eEdge.getName();
					if(attrname.equals("fixAttributes"))continue;
					Cell attr = r.createCell(colOffset+col);
					attr.setCellStyle(edgeHeaderStyle);
					attr.setCellType(HSSFCell.CELL_TYPE_STRING);
					attr.setCellValue(attrname);
					col++;
				}
			}
			
			
			rowCounter++;
			//Print Values for NodeType
			for(VersionNode vnode : edgeNodeList.getValue()){
				//Print Attrvalues for Node
				Row rowValues = sheet.createRow(rowOffset+rowCounter);
				
				//Set Style for the Node
				HSSFCellStyle rowStyle = oldNodeStyle;
				//Set Style for Nodestatus
				if(vnode.status == NodeStatus.NEW){
					rowStyle = newNodeStyle;
				}
				else if(vnode.status == NodeStatus.UPDATED){
					rowStyle = updatedNodeStyle;
				}
				else if(vnode.status == NodeStatus.REMOVED) {
					rowStyle = removedNodeStyle;
				}
				
				//Print ID for Node
				Cell idCell = rowValues.createCell(0);
				idCell.setCellValue(Integer.parseInt(NodeUtil.getId(vnode.node)));
				idCell.setCellType(Cell.CELL_TYPE_NUMERIC);
				idCell.setCellStyle(idStyle);
				
				int colValues = 1;
				for(EStructuralFeature eNode : vnode.node.eClass().getEStructuralFeatures()){
					
					if(eNode.getName().equals("fixAttributes"))continue;
					
					Cell attr = rowValues.createCell(colOffset+colValues);
					attr.setCellStyle(rowStyle);
					writeAttribute(eNode, attr, vnode.node);
					colValues++;
				}
				//Print ID for Edge
				if(vnode.edge!=null){
					Cell edgeidCell = rowValues.createCell(colValues);
					edgeidCell.setCellValue(Integer.parseInt(NodeUtil.getId(vnode.edge)));
					edgeidCell.setCellType(Cell.CELL_TYPE_NUMERIC);
					edgeidCell.setCellStyle(idStyle);
					colValues++;
					//Print Edge-Attributes
					for(EStructuralFeature eNode : vnode.edge.eClass().getEStructuralFeatures()){
						
						if(eNode.getName().equals("fixAttributes"))continue;
						
						Cell attr = rowValues.createCell(colOffset+colValues);
						attr.setCellStyle(rowStyle);
						writeAttribute(eNode, attr, vnode.edge);
						colValues++;
					}
				}
				rowCounter++;
			}
		}
		rowCounter+=stepOffset;
		
	}
	
	//Adjust autosize of all used columns
	for(int i=0;i<=colCount+1;i++){
		sheet.autoSizeColumn((short)i);
	}
	
	System.out.println("XLS successfully created");
	return workbook;
	//return "succsessfully";
}

private static void writeAttribute(EStructuralFeature eNode,Cell attr, ModelElement element) {
	if(element.eGet(eNode)==null)return;;
	String attrValue = element.eGet(eNode).toString();
	
	if(element.eGet(eNode) instanceof Integer){
		attr.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
		attr.setCellValue(Integer.parseInt(attrValue));
	}
	else if(element.eGet(eNode) instanceof Boolean) {
		attr.setCellType(HSSFCell.CELL_TYPE_BOOLEAN);
		attr.setCellValue(Boolean.getBoolean(attrValue));
	}
	else if(element.eGet(eNode) instanceof Double){
		attr.setCellType(HSSFCell.CELL_TYPE_NUMERIC);
		attr.setCellValue(Double.parseDouble(attrValue));
	}
	else if(attrValue.isEmpty()) {
		attr.setCellType(HSSFCell.CELL_TYPE_BLANK);
		attr.setCellValue(attrValue);
	}
	else{
		attr.setCellType(HSSFCell.CELL_TYPE_STRING);
		attr.setCellValue(attrValue);
	}
}

/**
 * 
 * @param resultNodeId
 * @param sheetName
 * @param Formular
 * @throws IOException
 * @throws ClassNotFoundException
 * @throws ClassCastException
 */
public static void writeFormular(String resultNodeId,String sheetName, String Formular) throws IOException, ClassNotFoundException, ClassCastException 
{
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
    
    Cell formularCell = sheet.getRow(1).getCell(0);
    formularCell.setCellFormula(Formular);
    
    file.close();
    
    FileOutputStream outFile =new FileOutputStream(new File(map.get(sheetName)));
    workbook.write(outFile);
    outFile.close();
}
/**
 * 
 * @param resultNodeId
 * @param sheetName
 * @throws ClassNotFoundException
 * @throws ClassCastException
 * @throws IOException
 */
public static void openFile(String resultNodeId,String sheetName) throws ClassNotFoundException, ClassCastException, IOException
{
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	File file = new File(SheetHandler.getSheetFolderPath()+map.get(sheetName));
	Desktop dt = Desktop.getDesktop();
	try {
		dt.open(file);
	} catch (IOException e) {
		e.printStackTrace();
	}
}

}''' 
}