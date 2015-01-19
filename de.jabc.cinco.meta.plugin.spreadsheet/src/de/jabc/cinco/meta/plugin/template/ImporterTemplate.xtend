package de.jabc.cinco.meta.plugin.template

class ImporterTemplate {
	def create(String packageName)'''
package «packageName»;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.HashMap;

import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.FormulaEvaluator;

public class Spreadsheetimporter {

public static double calculate(String sheetName,String resultNodeId) throws IOException, CalculationException, ClassNotFoundException, ClassCastException {
	double result = 0.0;
	HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
     
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
	
    FormulaEvaluator evaluator = workbook.getCreationHelper().createFormulaEvaluator();
    
    Cell resultCell = sheet.getRow(1).getCell(0);


    if(resultCell.getCellType() == Cell.CELL_TYPE_FORMULA)
    {
    	evaluator.evaluateFormulaCell(resultCell);
    	if(resultCell.getCachedFormulaResultType() == Cell.CELL_TYPE_STRING){
    		try
    		{
    			result = Double.parseDouble(resultCell.getStringCellValue());
    		}catch(NumberFormatException ex){
    			throw new CalculationException();
    		}
    		
    	}
    	else if(resultCell.getCachedFormulaResultType() == Cell.CELL_TYPE_NUMERIC) {
    		result = resultCell.getNumericCellValue();
    	}
    }
    else{
    	throw new CalculationException();
    }
	return result;
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

public static String importFormular(String sheetName, String resultNodeId) throws IOException, CalculationException, ClassNotFoundException, ClassCastException{
HashMap<String, String> map = SheetHandler.loadSheetMap(resultNodeId);
	
	FileInputStream file = new FileInputStream(new File(SheetHandler.getSheetFolderPath()+map.get(sheetName)));
    
    //Get the workbook instance for XLS file 
    HSSFWorkbook workbook = new HSSFWorkbook(file);
 
    //Get first sheet from the workbook
    HSSFSheet sheet = workbook.getSheetAt(0);
    
    Cell formularCell = sheet.getRow(1).getCell(0);
    if(!(formularCell.getCellType() == Cell.CELL_TYPE_FORMULA)){
    	throw new CalculationException();
    }
    
    return formularCell.getCellFormula();
}

}'''
}