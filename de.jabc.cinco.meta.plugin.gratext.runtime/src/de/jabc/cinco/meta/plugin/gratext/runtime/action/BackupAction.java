package de.jabc.cinco.meta.plugin.gratext.runtime.action;

import static de.jabc.cinco.meta.core.utils.job.JobFactory.job;

import java.util.stream.Stream;
import java.util.stream.StreamSupport;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IActionDelegate;

public abstract class BackupAction implements IActionDelegate, IBackupAction {

	private ISelection sel;
	
	public BackupAction() {}
	
	@Override 
	public void run(IAction action) {
		job("Gratext Backup")
		  .label("Generating backup...")
		  .consumeConcurrent(15)
		    .taskForEach(getSelectedFiles(),
		    		file -> run(file, file.getProjectRelativePath().removeLastSegments(1)),
		    		file -> file.getName())
		  .schedule();
	}
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	private Stream<IFile> getSelectedFiles() {
		if (sel instanceof IStructuredSelection && !sel.isEmpty())
			return StreamSupport.stream(
				((Iterable)(() -> ((IStructuredSelection)sel).iterator())).spliterator(), false)
				.filter(IFile.class::isInstance);
		return Stream.empty();
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		this.sel = selection;
	}
}
