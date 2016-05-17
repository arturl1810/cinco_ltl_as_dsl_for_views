package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;

public class ProjectCheckView extends CheckView {
	
	public static final String ID = "de.jabc.cinco.meta.plugin.mcam.runtime.views.ProjectCheckView";

	@Override
	protected void initView(Composite parent) {
		super.initView(parent);
		ResourcesPlugin.getWorkspace().removeResourceChangeListener(resourceChangeListener);
	}

	@Override
	public CheckViewPage<?, ?, ?, ?> createPage(String id, IEditorPart editor) {
		PageFactory pf = getPageFactory();
		if (pf != null)
			return pf.createProjectCheckViewPage(id, editor);
		return null;
	}

	@Override
	public String getPageId(IResource res) {
		if (res instanceof IFile == false || res == null)
			return null;

		IFile file = (IFile) res;
		return file.getProject().getName();
	}

	
	
}
