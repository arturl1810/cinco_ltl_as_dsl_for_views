package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.tools.ResizeTracker;
import org.eclipse.swt.events.MouseEvent;

class CincoResizeTracker extends ResizeTracker {

	public CincoResizeTracker(GraphicalEditPart owner, int direction) {
		super(owner, direction);
	}

	@Override
	public void mouseDrag(MouseEvent me, EditPartViewer viewer) {
		if (!isViewerImportant(viewer))
			return;
		setViewer(viewer);
		boolean wasDragging = movedPastThreshold();
		getCurrentInput().setInput(me);
		handleDrag();
		if (movedPastThreshold()) {
			// At this point wasDragging might be true while NOT being in
			// state DRAG_IN_PROGRESS although the original implementation
			// assumes the latter. Fix: call handleDragStarted
			if (!wasDragging
					|| !isInState(STATE_DRAG_IN_PROGRESS | STATE_ACCESSIBLE_DRAG_IN_PROGRESS)) {
				handleDragStarted();
			}	
			handleDragInProgress();
		}
	}
}