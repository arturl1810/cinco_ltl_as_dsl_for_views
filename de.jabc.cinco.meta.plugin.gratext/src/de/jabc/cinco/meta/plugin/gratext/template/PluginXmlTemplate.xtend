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
			id="«model.basePackage».«model.name»GratextBackupObjectContributor"
			adaptable="false"
			nameFilter="*«model.acronym»"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«backupAction.package».«backupAction.nameWithoutExtension»"
				id="«backupAction.package».«backupAction.nameWithoutExtension»"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png"
				label="Generate Backup">
			</action>
		</objectContribution>
		<objectContribution
			id="«model.basePackage».«model.name»GratextRestoreObjectContributor"
			adaptable="false"
			nameFilter="*«model.acronym»DL"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«backupAction.package».«restoreAction.nameWithoutExtension»"
				id="«backupAction.package».«restoreAction.nameWithoutExtension»"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png"
				label="Restore Model">
			</action>
		</objectContribution>
   </extension>
   <extension point="info.scce.cinco.gratext.backup">
      <!--@GratextGen «model.name»-->
		<client fileExtension="«model.acronym»" class="«backupAction.package».«backupAction.nameWithoutExtension»"/>
   </extension>
   <extension point="info.scce.cinco.gratext.restore">
      <!--@GratextGen «model.name»-->
		<client fileExtension="«model.acronym»DL" class="«restoreAction.package».«restoreAction.nameWithoutExtension»"/>
   </extension>
</plugin>
'''
}