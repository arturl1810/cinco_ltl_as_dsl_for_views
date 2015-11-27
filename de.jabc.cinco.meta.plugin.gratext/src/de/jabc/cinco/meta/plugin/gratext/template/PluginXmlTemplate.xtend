package de.jabc.cinco.meta.plugin.gratext.template

class PluginXmlTemplate extends AbstractGratextTemplate {
		
def backupAction() {
	fileFromTemplate(BackupActionTemplate)
}

def restoreAction() {
	fileFromTemplate(RestoreActionTemplate)
}
		
override template()
'''	
<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.0"?>

<plugin>
   <extension point="org.eclipse.ui.popupMenus">
      <!--@GratextGen «model.name»-->
		<objectContribution
			adaptable="false"
			id="«model.basePackage».«model.name»ObjectContributor"
			nameFilter="*«model.acronym»"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«backupAction.package».«backupAction.nameWithoutExtension»"
				id="«backupAction.package».«backupAction.nameWithoutExtension»"
				label="Generate Backup">
			</action>
		</objectContribution>
   </extension>
   <extension point="info.scce.cinco.gratext.backup">
      <!--@GratextGen Data-->
		<client fileExtension="«model.acronym»" class="«backupAction.package».«backupAction.nameWithoutExtension»"/>
   </extension>
   <extension point="org.eclipse.ui.popupMenus">
      <!--@GratextGen «model.name»-->
		<objectContribution
			adaptable="false"
			id="«model.basePackage».«model.name»ObjectContributor"
			nameFilter="*«model.acronym»DL"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«backupAction.package».«restoreAction.nameWithoutExtension»"
				id="«backupAction.package».«restoreAction.nameWithoutExtension»"
				label="Restore Model">
			</action>
		</objectContribution>
   </extension>
    <extension point="info.scce.cinco.gratext.restore">
      <!--@GratextGen Data-->
		<client fileExtension="«model.acronym»DL" class="«restoreAction.package».«restoreAction.nameWithoutExtension»"/>
   </extension>
</plugin>
'''
}