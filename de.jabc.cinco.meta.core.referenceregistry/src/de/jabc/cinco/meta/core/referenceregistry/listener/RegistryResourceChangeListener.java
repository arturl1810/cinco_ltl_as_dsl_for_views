package de.jabc.cinco.meta.core.referenceregistry.listener;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IResourceChangeEvent;
import org.eclipse.core.resources.IResourceChangeListener;
import org.eclipse.core.resources.IResourceDelta;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.util.URI;

import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry;

public class RegistryResourceChangeListener implements IResourceChangeListener {

	@Override
	public void resourceChanged(IResourceChangeEvent event) {
		IResourceDelta delta = event.getDelta();
		if (delta != null) {
			processAffectedFiles(delta);
		}
	}

	private void processAffectedFiles(IResourceDelta delta) {
		IPath from = null;
		for (IResourceDelta child: delta.getAffectedChildren()) {
			IResource res = child.getResource();
		
			if (res instanceof IProject) {
				if (deleted(child)) {
					ReferenceRegistry.getInstance().handleDeleteProject((IProject) res);
				}
			}
			
			if (res instanceof IFile) {
				IFile file = (IFile) res;
//				//System.out.println("For file: " + file);
//				//System.out.println("Delta-Kind: " + child.getKind());
//				//System.out.println("Delta-Flags : " + child.getFlags());
//				//System.out.println("From: " + child.getMovedFromPath());
//				//System.out.println("To: " + child.getMovedToPath());
				if (deleted(child)){
					ReferenceRegistry.getInstance().handleDelete(getUri(file.getFullPath()));
				}
				if (changed(child)){
					ReferenceRegistry.getInstance().handleContentChange(getUri(file.getFullPath()));
				} 
				if (movedFrom(child)) {
					from = child.getMovedFromPath();
					ReferenceRegistry.getInstance().handleRename(getUri(from), getUri(file.getFullPath()));
				}
			}
			processAffectedFiles(child);
		}
	}

	private boolean movedFrom(IResourceDelta child) {
		return (child.getKind() == IResourceDelta.ADDED && child.getFlags() == IResourceDelta.MOVED_FROM);
	}
	
	private boolean changed(IResourceDelta child) {
		return child.getKind() == IResourceDelta.CHANGED && child.getFlags() == IResourceDelta.CONTENT;
	}

	private boolean deleted(IResourceDelta child) {
		return child.getKind() == IResourceDelta.REMOVED && child.getFlags() == IResourceDelta.NO_CHANGE;
	}
	
	private URI getUri(IPath path) {
		URI uri = URI.createPlatformResourceURI(path.toPortableString(), true);
		return uri;
	}
}
