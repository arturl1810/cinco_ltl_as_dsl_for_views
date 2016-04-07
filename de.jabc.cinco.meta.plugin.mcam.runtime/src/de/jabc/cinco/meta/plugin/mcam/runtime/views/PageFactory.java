package de.jabc.cinco.meta.plugin.mcam.runtime.views;

import org.eclipse.core.resources.IFile;

import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.CheckViewPage;
import de.jabc.cinco.meta.plugin.mcam.runtime.views.pages.ConflictViewPage;

public interface PageFactory {
	public CheckViewPage<?, ?, ?> createCheckViewPage(IFile file);
	public ConflictViewPage<?, ?, ?> createConflictViewPage(IFile file);
}
