package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.Bendpoint;
import org.eclipse.draw2d.ConnectionLocator;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.Handle;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.handles.BendpointHandle;
import org.eclipse.gef.tools.ConnectionBendpointTracker;
import org.eclipse.gef.tools.ConnectionEndpointTracker;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.context.impl.AddBendpointContext;
import org.eclipse.graphiti.features.context.impl.MoveBendpointContext;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.features.context.impl.RemoveBendpointContext;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.tb.IConnectionSelectionInfo;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.config.ConfigurationProvider;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.policy.ConnectionBendpointEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.ConnectionHighlightEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.DefaultEditPolicyFactory;
import org.eclipse.graphiti.ui.internal.policy.GFConnectionEndpointTracker;
import org.eclipse.graphiti.ui.internal.policy.IEditPolicyFactory;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFBendpointHandle;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFConnectionEndpointHandle;
import org.eclipse.swt.events.MouseEvent;



public class CincoConfigurationProvider extends ConfigurationProvider {

	public CincoConfigurationProvider(DiagramBehavior diagramBehavior, IDiagramTypeProvider diagramTypeProvider) {
		super(diagramBehavior, diagramTypeProvider);
	}

	IEditPolicyFactory editPolicyFactory;
	
	@Override
	public IEditPolicyFactory getEditPolicyFactory() {
		if (editPolicyFactory == null && !isDisposed()) {
			editPolicyFactory = new DefaultEditPolicyFactory(this) {
				
				public EditPolicy createConnectionBendpointsEditPolicy() {
					return new ConnectionBendpointEditPolicy(getConfigurationProvider()) {
						
						private IConnectionSelectionInfo csi;

						@Override
						public void activate() {
							super.activate();
							Object model = getHost().getModel();
							if (model instanceof Connection) {
								csi = getConfigurationProvider()
										.getDiagramTypeProvider()
										.getCurrentToolBehaviorProvider()
										.getSelectionInfoForConnection((Connection) model);
							}
						}
						
						@Override
						protected List<BendpointHandle> createHandlesForAutomaticBendpoints() {
							List<BendpointHandle> list = new ArrayList<BendpointHandle>();
							ConnectionEditPart connEP = (ConnectionEditPart) getHost();
							PointList points = getConnection().getPoints();
							for (int i = 0; i < points.size() - 1; i++) {
								// CHANGED: create GFBendpointCreationHandle instead of
								// BendpointCreationHandle
								list.add(new GFBendpointHandle(connEP, 0, i, getConfigurationProvider(), GFBendpointHandle.Type.CREATE,	csi));
							}

							return list;
						}
						
						@Override
						protected List<BendpointHandle> createHandlesForUserBendpoints() {
							List<BendpointHandle> list = new ArrayList<BendpointHandle>();
							ConnectionEditPart connEP = (ConnectionEditPart) getHost();
							PointList points = getConnection().getPoints();
							List<Bendpoint> bendPoints = getConnectionRoutingConstraint();
							int bendPointIndex = 0;
							org.eclipse.draw2d.geometry.Point currBendPoint = null;

							if (bendPoints == null)
								bendPoints = NULL_CONSTRAINT;
							else if (!bendPoints.isEmpty())
								currBendPoint = bendPoints.get(0).getLocation();

							for (int i = 0; i < points.size() - 1; i++) {
								// Put a create handle on the middle of every segment
								// CHANGED: create GFBendpointCreationHandle instead of
								// BendpointCreationHandle
								list.add(new CustomGFBendpointHandle(connEP, bendPointIndex, i, getConfigurationProvider(),
										GFBendpointHandle.Type.CREATE, csi));

								// If the current user bendpoint matches a bend location, show a
								// move handle
								if (i < points.size() - 1 && bendPointIndex < bendPoints.size()
										&& currBendPoint.equals(points.getPoint(i + 1))) {
									// CHANGED: create GFBendpointMoveHandle instead of
									// BendpointMoveHandle
									list.add(new CustomGFBendpointHandle(connEP, bendPointIndex, i + 1, getConfigurationProvider(),
											GFBendpointHandle.Type.MOVE, csi));

									// Go to the next user bendpoint
									bendPointIndex++;
									if (bendPointIndex < bendPoints.size())
										currBendPoint = bendPoints.get(bendPointIndex).getLocation();
								}
							}

							return list;
						}
						
					};
				}
				
				/**
				 * Custom handles fix an issue of not correctly recognizing the movement
				 * of connection points.
				 */
				@Override
				public EditPolicy createConnectionHighlightEditPolicy() {
					return new ConnectionHighlightEditPolicy(getConfigurationProvider()) {
						
						@Override
						protected List<Handle> createSelectionHandles() {
							List<Handle> list = new ArrayList<Handle>();
							Connection connection = (Connection) getHost().getModel();
							ReconnectionContext sourceCtx = new ReconnectionContext(connection, connection.getStart(), null, null);
							ReconnectionContext targetCtx = new ReconnectionContext(connection, connection.getEnd(), null, null);
							IReconnectionFeature sourceReconnectionFeature = getConfigurationProvider().getFeatureProvider()
									.getReconnectionFeature(sourceCtx);
							IReconnectionFeature targetReconnectionFeature = getConfigurationProvider().getFeatureProvider()
									.getReconnectionFeature(targetCtx);
							// add endpoint handles only if they can start reconnect
							if (sourceReconnectionFeature == null || sourceReconnectionFeature.canStartReconnect(sourceCtx)) {
								list.add(new CustomGFConnectionEndpointHandle((ConnectionEditPart) getHost(), ConnectionLocator.SOURCE));
							}
							if (targetReconnectionFeature == null || targetReconnectionFeature.canStartReconnect(targetCtx)) {
								list.add(new CustomGFConnectionEndpointHandle((ConnectionEditPart) getHost(), ConnectionLocator.TARGET));
							}
							return list;
						}
					};
				}
				
			};
		}
		return editPolicyFactory;
	}
	
	@Override
	public void dispose() {
		editPolicyFactory = null;
		super.dispose();
	}
	
	
	static class CustomGFConnectionEndpointHandle extends GFConnectionEndpointHandle {

		public CustomGFConnectionEndpointHandle(ConnectionEditPart owner, int endPoint) {
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
						if (!wasDragging)
							handleDragStarted();
						
						// Fixes an issue of not correctly recognizing the movement
						// of connection points.
						else if (getState() == 1) // STATE_INITIAL
							stateTransition(1, 4); // STATE_INITIAL  ==>  STATE_DRAG_IN_PROGRESS
							
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
	
	static class CustomGFBendpointHandle extends GFBendpointHandle {

		private String dragTrackerType;

		public CustomGFBendpointHandle(ConnectionEditPart owner, int index, int locatorIndex,
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
								if (!wasDragging)
									handleDragStarted();
								
								// Fixes an issue of not correctly recognizing the movement
								// of connection points.
								else if (getState() == 1)
									stateTransition(1, 4);
									
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
}
