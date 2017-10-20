package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.config.ConfigurationProvider;
import org.eclipse.graphiti.ui.internal.policy.IEditPolicyFactory;

/**
 * @author Steve Bosselmann
 */
@SuppressWarnings("restriction")
public class CincoConfigurationProvider extends ConfigurationProvider {

	IEditPolicyFactory editPolicyFactory;
	
	public CincoConfigurationProvider(DiagramBehavior diagramBehavior, IDiagramTypeProvider diagramTypeProvider) {
		super(diagramBehavior, diagramTypeProvider);
	}
	
	@Override
	public IEditPolicyFactory getEditPolicyFactory() {
		if (editPolicyFactory == null && !isDisposed()) {
			editPolicyFactory = new CincoEditPolicyFactory(this);
		}
		return editPolicyFactory;
	}
	
	@Override
	public void dispose() {
		editPolicyFactory = null;
		super.dispose();
	}
}
