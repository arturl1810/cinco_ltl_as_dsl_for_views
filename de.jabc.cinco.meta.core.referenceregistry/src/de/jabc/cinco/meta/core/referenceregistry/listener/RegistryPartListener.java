package de.jabc.cinco.meta.core.referenceregistry.listener;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.graphiti.ui.editor.DiagramEditorInput;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IPartListener;
import org.eclipse.ui.IWorkbenchPart;

import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry;

public class RegistryPartListener implements IPartListener {

	private IProject currentProject;
	
	
	@Override
	public void partOpened(IWorkbenchPart part) {
		refreshIfNeeded(part);
	}
	
	@Override
	public void partActivated(IWorkbenchPart part) {
		refreshIfNeeded(part);
	}

	@Override
	public void partDeactivated(IWorkbenchPart part) {
		storeIfNeeded(part);
	}

	
	private void refreshIfNeeded(IWorkbenchPart part) {
		IProject project = getProject(part);
		if (refreshNeeded(project)) {
			ReferenceRegistry.getInstance().setCurrentMap(project);
			currentProject = project;
		} else {
		}
	}
	
	private void storeIfNeeded(IWorkbenchPart part) {
		IProject project = getProject(part);
		if (storeNeeded(project)) {
			ReferenceRegistry.getInstance().storeMaps(project);
		} else {
		}
		
	}
	
	private boolean storeNeeded(IProject project) {
		if (currentProject != null && currentProject.equals(project))
			return true;
		return false;
	}

	private boolean refreshNeeded(IProject project) {
		if (project != null && !project.equals(currentProject))
			return true;
		return false;
	}

	@Override
	public void partBroughtToTop(IWorkbenchPart part) {
	}

	@Override
	public void partClosed(IWorkbenchPart part) {
		
	}


	private IProject getProject(IWorkbenchPart part) {
		if (part.getSite().getPage().getActiveEditor() == null) 
			return null;
			IEditorInput editorInput = part.getSite().getPage().getActiveEditor().getEditorInput();
			if (!(editorInput instanceof DiagramEditorInput))
				return null;
			DiagramEditorInput input = (DiagramEditorInput) editorInput;
			URI uri = input.getUri();
			IResource member = ResourcesPlugin.getWorkspace().getRoot().findMember(uri.toPlatformString(true));
			if (member == null) 
				return null;
			IProject project = member.getProject();
			if (project != null && !project.equals(currentProject))
				return project;
			
			return null;
	}

}
