package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.DragTracker;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.tools.DragEditPartsTracker;
import org.eclipse.graphiti.tb.IShapeSelectionInfo;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFCornerHandle;

class CincoCornerHandle extends GFCornerHandle {

	private int resizeDirection;
	private boolean movable;

	public CincoCornerHandle(GraphicalEditPart owner, IConfigurationProviderInternal configurationProvider,
			int location, int supportedResizeDirections, boolean movable, IShapeSelectionInfo shapeSelectionInfo) {
		super(owner, configurationProvider, location, supportedResizeDirections, movable, shapeSelectionInfo);
		this.resizeDirection = supportedResizeDirections & location;
		this.movable = movable;
	}
	
	@Override
	protected DragTracker createDragTracker() {
		if (resizeDirection != 0) { // if is resizable
			return new CincoResizeTracker(getOwner(), resizeDirection);
		} else if (movable) {
			DragEditPartsTracker tracker = new CincoDragEditPartsTracker(getOwner());
			tracker.setDefaultCursor(getCursor());
			return tracker;
		} else {
			return null;
		}
	}
	
}