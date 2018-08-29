package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.core.FrameworkExecution;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;

public interface PageFactory {
	
	boolean canHandle(Resource resource);
	
	public List<String> getFileExtensions();
	
	@SuppressWarnings("rawtypes")
	public FrameworkExecution getFrameWorkExecution(IFile iFile);
	
	public CheckViewPage<?, ?, ?> createCheckViewPage(String id, IEditorPart editor);
	public ConflictViewPage<?, ?, ?> createConflictViewPage(String id, IEditorPart editor);
}
