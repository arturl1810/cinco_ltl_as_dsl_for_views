package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextPluginXmlTemplate extends AbstractGratextTemplate {

		
override template()
'''	
<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>
   <extension-point id="info.scce.cinco.gratext.backup" name="Gratext Backup" schema="schema/info.scce.cinco.gratext.backup.exsd"/>
   <extension-point id="info.scce.cinco.gratext.restore" name="Gratext Restore" schema="schema/info.scce.cinco.gratext.restore.exsd"/>
   <extension point="org.eclipse.ui.popupMenus">
      <!--@GratextGen Data-->
		<objectContribution
			adaptable="false"
			id="info.scce.cinco.gratext.ProjectContributor"
			objectClass="org.eclipse.core.resources.IProject">
			<action
				class="info.scce.cinco.gratext.BackupAction"
				id="info.scce.cinco.gratext.BackupAction"
				label="Generate Gratext Backup">
			</action>
		</objectContribution>
   </extension>
   <extension point="org.eclipse.ui.popupMenus">
      <!--@GratextGen Data-->
		<objectContribution
			adaptable="false"
			id="info.scce.cinco.gratext.ProjectContributor"
			objectClass="org.eclipse.core.resources.IProject">
			<action
				class="info.scce.cinco.gratext.RestoreAction"
				id="info.scce.cinco.gratext.RestoreAction"
				label="Restore Gratext Backup">
			</action>
		</objectContribution>
   </extension>
</plugin>
'''
}