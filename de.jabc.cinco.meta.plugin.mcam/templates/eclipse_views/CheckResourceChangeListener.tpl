package ${McamViewBasePackage};

import java.io.File;

import ${McamViewBasePackage}.CheckView;
import ${McamViewBasePackage}.CheckViewInformation;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.swt.widgets.Display;

public class CheckResourceChangeListener implements IResourceChangeListener {

	final private CheckView view;

	public CheckResourceChangeListener(CheckView view) {
		super();
		this.view = view;
	}

	@Override
	public void resourceChanged(IResourceChangeEvent event) {
		IResourceDelta delta = event.getDelta();
		if (delta == null)
			return;
		File file = getFileFromDelta(event.getDelta());
		if (file != null) {
			Object obj = view.getCheckInfoMap().get(file.getAbsolutePath());
			if (obj instanceof CheckViewInformation) {
				CheckViewInformation cvi = (CheckViewInformation) obj;
				Display.getDefault().asyncExec(new Runnable() {
				    public void run() {
				    	cvi.closeView();
				    	cvi.createCheckProcess();
				    	cvi.createCheckViewTree(view.getParent());

				    	cvi.getTreeViewer().expandAll();

						if (!view.getParent().isDisposed()) {
							view.getParent().layout(true);
							view.getParent().redraw();
							view.getParent().update();
						}
				    	
				    }
				});
			}
		}
	}

	private File getFileFromDelta(IResourceDelta delta) {
		for (IResourceDelta child : delta.getAffectedChildren()) {
			IResource res = child.getResource();
			if (res instanceof IFile) {
				IFile iFile = (IFile) res;
				return iFile.getRawLocation().makeAbsolute().toFile();
			}
			return getFileFromDelta(child);
		}
		return null;
	}

}

