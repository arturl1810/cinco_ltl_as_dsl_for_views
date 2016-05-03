package de.jabc.cinco.meta.plugin.gratext.runtime.action;

import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;


import java.util.AbstractMap;
import java.util.AbstractMap.SimpleEntry;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.ISafeRunnable;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.SafeRunner;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.IActionDelegate;


public class GratextBackupAction implements IActionDelegate {

	private static final String EXTENSION_POINT = "info.scce.cinco.gratext.backup";
	private static final String ATTRIBUTE_CLASS = "class";
	private static final String ATTRIBUTE_FILE_EXTENSION = "fileExtension";
	private static final String TARGET_FOLDER = "_backup";
	
	private Display display;
	private ISelection selection;
	private IProject project;
	private Map<String, IBackupAction> actionByExtension;
	private Stream<SimpleEntry<IFile, IBackupAction>> actionByFile;
	
	@Override
	public void run(IAction action) {
		if (!initProject()) return;
		
		job("Gratext Backup")
		  .label("Collecting files...")
		  .consume(5)
		    .task(this::initExtensions)
		    .task(this::initActions)
		  .label("Generating backups...")
		  .consumeConcurrent(95)
		    .taskForEach(() -> actionByFile, 
		    		  entry -> runBackup(entry.getValue(), entry.getKey()),
		    		  entry -> entry.getKey().getName())
		  .onFailed(() -> showErrorMessage("Some backup tasks seem to have failed."))
		  .schedule();
	}
	
	private boolean initProject() {
		if (selection instanceof IStructuredSelection) {
			IStructuredSelection ssel = (IStructuredSelection) selection;
			if (!ssel.isEmpty() && ssel.getFirstElement() instanceof IProject) {
				project = (IProject) ssel.getFirstElement();
				return true;
			}
		}
		return false;
	}
	
	private void initExtensions() {
		actionByExtension = new HashMap<>();
		IConfigurationElement[] configs = Platform.getExtensionRegistry().getConfigurationElementsFor(EXTENSION_POINT);
		for (IConfigurationElement config : configs) try {
			final Object ext = config.createExecutableExtension(ATTRIBUTE_CLASS);
			String fileExtension = config.getAttribute(ATTRIBUTE_FILE_EXTENSION);
			if (fileExtension != null && ext instanceof IBackupAction)
				actionByExtension.put(fileExtension, (IBackupAction) ext);
		} catch (CoreException e) {
			e.printStackTrace();
		}
	}
	
	private void initActions() {
		actionByFile = getProjectFiles().stream()
			.map(file -> new AbstractMap.SimpleEntry<IFile, IBackupAction>(file, actionByExtension.get(file.getFileExtension())))
			.filter(entry -> entry.getValue() != null);
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
	
	private void showErrorMessage(String msg) {
		display = Display.getCurrent();
		if (display == null)
			display = Display.getDefault();
		if (display != null)
			display.syncExec(() ->
				new MessageDialog(display.getActiveShell(),
		            "Gratext Backup", display.getSystemImage(SWT.ICON_ERROR),
		            msg, MessageDialog.ERROR, new String[] {"OK"}, 0
		        ).open()
			);
	}
	
	protected List<IFile> getProjectFiles() {
		return getFiles(project, null, true);
	}
	
	protected List<IFile> getFiles(IContainer container, String fileExtension,
			boolean recurse) {
		List<IFile> files = new ArrayList<>();
		if (container instanceof IFolder
				&& TARGET_FOLDER.equals(((IFolder) container).getName()))
			return files;
		IResource[] members = null;
		try {
			members = container.members();
		} catch (CoreException e) {
			e.printStackTrace();
		}
		if (members != null)
			Arrays.stream(members).forEach( mbr -> {
				if (recurse && mbr instanceof IContainer)
					files.addAll(getFiles((IContainer) mbr,
							fileExtension, recurse));
				else if (mbr instanceof IFile && !mbr.isDerived()) {
					IFile file = (IFile) mbr;
					if (fileExtension == null
							|| fileExtension.equals(file
									.getFileExtension()))
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
