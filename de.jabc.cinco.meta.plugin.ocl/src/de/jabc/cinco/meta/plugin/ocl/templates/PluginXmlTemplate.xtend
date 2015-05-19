package de.jabc.cinco.meta.plugin.ocl.templates

class PluginXmlTemplate {
	def create(String packageName)'''
   <extension
         point="org.eclipse.ui.popupMenus">
      <objectContribution
            objectClass="org.eclipse.core.resources.IFile"
            id="plugin.ocl.contribution">
         <menu
               label="OCL"
               path="additions"
               id="plugin.ocl.menu.file">
            <separator
                  name="group1">
            </separator>
         </menu>
         <action
               class="«packageName».ValidateAction"
               enablesFor="1"
               id="plugin.ocl.ValidateAction"
               label="Validate"
               menubarPath="plugin.ocl.menu.file/group1"
               tooltip="Validate the OCL-Expressions defined in the mgl">
         </action>
      </objectContribution>
   </extension>
   <extension
         point="org.eclipse.ui.popupMenus">
      <objectContribution
            adaptable="false"
            id="plugin.ocl.objectContribution"
            objectClass="org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart">
         <menu
               id="plugin.ocl.menu.element"
               label="OCL"
               path="additions">
            <groupMarker
                  name="group2">
            </groupMarker>
         </menu>
         <action
               class="«packageName».ValidateAction"
               enablesFor="1"
               id="plugin.ocl.ValidateAction.Element"
               label="Validate"
               menubarPath="plugin.ocl.menu.element/group2"
               tooltip="Validate the OCL-Expressions defined in the mgl">
         </action>
      </objectContribution>
   </extension>
	'''
}