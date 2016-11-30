package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import org.eclipse.ui.IPerspectiveFactory
import org.eclipse.ui.IPageLayout
import org.eclipse.graphiti.ui.internal.editor.ThumbNailView
import org.eclipse.ui.IFolderLayout

class PerspectiveTmpl extends GeneratorUtils{
	
def generatePerspective(GraphModel gm)
'''package «gm.packageName»;

public class «gm.fuName»PerspectiveFactory implements «IPerspectiveFactory.name» {

	public static final «String.name» ID_PERSPECTIVE = "«gm.package».«gm.name.toLowerCase»perspective";

	@Override
	public void createInitialLayout(«IPageLayout.name» layout) {
		layout.addView(«IPageLayout.name».ID_PROJECT_EXPLORER, «IPageLayout.name».LEFT, 0.25f, «IPageLayout.name».ID_EDITOR_AREA); 
		layout.addView(«ThumbNailView.name».VIEW_ID, «IPageLayout.name».BOTTOM, 0.55f, «IPageLayout.name».ID_PROJECT_EXPLORER);
		
		«IFolderLayout.name» folderLayout = layout.createFolder("«gm.package».«gm.name.toLowerCase».property", «IPageLayout.name».BOTTOM, 0.75f, «IPageLayout.name».ID_EDITOR_AREA);
		
		/** This command adds the common property view **/
		/*folderLayout.addView(«IPageLayout.name».ID_PROP_SHEET);*/
		folderLayout.addView("de.jabc.cinco.meta.core.ui.propertyview");
		folderLayout.addView(«IPageLayout.name».ID_PROBLEM_VIEW);
	}

}

'''
}