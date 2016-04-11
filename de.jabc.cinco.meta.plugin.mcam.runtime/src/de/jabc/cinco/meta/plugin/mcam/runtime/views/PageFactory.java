package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import org.eclipse.ui.IEditorPart;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;

public interface PageFactory {
	public CheckViewPage<?, ?, ?, ?> createCheckViewPage(String id, IEditorPart editor);
	public ConflictViewPage<?, ?, ?, ?> createConflictViewPage(String id, IEditorPart editor);
}
