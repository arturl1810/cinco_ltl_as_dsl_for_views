package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.PositionConstants;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.handles.AbstractHandle;
import org.eclipse.gef.tools.DragEditPartsTracker;
import org.eclipse.gef.tools.SelectEditPartTracker;
import org.eclipse.graphiti.features.IResizeShapeFeature;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.tb.IShapeSelectionInfo;
import org.eclipse.graphiti.tb.IToolBehaviorProvider;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.policy.GFResizableEditPolicy;

class CincoResizableEditPolicy extends GFResizableEditPolicy {

	private IResizeShapeContext context;
	
	public CincoResizableEditPolicy(IConfigurationProviderInternal cfgProvider) {
		super(cfgProvider);
	}
	
	public CincoResizableEditPolicy(IConfigurationProviderInternal configurationProvider, IResizeShapeContext resizeShapeContext) {
		super(configurationProvider, resizeShapeContext);
		context = resizeShapeContext;
	}
	
	@Override
	protected SelectEditPartTracker getSelectTracker() {
		return new CincoSelectEditPartTracker(getHost());
	}

	@Override
	protected DragEditPartsTracker getDragTracker() {
		return new CincoDragEditPartsTracker(getHost());
	}
	
	@Override
	protected List<?> createSelectionHandles() {
		boolean resizeAllowed = false;
		if (context != null) {
			resizeAllowed = !(getResizeShapeFeature() == null || !getResizeShapeFeature().canResizeShape(context));
		}

		GraphicalEditPart owner = (GraphicalEditPart) getHost();
		List<?> list = createShapeHandles(owner, getConfigurationProvider(), getResizeDirections(),
				isDragAllowed(), resizeAllowed);
		return list;
	}
	
	private IResizeShapeFeature getResizeShapeFeature() {
		if (context == null) {
			return null;
		}
		return getConfigurationProvider().getFeatureProvider().getResizeShapeFeature(context);
	}
	
	private List<AbstractHandle> createShapeHandles(GraphicalEditPart owner, IConfigurationProviderInternal cp,
			int supportedResizeDirections, boolean movable, boolean resizeAllowed) {
		List<AbstractHandle> list = new ArrayList<AbstractHandle>();

		IShapeSelectionInfo si = null;
		IToolBehaviorProvider tbp = cp.getDiagramTypeProvider().getCurrentToolBehaviorProvider();
		Object model = owner.getModel();
		if (model instanceof Shape) {
			si = tbp.getSelectionInfoForShape((Shape) model);
		} else if (model instanceof Anchor) {
			si = tbp.getSelectionInfoForAnchor((Anchor) model);
		}

		list.add(new CincoSurroundingHandle(owner, cp, movable, si));

		if (resizeAllowed) {
			if ((PositionConstants.NORTH_EAST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.NORTH_EAST, supportedResizeDirections,
						movable, si));
			if ((PositionConstants.SOUTH_EAST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.SOUTH_EAST, supportedResizeDirections,
						movable, si));
			if ((PositionConstants.SOUTH_WEST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.SOUTH_WEST, supportedResizeDirections,
						movable, si));
			if ((PositionConstants.NORTH_WEST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.NORTH_WEST, supportedResizeDirections,
						movable, si));
			if ((PositionConstants.NORTH & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.NORTH, supportedResizeDirections, movable, si));
			if ((PositionConstants.EAST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.EAST, supportedResizeDirections, movable, si));
			if ((PositionConstants.SOUTH & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.SOUTH, supportedResizeDirections, movable, si));
			if ((PositionConstants.WEST & supportedResizeDirections) != 0)
				list.add(new CincoCornerHandle(owner, cp, PositionConstants.WEST, supportedResizeDirections, movable, si));
		}

		return list;
	}
}