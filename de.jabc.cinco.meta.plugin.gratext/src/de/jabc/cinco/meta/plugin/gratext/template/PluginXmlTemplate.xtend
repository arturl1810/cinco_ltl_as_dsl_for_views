package de.jabc.cinco.meta.plugin.gratext.template

class PluginXmlTemplate extends AbstractGratextTemplate {
		
def backupAction() {
	fileFromTemplate(BackupActionTemplate) 
}

def restoreAction() {
	fileFromTemplate(RestoreActionTemplate)
}

def fileExtension() {
	graphmodel.fileExtension
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
			nameFilter="*«fileExtension»"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«backupAction.className»"
				id="«backupAction.className»"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png"
				label="Generate Backup">
			</action>
		</objectContribution>
		<objectContribution
			id="«model.basePackage».«model.name»GratextRestoreObjectContributor"
			adaptable="false"
			nameFilter="*«fileExtension»«backupFileSuffix»"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«restoreAction.className»"
				id="«restoreAction.className»"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png"
				label="Restore Model">
			</action>
		</objectContribution>
		<objectContribution
			id="«model.basePackage».«model.name»GratextRestoreObjectContributor2"
			adaptable="false"
			nameFilter="*«fileExtension»DL"
			objectClass="org.eclipse.core.resources.IResource">
			<action
				class="«restoreAction.className»"
				id="«restoreAction.className»"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png"
				label="Restore Model">
			</action>
		</objectContribution>
   </extension>
   <extension point="info.scce.cinco.gratext.backup">
      <!--@GratextGen «model.name»-->
		<client fileExtension="«fileExtension»" class="«backupAction.className»"/>
   </extension>
   <extension point="info.scce.cinco.gratext.restore">
      <!--@GratextGen «model.name»-->
		<client fileExtension="«fileExtension»«backupFileSuffix»" class="«restoreAction.className»"/>
   </extension>
   <extension point="info.scce.cinco.gratext.restore">
      <!--@GratextGen «model.name»-->
		<client fileExtension="«fileExtension»DL" class="«restoreAction.className»"/>
   </extension>
</plugin>
'''
}