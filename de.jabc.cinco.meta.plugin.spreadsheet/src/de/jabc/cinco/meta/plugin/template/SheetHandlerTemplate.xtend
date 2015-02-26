package de.jabc.cinco.meta.plugin.template

class SheetHandlerTemplate {
	def create(String packageName, boolean multiple,String sheetFolderName)'''
package «packageName»;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map.Entry;
import java.util.Properties;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.ui.PlatformUI;

@SuppressWarnings("restriction")
public class SheetHandler {
	
	private static String splitter = ">>>";
	
	public static String getSheetFolderPath()
	{
		IProject project = null;
		Object element = null;
		String projectName= "";
		StructuredSelection sel = (StructuredSelection) PlatformUI.getWorkbench().getActiveWorkbenchWindow().getSelectionService().getSelection();
		if(sel.getFirstElement() instanceof ContainerShapeEditPart) {
			ContainerShapeEditPart csed = (ContainerShapeEditPart) sel.getFirstElement();
			element = ResourcesPlugin.getWorkspace().getRoot().findMember(
					csed.getPictogramElement().eResource().getURI().toPlatformString(true));
		}
		
		if(element instanceof IResource) {
			project = ((IResource) element).getProject(); 
			projectName = project.getName();
			try {
				((IResource) element).refreshLocal(IResource.DEPTH_ZERO, null);
			} catch (CoreException e) {
				System.err.println("Could not refresh Project.");
			}
		}
		
		return ResourcesPlugin.getWorkspace().getRoot().getLocation().toString()+"/"+projectName+"/«sheetFolderName»/";
	}
	
	/**
	 * Loads all known sheets for a result-node.
	 * The returned hash-map contains the name of the sheet and the hashed id of the file
	 * @param resultNodeId
	 * @return HashMap<sheetname,filename>
	 * @throws IOException 
	 * @throws ClassNotFoundException 
	 */
	public static HashMap<String,String> loadSheetMap(String resultNodeId) throws IOException, ClassNotFoundException, ClassCastException
	{
		HashMap<String,String> map = new HashMap<String,String>();
		BufferedInputStream fin = new BufferedInputStream(new FileInputStream(getSheetFolderPath()+NodeUtil.getSheetMapFileName(resultNodeId)));
		Properties properties = new Properties();
		properties.load(fin);
		fin.close();
		
		for (Entry<Object, Object> entry : properties.entrySet()) {
			if(((String)entry.getKey()).split(splitter)[1].equals(resultNodeId))
			{
				String[] sheets = ((String)entry.getValue()).split(splitter);
				if(sheets.length == 2) {
					map.put(sheets[0],sheets[1]);
				}
				
			}
			
		}
		
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
	public static void writeSheet(HSSFWorkbook workbook,String resultNodeId,String sheetName,boolean isEdition) throws ClassNotFoundException, ClassCastException, IOException
	{
		//Write the sheetmap
		//SINGLEMODE
		HashMap<String,String> map = new HashMap<String,String>();
		File file;
		//Check wheter filename is in use
		int counter = 0;
		
		if(!isEdition) {
			File f = new File(getSheetFolderPath()+NodeUtil.getSheetFileName(sheetName, resultNodeId, counter));
			if(f.exists()|| f.isDirectory()) {			
				do {
					counter++;
					f = new File(getSheetFolderPath()+NodeUtil.getSheetFileName(sheetName, resultNodeId, counter));
				}while(f.exists() || f.isDirectory());
			}
			
			map.put(sheetName, NodeUtil.getSheetFileName(sheetName, resultNodeId,counter));
			writeSheetMap(map, resultNodeId);			
			file = new File(getSheetFolderPath()+NodeUtil.getSheetFileName(sheetName, resultNodeId,counter));
		}
		else {
			map = loadSheetMap(resultNodeId);
			file = new File(getSheetFolderPath()+map.get(sheetName));
		}
		
		//Write the XLS
		FileOutputStream out = new FileOutputStream(file);
		try {
			workbook.write(out);
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		//System.out.println("XLS and Sheetmap written");
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
			//System.out.println("No Sheet known for this Resultnode. I create a new one.");
			try {
				writeSheetMap(new HashMap<String,String>(),resultNodeId);
			} catch (IOException e1) {
				System.err.println("I Could not create a new SheetMap for resultnode: "+resultNodeId);
				return null;
			}
		}
		return sheetNames;
	}

	/**
	 *
	 * @param map
	 * @param resultNodeId
	 * @throws IOException
	 */
	private static void writeSheetMap(HashMap<String,String> map,String resultNodeId) throws IOException
	{
		HashMap<String, String> output = new HashMap<String,String>();
		int i = 0;
		try{
			BufferedInputStream fin = new BufferedInputStream(new FileInputStream(getSheetFolderPath()+NodeUtil.getSheetMapFileName(resultNodeId)));
			Properties preProperties = new Properties();
			preProperties.load(fin);
			fin.close();
			//Save all not relevant entrys
			for (Entry<Object, Object> entry : preProperties.entrySet()) {
				if(!((String)entry.getKey()).split(splitter)[1].equals(resultNodeId) || «multiple»)
				{
						output.put(((String)entry.getKey()),(String) entry.getValue());
						i++;
					
				}
				
			}
			
		}catch(IOException ex) {
			
		}
		
		//write new and old entries
		Properties properties = new Properties();
		
		for(Entry<String, String> entry : output.entrySet()){
			properties.setProperty(entry.getKey(),entry.getValue());
		}
		
		for(Entry<String,String> entry : map.entrySet()){
			properties.put(i+splitter+resultNodeId, entry.getKey()+splitter+entry.getValue());
			i++;
		}
		
		File sheetMap = new File(getSheetFolderPath());
		sheetMap.mkdirs();
		
		FileOutputStream fout = new FileOutputStream(getSheetFolderPath()+NodeUtil.getSheetMapFileName(resultNodeId));
		properties.store(fout, "Sheetmap");
		fout.close();
	}
	
	public static HSSFWorkbook loadWorkbook(String path)
	{
	    try {
	    	FileInputStream file = new FileInputStream(new File(path));
			return new HSSFWorkbook(file);
		} catch (IOException e) {
			e.printStackTrace();
		}
	    return null;
	}
	
	
}
'''
}