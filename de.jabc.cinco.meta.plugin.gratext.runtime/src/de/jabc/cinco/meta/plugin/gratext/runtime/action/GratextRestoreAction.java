package de.jabc.cinco.meta.plugin.gratext.runtime.action;

import static de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi;
import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;
import static de.jabc.cinco.meta.plugin.gratext.runtime.util.GratextUtils.showErrorMessage;

import java.util.AbstractMap;
import java.util.AbstractMap.SimpleEntry;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Stream;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IProject;
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


public class GratextRestoreAction implements IActionDelegate {

	private static final String EXTENSION_POINT = "info.scce.cinco.gratext.restore";
	private static final String ATTRIBUTE_CLASS = "class";
	private static final String ATTRIBUTE_FILE_EXTENSION = "fileExtension";
	private static final String TARGET_FOLDER = "";
	private static final String BACKUP_FOLDER = "_backup";
	
	private ISelection selection;
	private IProject project;
	private Map<String, IRestoreAction> actionByExtension;
	private Stream<SimpleEntry<IFile, IRestoreAction>> actionByFile;
	
	@Override
	public void run(IAction action) {
		if (!initProject()) return;
		
		job("Gratext Restore")
		  .label("Collecting files...")
		  .consume(5)
		    .task(this::initExtensions)
		    .task(this::initActions)
		  .label("Restoring from backups...")
		  .consumeConcurrent(95)
			.taskForEach(() -> actionByFile, 
		    		  entry -> runRestore(entry.getValue(), entry.getKey()),
		    		  entry -> entry.getKey().getName())
		  .onFailed(() -> showErrorMessage("Gratext Restore", "Some restore tasks seem to have failed."))
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
			if (fileExtension != null && ext instanceof IRestoreAction) {
				actionByExtension.put(fileExtension, (IRestoreAction) ext);
			}
		} catch (CoreException e) {
			e.printStackTrace();
		}
		
	}
	
	private void initActions() {
		actionByFile = getRestoreCandidates(project).stream()
			.map(file -> new AbstractMap.SimpleEntry<IFile, IRestoreAction>(file, actionByExtension.get(file.getFileExtension())))
			.filter(entry -> entry.getValue() != null);
	}
	
	protected List<IFile> getRestoreCandidates(IProject project) {
		IFolder backupFolder = project.getFolder(new Path(BACKUP_FOLDER));
		return eapi(backupFolder).getFiles();
	}
	
	private void runRestore(final IRestoreAction action, IFile file) {
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
		try {
			SafeRunner.run(runnable);
		} catch(Error e) {
			System.err.println("[GratextRestore] severe error, failed to restore " + file.getFullPath());
			System.err.println("[GratextRestore] " + e.getMessage());
		}
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection;
	}
}
