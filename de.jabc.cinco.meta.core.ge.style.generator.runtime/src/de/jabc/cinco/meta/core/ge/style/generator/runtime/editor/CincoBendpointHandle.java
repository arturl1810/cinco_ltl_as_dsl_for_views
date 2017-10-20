package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.tools.ConnectionBendpointTracker;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.impl.AddBendpointContext;
import org.eclipse.graphiti.features.context.impl.MoveBendpointContext;
import org.eclipse.graphiti.features.context.impl.RemoveBendpointContext;
import org.eclipse.graphiti.tb.IConnectionSelectionInfo;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFBendpointHandle;
import org.eclipse.swt.events.MouseEvent;

@SuppressWarnings("restriction")
class CincoBendpointHandle extends GFBendpointHandle {

	private String dragTrackerType;
	org.eclipse.graphiti.ui.internal.util.draw2d.GFCornerHandle h1;
	org.eclipse.graphiti.ui.internal.util.draw2d.GFSurroundingHandle h2;

	public CincoBendpointHandle(ConnectionEditPart owner, int index, int locatorIndex,
			IConfigurationProviderInternal configurationProvider, Type type,
			IConnectionSelectionInfo connectionSelectionInfo) {
		super(owner, index, locatorIndex, configurationProvider, type, connectionSelectionInfo);
		
		if (Type.CREATE.equals(type)) {
			dragTrackerType = RequestConstants.REQ_CREATE_BENDPOINT;
		} else if (Type.MOVE.equals(type)) {
			dragTrackerType = RequestConstants.REQ_MOVE_BENDPOINT;
		}
	}
	
	@Override
	protected DragTracker createDragTracker() {
		ConnectionBendpointTracker tracker = null;
		if (dragTrackerType != null) {
			if (((dragTrackerType.equals(RequestConstants.REQ_MOVE_BENDPOINT)) && checkMoveBendpointFeature())
					|| ((dragTrackerType.equals(RequestConstants.REQ_CREATE_BENDPOINT)) && checkRemoveBendpointFeature())) {
				tracker = new ConnectionBendpointTracker((ConnectionEditPart) getOwner(), getIndex()) {
					
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
				tracker.setType(dragTrackerType);
				tracker.setDefaultCursor(getCursor());
			}
		}
		return tracker;
	}
	
	private boolean checkMoveBendpointFeature() {
		boolean ret = false;
		IFeatureProvider fp = getConfigurationProvider().getFeatureProvider();
		ret = (null != fp.getMoveBendpointFeature(new MoveBendpointContext(null)));
		return ret;
	}

	private boolean checkAddBendpointFeature() {
		boolean ret = false;
		IFeatureProvider fp = getConfigurationProvider().getFeatureProvider();
		ret = (null != fp.getAddBendpointFeature(new AddBendpointContext(null, 0, 0, 0)));
		return ret;
	}

	private boolean checkRemoveBendpointFeature() {
		boolean ret = false;
		IFeatureProvider fp = getConfigurationProvider().getFeatureProvider();
		ret = (null != fp.getRemoveBendpointFeature(new RemoveBendpointContext(null, null)));
		return ret;
	}
}