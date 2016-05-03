package de.jabc.cinco.meta.plugin.gratext.runtime.action;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;

public interface IBackupAction {

	void run(IFile file, IPath targetFolder);
}
