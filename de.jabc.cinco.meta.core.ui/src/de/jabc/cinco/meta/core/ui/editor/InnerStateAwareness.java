package de.jabc.cinco.meta.core.ui.editor;

import org.eclipse.emf.ecore.resource.Resource;

public interface InnerStateAwareness {

	Resource getInnerState();
	
	void handleInnerStateChanged();
	
	void handleNewInnerState();
}
