package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.tools.SelectEditPartTracker;
import org.eclipse.swt.events.MouseEvent;

class CincoSelectEditPartTracker extends SelectEditPartTracker {

	public CincoSelectEditPartTracker(EditPart owner) {
		super(owner);
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