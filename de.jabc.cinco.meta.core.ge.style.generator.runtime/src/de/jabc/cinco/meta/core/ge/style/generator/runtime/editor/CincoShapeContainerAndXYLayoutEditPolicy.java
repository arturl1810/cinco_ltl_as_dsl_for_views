package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.editpolicies.NonResizableEditPolicy;
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.parts.AdvancedAnchorEditPart;
import org.eclipse.graphiti.ui.internal.parts.ShapeEditPart;
import org.eclipse.graphiti.ui.internal.policy.ShapeContainerAndXYLayoutEditPolicy;

class CincoShapeContainerAndXYLayoutEditPolicy extends ShapeContainerAndXYLayoutEditPolicy {

	protected CincoShapeContainerAndXYLayoutEditPolicy(IConfigurationProviderInternal configurationProvider) {
		super(configurationProvider);
	}
	
	@Override
	protected EditPolicy createChildEditPolicy(EditPart child) {
		if (child instanceof AdvancedAnchorEditPart) {
			return new CincoResizableEditPolicy(getConfigurationProvider());
		}
		if (!(child instanceof ShapeEditPart)) {
			return new NonResizableEditPolicy();
		}
		PictogramElement pictogramElement = ((ShapeEditPart) child).getPictogramElement();
		Shape shape = (Shape) pictogramElement;
		ResizeShapeContext resizeShapeContext = new ResizeShapeContext(shape);
		return new CincoResizableEditPolicy(getConfigurationProvider(), resizeShapeContext);
	}
}