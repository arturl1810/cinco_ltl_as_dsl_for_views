package de.jabc.cinco.meta.plugin.template

class PluginXMLTemplate {
	def createPlugin(String packageName,String xlsGenHandlerName,String xlsCalcHandlerName,String xlsOpeningHandlerName) '''
	
	<extension
point="org.eclipse.ui.menus">
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsgen"
label="Create XLS"
style="push">
<visibleWhen
 checkEnabled="false">
<with
variable="activeMenuSelection">
<iterate
ifEmpty="false"
operator="and">
<adapt
type="org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart">
</adapt>
<test
      forcePluginActivation="true"
      property="«packageName».canGenerate">
</test>
</iterate>
</with>
</visibleWhen>
</command>
</menuContribution>
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsopen"
label="Edit XLS"
style="push">
<visibleWhen
 checkEnabled="false">
<with
variable="activeMenuSelection">
<iterate
ifEmpty="false"
operator="and">
<adapt
type="org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart">
</adapt>
<test
      forcePluginActivation="true"
      property="«packageName».canEdit">
</test>
</iterate>
</with>
</visibleWhen>
</command>
</menuContribution>
<menuContribution
allPopups="false"
locationURI="popup:org.eclipse.ui.popup.any">
<command
commandId="xlsclac"
label="Calculate XLS"
style="push">
<visibleWhen
 checkEnabled="false">
<with
variable="activeMenuSelection">
<iterate
ifEmpty="false"
operator="and">
<adapt
type="org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart">
</adapt>
<test
      forcePluginActivation="true"
      property="«packageName».canCalculate">
</test>
</iterate>
</with>
</visibleWhen>
</command>
</menuContribution>
</extension>
<extension
point="org.eclipse.ui.commands">
<command
defaultHandler="«packageName».«xlsGenHandlerName.toFirstUpper»"
id="xlsgen"
name="CommandName1">
</command>
<command
defaultHandler="«packageName».«xlsOpeningHandlerName.toFirstUpper»"
id="xlsopen"
name="CommandName2">
</command>
<command
defaultHandler="«packageName».«xlsCalcHandlerName.toFirstUpper»"
id="xlsclac"
name="CommandName3">
</command>
</extension>
<extension
      point="org.eclipse.core.expressions.propertyTesters">
   <propertyTester
         class="«packageName».MenuPropertyTester"
         id="«packageName».menutester"
         namespace="«packageName»"
         properties="canGenerate,canEdit,canCalculate"
         type="org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart">
   </propertyTester>
</extension>

	'''
}