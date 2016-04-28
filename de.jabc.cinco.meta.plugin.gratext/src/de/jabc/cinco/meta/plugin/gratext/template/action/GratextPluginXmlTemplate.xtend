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
		<objectContribution
			adaptable="true"
			id="info.scce.cinco.gratext.ProjectContributor"
			objectClass="org.eclipse.core.resources.IProject">
			<menu id="gratext.main"
				path="additions"
				label="Gratext"
				icon="platform:/plugin/de.jabc.cinco.meta.plugin.gratext/gt_icon_16.png">
			</menu>
			<action
				class="de.jabc.cinco.meta.plugin.gratext.runtime.action.GratextRestoreAction"
				label="Restore from Backup"
				menubarPath="gratext.main/group1">
			</action>
			<action
				class="de.jabc.cinco.meta.plugin.gratext.runtime.action.GratextBackupAction"
				label="Generate Backup"
				menubarPath="gratext.main/group1">
			</action>
		</objectContribution>
   </extension>
</plugin>
'''
}