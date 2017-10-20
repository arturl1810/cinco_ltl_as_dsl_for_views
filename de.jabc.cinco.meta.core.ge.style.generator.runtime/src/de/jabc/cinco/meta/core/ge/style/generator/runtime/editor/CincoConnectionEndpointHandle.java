package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.draw2d.ConnectionLocator;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.tools.ConnectionEndpointTracker;
import org.eclipse.graphiti.ui.internal.policy.GFConnectionEndpointTracker;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFConnectionEndpointHandle;
import org.eclipse.swt.events.MouseEvent;

class CincoConnectionEndpointHandle extends GFConnectionEndpointHandle {

	public CincoConnectionEndpointHandle(ConnectionEditPart owner, int endPoint) {
		super(owner, endPoint);
	}
	
	@Override
	protected DragTracker createDragTracker() {
		if (isFixed())
			return null;
		ConnectionEndpointTracker tracker = 
			new GFConnectionEndpointTracker((ConnectionEditPart) getOwner()) {
			
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
			
		};
		if (getEndPoint() == ConnectionLocator.SOURCE) {
			tracker.setCommandName(RequestConstants.REQ_RECONNECT_SOURCE);
		} else {
			tracker.setCommandName(RequestConstants.REQ_RECONNECT_TARGET);
		}
		tracker.setDefaultCursor(getCursor());
		return tracker;
	}
}