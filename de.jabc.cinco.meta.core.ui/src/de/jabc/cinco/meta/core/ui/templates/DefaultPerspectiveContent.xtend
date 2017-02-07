package de.jabc.cinco.meta.core.ui.templates

import mgl.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.ui.IFolderLayout
import org.eclipse.ui.IPageLayout
import org.eclipse.ui.IPerspectiveFactory
import productDefinition.CincoProduct
import de.jabc.cinco.meta.runtime.xapi.FileExtension

class DefaultPerspectiveContent {
	
	static extension val FileExtension = new FileExtension
	
	def static generateDefaultPerspective(CincoProduct cp, IFile cpdFile) {
		var pName = cpdFile.project.name+".editor.graphiti"
'''package «pName»;

public class «cp.name.toFirstUpper»Perspective implements «IPerspectiveFactory.name» {
	
	public static final «String.name» ID_PERSPECTIVE = "«pName».«cp.name.toLowerCase»perspective";

	@Override
	public void createInitialLayout(«IPageLayout.name» layout) {
		layout.addView(«IPageLayout.name».ID_PROJECT_EXPLORER, «IPageLayout.name».LEFT, 0.25f, «IPageLayout.name».ID_EDITOR_AREA); 
		
		«IFolderLayout.name» checkViewFolder = layout.createFolder("de.jabc.cinco.meta.plugin.check", «IPageLayout.name».BOTTOM, 0.55f, «IPageLayout.name».ID_PROJECT_EXPLORER);
		checkViewFolder.addView("de.jabc.cinco.meta.plugin.mcam.runtime.views.CheckView");
		checkViewFolder.addView("org.eclipse.graphiti.ui.internal.editor.thumbnailview");
		
		«IFolderLayout.name» folderLayout = layout.createFolder("«pName».property", «IPageLayout.name».BOTTOM, 0.75f, «IPageLayout.name».ID_EDITOR_AREA);
		/** This command adds the common property view **/
		/*folderLayout.addView(«IPageLayout.name».ID_PROP_SHEET);*/
		folderLayout.addView("de.jabc.cinco.meta.core.ui.propertyview");
		folderLayout.addView(«IPageLayout.name».ID_PROBLEM_VIEW);
	}
	
}'''
}
	
	def static generateXMLPerspective(CincoProduct cp, String pName)'''
	<extension
		point="org.eclipse.ui.perspectives">
	<!--@CincoGen «cp.name.toUpperCase»-->
		<perspective
			class="«pName».editor.graphiti.«cp.name.toFirstUpper»Perspective"
			fixed="false"
			id="«pName».«cp.name.toLowerCase»perspective"
			«IF !cp.image16.isNullOrEmpty»
			icon=«cp.image16»
			«ENDIF»
			name="«cp.name.toFirstUpper» Perspective">
		</perspective>
	</extension>'''
	
	def static boolean isMCAMAnnotated(CincoProduct cp, IFile cpdFile) {
		for (mgl : cp.mgls) {
			var iRes = cpdFile.project.findMember(mgl.mglPath);
			if (iRes instanceof IFile) {
				var gm = iRes.getContent(GraphModel, 0)
				if (gm.annotations.exists[annot | annot.name.equals("mcam")])
					return true;
			}
		}
		return false
			
	}
}