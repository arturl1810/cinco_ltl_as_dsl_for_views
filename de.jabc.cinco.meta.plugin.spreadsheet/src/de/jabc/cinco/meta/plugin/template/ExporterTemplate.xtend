package de.jabc.cinco.meta.plugin.template

class ExporterTemplate {
	def create(String packageName,String className,String graphName,String projectName,String fileName,String sheetName,int userCellsX, int userCellsY)
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
import java.util.Iterator;
import java.util.Map.Entry;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.TreeMap;

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
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.RichTextString;
import org.apache.poi.ss.usermodel.Row;
import org.eclipse.emf.ecore.EStructuralFeature;

public class Spreadsheetexporter {
	public static String NodeId = "NodeId";
	public static String EdgeId = "EdgeId";
	public static String Default = "Exported";
	public static int UserCellCols = «userCellsX»;
	public static int UserCellRows = «userCellsY»;

public static HSSFWorkbook export(ArrayList<VersionNode> nodes,HashMap<String,String> formulas,ArrayList<Cell> userCells) throws FileNotFoundException{
	// create a new file
	// create a new workbook
	HSSFWorkbook workbook = new HSSFWorkbook();
	HSSFSheet sheet = workbook.createSheet("Sample sheet");
	sheet.protectSheet("password");
	
	//define Styles and fonts
	
	//Default FONT
	HSSFFont defaultfont = workbook.createFont();
	//NODE-HEADER FONT
	HSSFFont nodeHeaderfont = workbook.createFont();
	nodeHeaderfont.setColor(HSSFColor.GREY_25_PERCENT.index);
	nodeHeaderfont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	//EDGE-HEADER FONT
	HSSFFont edgeHeaderFont = workbook.createFont();
	edgeHeaderFont.setColor(HSSFColor.GREY_80_PERCENT.index);
	edgeHeaderFont.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
	//ID FONT
	Font idFont = workbook.createFont();
	idFont.setColor(HSSFColor.GREY_25_PERCENT.index);
	
	//Formula Style
	HSSFCellStyle formulaStyle = workbook.createCellStyle();
	formulaStyle.setLocked(false);
	formulaStyle.setFont(defaultfont);
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
	headerStyle.setFillForegroundColor(HSSFColor.GREY_80_PERCENT.index);
	headerStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	//EDGE-HEADER Style
	HSSFCellStyle edgeHeaderStyle = workbook.createCellStyle();
	edgeHeaderStyle.setFont(edgeHeaderFont);
	edgeHeaderStyle.setFillForegroundColor(HSSFColor.GREY_25_PERCENT.index);
	edgeHeaderStyle.setFillPattern(CellStyle.SOLID_FOREGROUND);
	//ID Style
	HSSFCellStyle idStyle = workbook.createCellStyle();
    idStyle.setFont(idFont);
	
    //Create Drawing Patriarch
    Drawing drawing = sheet.createDrawingPatriarch();
    CreationHelper factory = workbook.getCreationHelper();
    
	//Put all nodes in a HashMap depending on its type
	TreeMap<String, HashMap<String, ArrayList<VersionNode>>> orderedNodes = new TreeMap<String,HashMap<String,ArrayList<VersionNode>>>(new ResultNodeComparator());
	
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
	//Sort the Map
	
	//Create Sheet
	int rowOffset = 0, colOffset = 0, rowCounter = 0, stepOffset = 0, colCount = 2;
	
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
			
			setCellComment(type,Default,"Header",factory,drawing);
			type.setCellValue(nodeList.getKey());
			type.setCellStyle(headerStyle);
			//Attr Names Cells
			int col=1;
			
			//Correct the amount of cols in use
			int colsInUse = edgeNodeList.getValue().get(0).node.eClass().getEStructuralFeatures().size();
			if(edgeNodeList.getValue().get(0).edge != null)colsInUse += edgeNodeList.getValue().get(0).edge.eClass().getEStructuralFeatures().size();
			if(colsInUse>colCount)colCount=colsInUse;
			
			//Node Header
			for(EStructuralFeature eNode : edgeNodeList.getValue().get(0).node.eClass().getEStructuralFeatures()){
				
				String attrname = eNode.getName();
				if(attrname.equals("fixAttributes"))continue;
				Cell attr = r.createCell(colOffset+col);
				
				setCellComment(attr,Default,"Header",factory,drawing);
				
				attr.setCellStyle(headerStyle);
				attr.setCellType(HSSFCell.CELL_TYPE_STRING);
				attr.setCellValue(attrname);
				col++;
			}
			//Edge name
			if((!edgeNodeList.getKey().equals(" ")) && edgeNodeList.getValue().get(0).status != NodeStatus.RESULT) {
				Cell edgeType = r.createCell(colOffset+col);
				
				setCellComment(edgeType,Default,"Header",factory,drawing);
				
				edgeType.setCellValue(edgeNodeList.getKey());
				edgeType.setCellStyle(edgeHeaderStyle);
				col++;
				//Edge header
				if(edgeNodeList.getValue().get(0).edge!=null) {
					for(EStructuralFeature eEdge : edgeNodeList.getValue().get(0).edge.eClass().getEStructuralFeatures()){
						
						String attrname = eEdge.getName();
						if(attrname.equals("fixAttributes"))continue;
						Cell attr = r.createCell(colOffset+col);
						
						setCellComment(attr,Default,"Header",factory,drawing);
						
						attr.setCellStyle(edgeHeaderStyle);
						attr.setCellType(HSSFCell.CELL_TYPE_STRING);
						attr.setCellValue(attrname);
						col++;
					}
				}
			}else {
				col++;
			}
			//writeUserCells(r, col, userCells);
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
				
				setCellComment(idCell,NodeId,NodeUtil.getId(vnode.node),factory,drawing);
				idCell.setCellStyle(rowStyle);
				
				int colValues = 1;
				for(EStructuralFeature eNode : vnode.node.eClass().getEStructuralFeatures()){
					
					if(eNode.getName().equals("fixAttributes"))continue;
					
					Cell attr = rowValues.createCell(colOffset+colValues);
					attr.setCellStyle(rowStyle);
					//Print Resultnodes
					if((!vnode.formulas.isEmpty()) || vnode.status==NodeStatus.RESULT) {
						
						setCellComment(attr,Default,"Formula",factory,drawing);
						
						if(formulas!=null && formulas.containsKey(eNode.getName())){
							attr.setCellFormula(formulas.get(eNode.getName()));
						}
						else{
							attr.setCellFormula(vnode.formulas.get(eNode.getName()));
						}
						attr.setCellStyle(formulaStyle);
						attr.setCellType(Cell.CELL_TYPE_FORMULA);
					}
					else{
						writeAttribute(eNode, attr, vnode.node,factory,drawing);
					}
					
					colValues++;
				}
				//Print ID for Edge
				if(vnode.edge!=null){
					Cell edgeidCell = rowValues.createCell(colValues);
					
					setCellComment(edgeidCell,EdgeId,NodeUtil.getId(vnode.edge),factory,drawing);

					edgeidCell.setCellStyle(rowStyle);
					colValues++;
					//Print Edge-Attributes
					for(EStructuralFeature eNode : vnode.edge.eClass().getEStructuralFeatures()){
						
						if(eNode.getName().equals("fixAttributes"))continue;
						
						Cell attr = rowValues.createCell(colOffset+colValues);
						attr.setCellStyle(rowStyle);
						writeAttribute(eNode, attr, vnode.edge,factory,drawing);
						colValues++;
					}
				}
				rowCounter++;
				//writeUserCells(rowValues, colValues, userCells);
			}
		}
		rowCounter+=stepOffset;
		
	}
	//Write divider for the user cells
	CellStyle borderStyle = workbook.createCellStyle();
	borderStyle.setBorderBottom(CellStyle.BORDER_DOUBLE);
	borderStyle.setBottomBorderColor(IndexedColors.BLACK.getIndex());
    Row divider = sheet.createRow(rowCounter);
    for(int i = 0; i <= colCount+2; i++) {
    	Cell dividerCell = divider.createCell(i);
    	dividerCell.setCellStyle(borderStyle);
    	setCellComment(dividerCell, "Divider", "EOF", factory, drawing);
    }
    rowCounter++;
	//Write the usercells
	writeUserCells(rowCounter, userCells, sheet, formulaStyle);
	
	
	//Adjust autosize of all used columns
	for(int i=0;i<=colCount+2;i++){
		sheet.autoSizeColumn((short)i);
	}
	
	//System.out.println("XLS successfully created");
	return workbook;
	//return "succsessfully";
}

