package de.jabc.cinco.meta.plugin.template

class UserInteractionTemplate {
		def create(String packageName)'''
package «packageName»;

import graphmodel.Node;

import org.eclipse.jface.window.Window;
import org.eclipse.swt.widgets.Display;

import java.util.ArrayList;

public class UserInteraction {
	/**
	 * Let the User choose a new sheet-name
	 * @return
	 */
	public static String getNewSheetName(String resultNodeId) {
	    
	    String sheetName = null;
	    String errorMessage = "";
	    do{
	    	NewSheetDialog dialog = new NewSheetDialog(Display.getCurrent().getActiveShell(),errorMessage);
	    	dialog.create();
	    	
		    if(dialog.open()==Window.OK)
		    {
		    	sheetName = dialog.getSheetName();
		    	if(sheetName==null)return null;
		    	sheetName = sheetName.replaceAll("[^a-zA-Z0-9.-]", "_");
		    	System.out.println("User selected new Sheetname: "+sheetName);
		    }
		    else
		    {
		    	System.out.println("User canceld creation");
		    	return null;
		    }
		    errorMessage = "Your sheetname is already in use.";
	    }while(SheetHandler.containsSheet(resultNodeId, sheetName)==true || sheetName.isEmpty());
	    System.out.println("User Sheetname is OK");
	    //Write new sheetname to the sheetmap
	    
	    //SheetHandler.addSheet(resultNodeId,sheetName);
	    
	    return sheetName;
	}
	/**
	 * Let the user choose a sheet-name from the list
	 * OR a new Sheetname
	 * @param sheetNames
	 * @return
	 */
	public static String pickSheetName(ArrayList<String> sheetNames, String resultNodeId,boolean creationEnabled) {
		SelectSheetDialog dialog = new SelectSheetDialog(Display.getCurrent().getActiveShell(),resultNodeId,sheetNames,creationEnabled);
    	dialog.create();
	    if(dialog.open()==Window.OK)
	    {
	    	System.out.println("User chose a Sheet");
	    	return dialog.getSheetName();
	    }
	    System.out.println("User canceld selection.");
	    return null;
	    
	}
	public static String getSheetNameForGeneration(Node resultNode)
	{
		String resultNodeId = NodeUtil.getId(resultNode);
		ArrayList<String> sheetNames = SheetHandler.getSheetNames(resultNodeId); 
		//User Interaction
		if(sheetNames == null)
		{
			return UserInteraction.getNewSheetName(resultNodeId);
		}
		if(sheetNames.isEmpty())
		{
			return UserInteraction.getNewSheetName(resultNodeId);
		}
		return UserInteraction.pickSheetName(sheetNames,resultNodeId,true);
	}
	public static String getSheetNameForCalculation(Node resultNode)
	{
		String resultNodeId = NodeUtil.getId(resultNode);
		ArrayList<String> sheetNames = SheetHandler.getSheetNames(resultNodeId); 
		//User Interaction
		if(sheetNames == null)
		{
			return null;
		}
		if(sheetNames.isEmpty())
		{
			return null;
		}
		return UserInteraction.pickSheetName(sheetNames,resultNodeId,false);
	}
	

}

'''
}