package de.jabc.cinco.meta.plugin.gratext.template.action

import de.jabc.cinco.meta.plugin.gratext.template.AbstractGratextTemplate

class GratextBackupActionTemplate extends AbstractGratextTemplate {

		
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


public class BackupAction implements IActionDelegate {

	private static final String EXTENSION_POINT = "info.scce.cinco.gratext.backup";
	private static final String ATTRIBUTE_CLASS = "class";
	private static final String ATTRIBUTE_FILE_EXTENSION = "fileExtension";
	private static final String TARGET_FOLDER = "_backup";
	
	private ISelection selection;
	private Map<String, IBackupAction> map = new HashMap<>();
	
	@Override
	public void run(IAction action) {
		System.out.println("[GratextBackup] run");
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
			System.out.println("[GratextBackup] Evaluating extension");
			final Object ext = config.createExecutableExtension(ATTRIBUTE_CLASS);
			String fileExtension = config.getAttribute(ATTRIBUTE_FILE_EXTENSION);
			if (fileExtension != null && ext instanceof IBackupAction) {
				System.out.println("[GratextBackup]  > " + fileExtension + " = " + ext);
				map.put(fileExtension, (IBackupAction) ext);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}
	
	private void executeExtensions(IProject project) {
		getWorkspaceFiles().forEach(file -> {
			IBackupAction action = map.get(file.getFileExtension());
			if (action != null) 
				executeExtension(action, file);
		});
	}
	
	private void executeExtension(final IBackupAction action, IFile file) {
		ISafeRunnable runnable = new ISafeRunnable() {
			
			@Override
			public void handleException(Throwable e) {
				System.out.println("Exception in client");
				e.printStackTrace();
			}

			@Override
			public void run() throws Exception {
				action.run(file, new Path(TARGET_FOLDER).append(file.getProjectRelativePath().removeLastSegments(1)));
			}
		};
		SafeRunner.run(runnable);
	}
	
	protected List<IFile> getWorkspaceFiles() {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), null, true);
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