private static void writeAttribute(EStructuralFeature eNode,Cell attr, ModelElement element, CreationHelper factory, Drawing drawing) {
	if(element.eGet(eNode)==null)return;
	
	setCellComment(attr,Default,"Value",factory,drawing);
	
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
 * @param rowRefs 
 * @param Formula
 * @throws IOException
 * @throws ClassNotFoundException
 * @throws ClassCastException
 */
public static void writeFormula(String resultNodeId,String sheetName, HashMap<String,String> formulas, HashMap<Integer, Integer> rowRefs) throws IOException, ClassNotFoundException, ClassCastException 
{
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
    
    Iterator<Row> rowIterator = sheet.iterator();
    while(rowIterator.hasNext()) {
        Row row = rowIterator.next();
		Iterator<Cell> cellIterator = row.cellIterator();
        while(cellIterator.hasNext()) {
        	Cell cell = cellIterator.next();
        	
        	if(cell.getCellComment()!=null) {
        		String [] comment = cell.getCellComment().getString().toString().split(":");
        		if(comment[1].equals(resultNodeId) && comment[0].equals(NodeId)) {
        			while(cellIterator.hasNext()) {
        				Cell resultCell = cellIterator.next();
        				String attrName = sheet.getRow(row.getRowNum()-1).getCell(resultCell.getColumnIndex()).getStringCellValue();
    		        	if(formulas.containsKey(attrName)){
    		        		resultCell.setCellValue("");
    		        		resultCell.setCellFormula(formulas.get(attrName));
    		        		resultCell.setCellType(Cell.CELL_TYPE_FORMULA);		
            	        }
        			}
        			break;
	    		}
    		}
        	else {
        		if(cell.getCellType() == Cell.CELL_TYPE_FORMULA) {
        			//Found User Cell Formula
        			StringBuffer formula = new StringBuffer(cell.getCellFormula());
        			//replace the Cell references in the formula with the new Cell References
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
        				if(rowRefs.containsKey(Integer.parseInt(cellRow))) {
        					formula = formula.replace(start+colOffset,end+colOffset,cellCol+rowRefs.get(Integer.parseInt(cellRow)));
	        				if(cellRow.length() < new String(rowRefs.get(Integer.parseInt(cellRow))+"").length()) {
	        					colOffset = new String(rowRefs.get(Integer.parseInt(cellRow))+"").length() - cellRow.length();
	        				}
        				}
        			}
        			cell.setCellFormula(formula.toString());
        		}
        	}
    	}
    }
   
    
    
    
    FileOutputStream outFile =new FileOutputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    workbook.write(outFile);
    file.close();
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
/**
 * 
 * @param cell
 * @param author
 * @param content
 * @param factory
 * @param drawing
 */
private static void setCellComment(Cell cell, String author,String content,CreationHelper factory, Drawing drawing)
{
	ClientAnchor anchor = factory.createClientAnchor();
	anchor.setCol1(cell.getColumnIndex());
	anchor.setCol2(cell.getColumnIndex()+1);
	anchor.setRow1(cell.getRowIndex());
	anchor.setRow2(cell.getRowIndex()+1);

    Comment comment = drawing.createCellComment(anchor);
    RichTextString str = factory.createRichTextString(author+":"+content);
    //comment.setAuthor(author);
    comment.setString(str);
	cell.setCellComment(comment);
}
/**
 * 
 * @param row
 * @param userCells
 * @param sheet
 */
private static void writeUserCells(int row,ArrayList<Cell> userCells, HSSFSheet sheet, HSSFCellStyle userCellStyle)
{
	//Sort by row and calculate offset
	int rowOffset = NodeUtil.getUserCellOffset(userCells, row);
	HashMap<Integer,ArrayList<Cell>> rowSorteteCellMap = new HashMap<Integer,ArrayList<Cell>>();
	for(Cell c : userCells) {
		
		if(!rowSorteteCellMap.containsKey(c.getRowIndex())) {
			rowSorteteCellMap.put(c.getRowIndex(), new ArrayList<Cell>());
		}
		rowSorteteCellMap.get(c.getRowIndex()).add(c);
	}
	//Write editable usercells
	for(int y=0; y< UserCellRows; y++) {
		Row userRow = sheet.createRow(row+y);
		for(int x=0; x<UserCellCols; x++) {
			Cell userCell = userRow.createCell(x);
			userCell.setCellStyle(userCellStyle);
		}
	}
	
	//Print Usercells
	for(Entry<Integer,ArrayList<Cell>> entry : rowSorteteCellMap.entrySet()) {
		Row userRow = sheet.createRow(entry.getKey() + rowOffset);
		for(Cell c : entry.getValue()) {
			Cell cell = userRow.createCell(c.getColumnIndex());
			cell.setCellType(c.getCellType());
			cell.setCellStyle(userCellStyle);
			switch (c.getCellType()) {
	        case Cell.CELL_TYPE_BOOLEAN:
	            cell.setCellValue(c.getBooleanCellValue());
	            break;
	        case Cell.CELL_TYPE_NUMERIC:
	            cell.setCellValue(c.getNumericCellValue());
	            break;
	        case Cell.CELL_TYPE_STRING:
	        	cell.setCellValue(c.getStringCellValue());
	            break;
	        case Cell.CELL_TYPE_BLANK:
	            break;
	        case Cell.CELL_TYPE_ERROR:
	            break;
	        case Cell.CELL_TYPE_FORMULA:
	        	cell.setCellFormula(NodeUtil.offsetFormula(c.getCellFormula(),rowOffset,row));
	            break;
    		}
		}
	}
}

}

''' 
}