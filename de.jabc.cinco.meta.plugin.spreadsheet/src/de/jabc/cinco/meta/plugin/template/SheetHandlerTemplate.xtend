package de.jabc.cinco.meta.plugin.template

class SheetHandlerTemplate {
	def create(String packageName)'''
package «packageName»;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;

public class SheetHandler {
	/**
	 * Loads all known sheets for a result-node.
	 * The returned hash-map contains the name of the sheet and the hashed id of the file
	 * @param resultNodeId
	 * @return
	 * @throws IOException 
	 * @throws ClassNotFoundException 
	 */
	@SuppressWarnings("unchecked")
	public static HashMap<String,String> loadSheetMap(String resultNodeId) throws IOException, ClassNotFoundException, ClassCastException
	{
		HashMap<String,String> map = null;
		FileInputStream fin = new FileInputStream(NodeUtil.getSheetMapFileName(resultNodeId));
		ObjectInputStream ois = new ObjectInputStream(fin);
		Object obj = ois.readObject();
		if(obj instanceof HashMap<?,?>)
		{
			map = (HashMap<String,String>) obj;
		}
		ois.close();
		return map;
	}
	/**
	 * Checks whether the given sheetName is already in use for the given resultnode
	 * @param resultNodeId
	 * @param sheetName
	 * @return
	 * @throws IOException 
	 * @throws ClassCastException 
	 * @throws ClassNotFoundException 
	 */
	public static boolean containsSheet(String resultNodeId,String sheetName)
	{
		HashMap<String, String> map;
		try {
			map = loadSheetMap(resultNodeId);
		} catch (ClassNotFoundException | ClassCastException | IOException e) {
			return false;
		}
		return map.containsKey(sheetName);
	}
	/**
	 * Writes a sheet with the given name and for the given result node.
	 * Check whether the sheet-name is already in use
	 * @param sheet
	 * @param resultNodeId
	 * @param sheetName
	 * @throws IOException 
	 * @throws ClassCastException 
	 * @throws ClassNotFoundException 
	 */
	public static void writeSheet(HSSFWorkbook workbook,String resultNodeId,String sheetName) throws ClassNotFoundException, ClassCastException, IOException
	{
		//Write the sheetmap
		HashMap<String,String> map = loadSheetMap(resultNodeId);
		map.put(sheetName, NodeUtil.getSheetFileName(sheetName, resultNodeId));
		writeSheetMap(map, resultNodeId);
		//Write the XLS
		File file = new File(NodeUtil.getSheetFileName(sheetName, resultNodeId));
		FileOutputStream out = new FileOutputStream(file);
		try {
			workbook.write(out);
			out.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("XLS and Sheetmap written");
	}
	/**
	 * Returns all known sheets.
	 * Returns null if there are no sheets for the given result-node
	 * @param resultNodeId
	 * @return
	 */
	public static ArrayList<String> getSheetNames(String resultNodeId) {
		ArrayList<String> sheetNames = new ArrayList<String>();
		try {
				sheetNames.addAll(loadSheetMap(resultNodeId).keySet());
		} catch (ClassNotFoundException | ClassCastException | IOException e) {
			System.out.println("No Sheet known for this Resultnode. I create a new one.");
			try {
				writeSheetMap(new HashMap<String,String>(),resultNodeId);
			} catch (IOException e1) {
				System.err.println("I Could not create a new SheetMap for resultnode: "+resultNodeId);
				return null;
			}
			e.printStackTrace();
		}
		return sheetNames;
	}

	
	private static void writeSheetMap(HashMap<String,String> map,String resultNodeId) throws IOException
	{
		FileOutputStream fout = new FileOutputStream(NodeUtil.getSheetMapFileName(resultNodeId));
		ObjectOutputStream oos = new ObjectOutputStream(fout);
		oos.writeObject(map);
		oos.close();
	}
	
	
}

'''
}