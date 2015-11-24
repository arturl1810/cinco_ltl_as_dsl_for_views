package ${ViewUtilPackage};

import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.runtime.CoreException;

public class ${ClassName} implements IResourceChangeListener {

	@Override
	public void resourceChanged(IResourceChangeEvent event) {
		IResource res = event.getResource();
		switch (event.getType()) {
		case IResourceChangeEvent.PRE_CLOSE:
			System.out.print("PRE_CLOSE: Project ");
			System.out.print(res.getFullPath());
			System.out.println(" is about to close.");
			break;
		case IResourceChangeEvent.PRE_DELETE:
			System.out.print("PRE_DELETE: Project ");
			System.out.print(res.getFullPath());
			System.out.println(" is about to be deleted.");
			break;
		case IResourceChangeEvent.POST_CHANGE:
			System.out.println("POST_CHANGE: Resources have changed.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		case IResourceChangeEvent.PRE_BUILD:
			System.out.println("PRE_BUILD: Build about to run.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		case IResourceChangeEvent.POST_BUILD:
			System.out.println("POST_BUILD: Build complete.");
			try {
				event.getDelta().accept(new DeltaPrinter());
			} catch (CoreException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			break;
		}
	}

}

