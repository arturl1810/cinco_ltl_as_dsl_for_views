package de.jabc.cinco.meta.plugin.template

class SheetHandlerTemplate {
	def create(String packageName)'''
package «packageName»;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map.Entry;
import java.util.Properties;
import java.util.Set;

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
		
		return ResourcesPlugin.getWorkspace().getRoot().getLocation().toString()+"/"+projectName+"/sheets/";
	}
	
	/**
	 * Loads all known sheets for a result-node.
	 * The returned hash-map contains the name of the sheet and the hashed id of the file
	 * @param resultNodeId
	 * @return
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
			if(((String)entry.getKey()).equals(resultNodeId))
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
	public static void writeSheet(HSSFWorkbook workbook,String resultNodeId,String sheetName) throws ClassNotFoundException, ClassCastException, IOException
	{
		//Write the sheetmap
		HashMap<String,String> map = loadSheetMap(resultNodeId);
		map.put(sheetName, NodeUtil.getSheetFileName(sheetName, resultNodeId));
		writeSheetMap(map, resultNodeId);
		//Write the XLS
		File file = new File(getSheetFolderPath()+NodeUtil.getSheetFileName(sheetName, resultNodeId));
		FileOutputStream out = new FileOutputStream(file);
		try {
			workbook.write(out);
			out.close();
		} catch (IOException e) {
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
		}
		return sheetNames;
	}

	private static void writeSheetMap(HashMap<String,String> map,String resultNodeId) throws IOException
	{
		Set<Entry<Object,Object>> output = new HashSet<Entry<Object,Object>>();
		try{
			BufferedInputStream fin = new BufferedInputStream(new FileInputStream(getSheetFolderPath()+NodeUtil.getSheetMapFileName(resultNodeId)));
			Properties preProperties = new Properties();
			preProperties.load(fin);
			fin.close();
			//Save all not relevant entrys
			
			for (Entry<Object, Object> entry : preProperties.entrySet()) {
				if(!((String)entry.getKey()).equals(resultNodeId))
				{
					output.add(entry);
				}
				
			}
		}catch(IOException ex) {
			
		}
		
		//write new and old entries
		Properties properties = new Properties();
		for(Entry<String,String> entry : map.entrySet()){
			properties.put(resultNodeId, entry.getKey()+splitter+entry.getValue());
		}
		for(Entry<Object, Object> entry : output){
			properties.put(entry.getKey(),entry.getValue());
		}
		File sheetMap = new File(getSheetFolderPath());
		sheetMap.mkdirs();
		
		FileOutputStream fout = new FileOutputStream(getSheetFolderPath()+NodeUtil.getSheetMapFileName(resultNodeId));
		properties.store(fout, "Sheetmap");
		fout.close();
	}
	
	
}
'''
}