package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextIRestoreActionTemplate extends AbstractGratextTemplate {

		
override template()
'''	
package info.scce.cinco.gratext;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public interface IRestoreAction {

	void run(IFile file, IPath targetFolder);
}
'''
}