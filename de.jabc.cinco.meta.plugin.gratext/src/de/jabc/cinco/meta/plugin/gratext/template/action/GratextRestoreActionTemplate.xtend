package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextRestoreActionTemplate extends AbstractGratextTemplate {

		
override template()
'''	
package info.scce.cinco.gratext;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IActionDelegate;


public class RestoreAction implements IActionDelegate {

	private static final String EXTENSION_POINT = "info.scce.cinco.gratext.restore";
	private static final String ATTRIBUTE_CLASS = "class";
	private static final String ATTRIBUTE_FILE_EXTENSION = "fileExtension";
	private static final String TARGET_FOLDER = "";
	private static final String BACKUP_FOLDER = "_backup";
	
	private ISelection selection;
	private Map<String, IRestoreAction> map = new HashMap<>();
	
	@Override
	public void run(IAction action) {
		System.out.println("[GratextRestore] run");
		if (selection instanceof IStructuredSelection) {
			map = new HashMap<>();
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IProject) {
				initExtensions();
				executeExtensions((IProject) ssel.getFirstElement());
			}
		}
	}
	
	private void initExtensions() {
		IConfigurationElement[] configs = Platform.getExtensionRegistry().getConfigurationElementsFor(EXTENSION_POINT);
		for (IConfigurationElement config : configs) try {
			System.out.println("[GratextRestore] Evaluating extension");
			final Object ext = config.createExecutableExtension(ATTRIBUTE_CLASS);
			String fileExtension = config.getAttribute(ATTRIBUTE_FILE_EXTENSION);
			if (fileExtension != null && ext instanceof IRestoreAction) {
				System.out.println("[GratextRestore]  > " + fileExtension + " = " + ext);
				map.put(fileExtension, (IRestoreAction) ext);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}
	
	private void executeExtensions(IProject project) {
		getBackupFiles(project).forEach(file -> {
			System.out.println("[GratextRestore]  > backup file = " + file);
			IRestoreAction action = map.get(file.getFileExtension());
			if (action != null) 
				executeExtension(action, file);
		});
	}
	
	private void executeExtension(final IRestoreAction action, IFile file) {
		ISafeRunnable runnable = new ISafeRunnable() {
			
			@Override
			public void handleException(Throwable e) {
				System.out.println("Exception in client");
				e.printStackTrace();
			}

			@Override
			public void run() throws Exception {
				action.run(file, new Path(TARGET_FOLDER).append(file.getProjectRelativePath().removeFirstSegments(1).removeLastSegments(1)));
			}
		};
		SafeRunner.run(runnable);
	}
	
	protected List<IFile> getBackupFiles(IProject project) {
		IFolder backupFolder = project.getFolder(new Path(BACKUP_FOLDER));
		System.out.println("[GratextRestore] Backup folder = " + backupFolder);
		if (backupFolder != null && backupFolder.exists())
			return getFiles(backupFolder, null, true);
		return new ArrayList<>();
	}
	
	protected List<IFile> getWorkspaceFiles(String fileExtension) {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), fileExtension, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
	    List<IFile> files = new ArrayList<>();
	    IResource[] members = null;
	    try {
	    	members = container.members();
	    } catch(CoreException e) {
	    	e.printStackTrace();
	    }
	    if (members != null)
			Arrays.stream(members).forEach(mbr -> {
			   if (recurse && mbr instanceof IContainer)
				   files.addAll(getFiles((IContainer) mbr, fileExtension, recurse));
			   else if (mbr instanceof IFile && !mbr.isDerived()) {
				   IFile file = (IFile) mbr;
				   if (fileExtension == null || fileExtension.equals(file.getFileExtension()))
				       files.add(file);
			   }
		   });
		return files;
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}
}
'''
}