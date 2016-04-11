package de.jabc.cinco.meta.core.ge.generator.templates

import ProductDefinition.CincoProduct
import mgl.GraphModel
import org.eclipse.ui.IPerspectiveFactory
import org.eclipse.ui.IPageLayout
import org.eclipse.graphiti.ui.internal.editor.ThumbNailView
import org.eclipse.ui.IFolderLayout

class DefaultPerspectiveContent {
	
	def static generateDefaultPerspective(CincoProduct cp, GraphModel gm)
'''package «gm.package»;

public class «cp.name.toFirstUpper»Perspective implements «IPerspectiveFactory.name» {
	
	public static final «String.name» ID_PERSPECTIVE = "«gm.package».«cp.name.toLowerCase»perspective";

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
	
}'''
	
	def static generateXMLPerspective(CincoProduct cp, GraphModel gm)'''
	<extension
		point="org.eclipse.ui.perspectives">
	<!--@CincoGen «gm.name.toFirstUpper»-->
		<perspective
			class="«gm.package».«cp.name.toFirstUpper»Perspective"
			fixed="false"
			id="«gm.package».«cp.name.toLowerCase»perspective"
			icon=«cp.image32»
			name="«cp.name.toFirstUpper» Perspective">
		</perspective>
	</extension>'''
	
}