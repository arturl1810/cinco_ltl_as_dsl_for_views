package de.jabc.cinco.meta.plugin.template

class PluginXMLTemplate {
	def createPlugin(String packageName,String xlsGenHandlerName,String xlsCalcHandlerName) '''
	
	<extension
point="org.eclipse.ui.menus">
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsgen"
label="Create XLS"
style="push">
</command>
</menuContribution>
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsopen"
label="Edit XLS"
style="push">
</command>
</menuContribution>
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsclac"
label="Calculate XLS"
style="push">
</command>
</menuContribution>
</extension>
<extension
point="org.eclipse.ui.commands">
<command
defaultHandler="info.scce.cinco.product.flowgraph.plugin.spreadsheet.GenerationHandler"
id="xlsgen"
name="CommandName1">
</command>
<command
defaultHandler="info.scce.cinco.product.flowgraph.plugin.spreadsheet.OpeningHandler"
id="xlsopen"
name="CommandName2">
</command>
<command
defaultHandler="info.scce.cinco.product.flowgraph.plugin.spreadsheet.CalculatingHandler"
id="xlsclac"
name="CommandName3">
</command>
</extension>

	'''
}