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
import java.util.Map.Entry;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.SubMonitor;
import org.eclipse.core.runtime.jobs.IJobChangeEvent;
import org.eclipse.core.runtime.jobs.Job;
import org.eclipse.core.runtime.jobs.JobChangeAdapter;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionDelegate;


public class BackupAction implements IActionDelegate {

	private static final String EXTENSION_POINT = "info.scce.cinco.gratext.backup";
	private static final String ATTRIBUTE_CLASS = "class";
	private static final String ATTRIBUTE_FILE_EXTENSION = "fileExtension";
	private static final String TARGET_FOLDER = "_backup";
	
	private Display display;
	private ISelection selection;
	private Map<String, IBackupAction> map = new HashMap<>();
	
	@Override
	public void run(IAction action) {
		System.out.println("[GratextBackup] run");
		display = Display.getCurrent();
		if (selection instanceof IStructuredSelection) {
			map = new HashMap<>();
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IProject) {
				initExtensions();
				runBackup((IProject) ssel.getFirstElement());
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
	
	private void runBackup(IProject project) {
		Job job = new Job("Generate Gratext Backup") {
			@Override
			protected IStatus run(IProgressMonitor monitor) {
				SubMonitor subMonitor = SubMonitor.convert(monitor, 100);
				Map<IFile,IBackupAction> files = getFilesToBackup(subMonitor.newChild(5));
				subMonitor.setWorkRemaining(95);
				int totalWork = files.size();
				int workTick = 95/totalWork;
				int worked = 1;
				for (Entry<IFile, IBackupAction> entry : files.entrySet()) {
					subMonitor.setTaskName("Backing up file " + (worked++) + "/" + totalWork + ": " + entry.getKey().getName());
					subMonitor.worked(workTick);
					runBackup(entry.getValue(), entry.getKey());
					if (monitor.isCanceled())
						return Status.CANCEL_STATUS;
				}
				return Status.OK_STATUS;
			};
		};
		job.addJobChangeListener(new JobChangeAdapter() {
	        public void done(IJobChangeEvent event) {
	        if (event.getResult().isOK())
	        		showMessage("Backup successful.");
	        else if (!event.getResult().equals(Status.CANCEL_STATUS))
	        		showErrorMessage("Some backups seem to have failed.");
	        }
	     });
	    job.setUser(true);
		job.schedule();
	}
	
	private void showMessage(String msg) {
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Gratext Backup", display.getSystemImage(SWT.ICON_INFORMATION),
	            msg, MessageDialog.INFORMATION, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	private void showErrorMessage(String msg) {
		display.asyncExec(() ->
			new MessageDialog(display.getActiveShell(),
	            "Gratext Backup", display.getSystemImage(SWT.ICON_ERROR),
	            msg, MessageDialog.ERROR, new String[] {"OK"}, 0
	        ).open()
		);
	}
	
	private Map<IFile, IBackupAction> getFilesToBackup(IProgressMonitor monitor) {
		SubMonitor subMonitor = SubMonitor.convert(monitor, 100);
		subMonitor.setTaskName("Collecting files to backup...");
		Map<IFile,IBackupAction> files = new HashMap<>();
		List<IFile> wsFiles = getWorkspaceFiles();
		subMonitor.worked(50);
		for (IFile file : wsFiles) {
			IBackupAction action = map.get(file.getFileExtension());
			if (action != null)
				files.put(file, action);
		}
		subMonitor.worked(50);
		return files;
	}
	
	private void runBackup(final IBackupAction action, IFile file) {
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
		try {
			SafeRunner.run(runnable);
		} catch(Error e) {
			System.err.println("[GratextBackup] severe error, failed to backup " + file.getFullPath());
			System.err.println("[GratextBackup] " + e.getMessage());
		}
	}
	
	protected List<IFile> getWorkspaceFiles() {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), null, true);
	}
	
	protected List<IFile> getWorkspaceFiles(String fileExtension) {
		return getFiles(ResourcesPlugin.getWorkspace().getRoot(), fileExtension, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension, boolean recurse) {
	    List<IFile> files = new ArrayList<>();
	    if (container instanceof IFolder && TARGET_FOLDER.equals(((IFolder)container).getName()))
	    		return files;
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