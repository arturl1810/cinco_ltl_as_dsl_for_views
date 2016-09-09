package de.jabc.cinco.meta.core.utils;

import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IPathEditorInput;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;

public class WorkbenchUtil {

	
	/**
	 * Retrieves the active editor if one exists
	 */
	public static IEditorPart getActiveEditor(){
		IWorkbench workbench = PlatformUI.getWorkbench();
		if (workbench == null) return null;
		
		IWorkbenchWindow activeWorkbenchWindow = workbench.getActiveWorkbenchWindow();
		if (activeWorkbenchWindow == null) return null;
		
		IWorkbenchPage activePage = activeWorkbenchWindow.getActivePage();
		if (activePage == null) return null;
		
		IEditorPart activeEditor = activePage.getActiveEditor();
		return activeEditor;
	}
	
	/**
	 * Retrieves the project of the active editor's input, null if no editor active
	 */
	public static IProject getProjectForActiveEditor(){
		if (getActiveEditor() == null) return null;
		IEditorInput editorInput = getActiveEditor().getEditorInput();
		if (!(editorInput instanceof IPathEditorInput)) return null;
		
		IPath editorPath = ((IPathEditorInput) editorInput).getPath();
		List<IFile> files = WorkspaceUtil.getFiles(f -> f.getFullPath().equals(editorPath) || f.getLocation().equals(editorPath));
		
		if (files.size() != 1) return null;
		
		return files.get(0).getProject();
	}
	
}
