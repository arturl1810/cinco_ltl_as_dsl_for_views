package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.DragTracker;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.tools.DragEditPartsTracker;
import org.eclipse.graphiti.tb.IShapeSelectionInfo;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFSurroundingHandle;

class CincoSurroundingHandle extends GFSurroundingHandle {

	private boolean movable;

	public CincoSurroundingHandle(GraphicalEditPart owner, IConfigurationProviderInternal configurationProvider,
			boolean movable, IShapeSelectionInfo shapeSelectionInfo) {
		super(owner, configurationProvider, movable, shapeSelectionInfo);
		this.movable = movable;
	}
	
	@Override
	protected DragTracker createDragTracker() {
		if (movable) {
			DragEditPartsTracker tracker = new CincoDragEditPartsTracker(getOwner());
			tracker.setDefaultCursor(getCursor());
			return tracker;
		} else {
			return null;
		}
	}
}