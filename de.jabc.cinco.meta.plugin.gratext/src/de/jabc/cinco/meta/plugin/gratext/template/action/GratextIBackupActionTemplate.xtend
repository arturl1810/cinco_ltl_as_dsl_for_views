package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextIBackupActionTemplate extends AbstractGratextTemplate {

		
override template()
'''	
package info.scce.cinco.gratext;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public interface IBackupAction {

	void run(IFile file, IPath targetFolder);
}
'''
}