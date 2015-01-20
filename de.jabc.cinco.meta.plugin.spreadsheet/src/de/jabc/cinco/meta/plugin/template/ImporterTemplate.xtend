package de.jabc.cinco.meta.plugin.template

class ImporterTemplate {
	def create(String packageName)'''
package «packageName»;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.FormulaEvaluator;
import org.apache.poi.ss.usermodel.Row;

public class Spreadsheetimporter {

public static HashMap<String,Double> calculate(String sheetName, String resultNodeId, ArrayList<String> resultAttrNames) throws IOException, CalculationException, ClassNotFoundException, ClassCastException {
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	HashMap<String, Double> results = new HashMap<String,Double>();
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
     
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
	
    FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
    evaluator.evaluateAll();
    //Search for result node
    Iterator<Row> rowIterator = sheet.iterator();
    while(rowIterator.hasNext()) {
        Row row = rowIterator.next();
         //Check ID Cell
        Cell idCell = row.getCell(0);
        if(idCell!=null) {
        	if(idCell.getCellType()==Cell.CELL_TYPE_NUMERIC) {
        		if(idCell.getNumericCellValue() == Integer.parseInt(resultNodeId)) {
        			
        			//Node is Found
        			Iterator<Cell> cellIterator = row.cellIterator();
        	        while(cellIterator.hasNext()) {
        	        	Cell cell = cellIterator.next();
        	        	if(cell.getCellType()==Cell.CELL_TYPE_FORMULA) {
        	        		String attrName = sheet.getRow(row.getRowNum()-1).getCell(cell.getColumnIndex()).getStringCellValue();
        	        		if(resultAttrNames.contains(attrName)) {
        	        			switch (evaluator.evaluateFormulaCell(cell)) {
        	        	        case Cell.CELL_TYPE_BOOLEAN:
        	        	            System.out.println(cell.getBooleanCellValue());
        	        	            results.put(attrName,(cell.getBooleanCellValue()) ? 1.0 : 0.0);
        	        	            break;
        	        	        case Cell.CELL_TYPE_NUMERIC:
        	        	            System.out.println(cell.getNumericCellValue()+" "+cell.getCellFormula());
        	        	            results.put(attrName, cell.getNumericCellValue());
        	        	            break;
        	        	        case Cell.CELL_TYPE_STRING:
        	        	            System.out.println(cell.getStringCellValue());
        	        	            results.put(attrName, Double.parseDouble(cell.getStringCellValue()));
        	        	            break;
        	        	        case Cell.CELL_TYPE_BLANK:
        	        	            break;
        	        	        case Cell.CELL_TYPE_ERROR:
        	        	            System.out.println(cell.getErrorCellValue());
        	        	            break;

        	        	        // CELL_TYPE_FORMULA will never occur
        	        	        case Cell.CELL_TYPE_FORMULA: 
        	        	            break;
            	        		}
        	        			
        	        		}
	        	        }
	        		}
	        	}
	        }
        }
   }

	return results;
}

public static HSSFSheet importSheet(String sheetName, String resultNodeId) throws IOException, ClassNotFoundException, ClassCastException{
HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    return workbook.getSheetAt(0);
}

public static HSSFSheet importSheet(String sheetName, int sheetNumber, String resultNodeId) throws IOException, ClassNotFoundException, ClassCastException{
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    return workbook.getSheetAt(sheetNumber);
}

public static HashMap<String,String> importFormula(String sheetName, String resultNodeId,ArrayList<String> resultNodeAttrs) throws IOException, CalculationException, ClassNotFoundException, ClassCastException{
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	HashMap<String,String> formulas = new HashMap<String,String>();
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
    
    FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();

    
    Iterator<Row> rowIterator = sheet.iterator();
    while(rowIterator.hasNext()) {
        Row row = rowIterator.next();
         //Check ID Cell
        Cell idCell = row.getCell(0);
        if(idCell!=null) {
        	if(idCell.getCellType()==Cell.CELL_TYPE_NUMERIC) {
        		if(idCell.getNumericCellValue() == Integer.parseInt(resultNodeId)) {
        			
        			//Node is Found
        			Iterator<Cell> cellIterator = row.cellIterator();
        	        while(cellIterator.hasNext()) {
        	        	Cell cell = cellIterator.next();
        	        	String attrName = sheet.getRow(row.getRowNum()-1).getCell(cell.getColumnIndex()).getStringCellValue();
        	        	if(resultNodeAttrs.contains(attrName) && cell.getCellType()==Cell.CELL_TYPE_FORMULA) {
        	        		formulas.put(attrName, cell.getCellFormula());
        	        		switch (evaluator.evaluateFormulaCell(cell)) {
    	        	        case Cell.CELL_TYPE_BOOLEAN:
    	        	            System.out.println(cell.getBooleanCellValue());
    	        	            formulas.put(attrName, cell.getCellFormula());
    	        	            break;
    	        	        case Cell.CELL_TYPE_NUMERIC:
    	        	            System.out.println(cell.getNumericCellValue()+" "+cell.getCellFormula());
    	        	            formulas.put(attrName, cell.getCellFormula());
    	        	            break;
    	        	        case Cell.CELL_TYPE_STRING:
    	        	            System.out.println(cell.getStringCellValue());
    	        	            formulas.put(attrName, cell.getCellFormula());
    	        	            break;
    	        	        case Cell.CELL_TYPE_BLANK:
    	        	            break;
    	        	        case Cell.CELL_TYPE_ERROR:
    	        	            System.out.println(cell.getErrorCellValue());
    	        	            break;

    	        	        // CELL_TYPE_FORMULA will never occur
    	        	        case Cell.CELL_TYPE_FORMULA: 
    	        	            break;
        	        		}
        	        	}
	        	        
	        		}
	        	}
	        }
        }
   }
   return formulas;
}

}'''
}