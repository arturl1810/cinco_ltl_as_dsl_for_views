package de.jabc.cinco.meta.plugin.gratext.runtime.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.Bendpoint;
import org.eclipse.draw2d.ConnectionLocator;
import org.eclipse.draw2d.Cursors;
import org.eclipse.draw2d.PositionConstants;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.DragTracker;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.Handle;
import org.eclipse.gef.RequestConstants;
import org.eclipse.gef.SharedCursors;
import org.eclipse.gef.editpolicies.NonResizableEditPolicy;
import org.eclipse.gef.handles.AbstractHandle;
import org.eclipse.gef.handles.BendpointHandle;
import org.eclipse.gef.handles.MoveHandle;
import org.eclipse.gef.handles.ResizableHandleKit;
import org.eclipse.gef.tools.ConnectionBendpointTracker;
import org.eclipse.gef.tools.ConnectionEndpointTracker;
import org.eclipse.gef.tools.DragEditPartsTracker;
import org.eclipse.gef.tools.ResizeTracker;
import org.eclipse.gef.tools.SelectEditPartTracker;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.IResizeShapeFeature;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.features.context.impl.AddBendpointContext;
import org.eclipse.graphiti.features.context.impl.MoveBendpointContext;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.features.context.impl.RemoveBendpointContext;
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext;
import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.tb.IConnectionSelectionInfo;
import org.eclipse.graphiti.tb.IShapeSelectionInfo;
import org.eclipse.graphiti.tb.IToolBehaviorProvider;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.config.ConfigurationProvider;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.parts.AdvancedAnchorEditPart;
import org.eclipse.graphiti.ui.internal.parts.ShapeEditPart;
import org.eclipse.graphiti.ui.internal.policy.ConnectionBendpointEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.ConnectionHighlightEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.DefaultEditPolicyFactory;
import org.eclipse.graphiti.ui.internal.policy.GFConnectionEndpointTracker;
import org.eclipse.graphiti.ui.internal.policy.GFResizableEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.IEditPolicyFactory;
import org.eclipse.graphiti.ui.internal.policy.ShapeContainerAndXYLayoutEditPolicy;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFBendpointHandle;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFConnectionEndpointHandle;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFCornerHandle;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFSurroundingHandle;
import org.eclipse.swt.events.MouseEvent;

/**
 * 
 * @author Steve Bosselmann
 */
public class CincoConfigurationProvider extends ConfigurationProvider {

	public CincoConfigurationProvider(DiagramBehavior diagramBehavior, IDiagramTypeProvider diagramTypeProvider) {
		super(diagramBehavior, diagramTypeProvider);
	}

	IEditPolicyFactory editPolicyFactory;
	
	@Override
	public IEditPolicyFactory getEditPolicyFactory() {
		if (editPolicyFactory == null && !isDisposed()) {
			editPolicyFactory = new CustomEditPolicyFactory(this);
		}
		return editPolicyFactory;
	}
	
	@Override
	public void dispose() {
		editPolicyFactory = null;
		super.dispose();
	}
	
	
	static class CustomEditPolicyFactory extends DefaultEditPolicyFactory {
		
		public CustomEditPolicyFactory(IConfigurationProviderInternal configurationProvider) {
			super(configurationProvider);
		}

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
		
//		public EditPolicy createConnectionDeleteEditPolicy(IConfigurationProvider configurationProvider) {
//			return new CustomConnectionEditPolicy(configurationProvider);
//		}
		
		public EditPolicy createShapeXYLayoutEditPolicy() {
			
			return new CustomShapeContainerAndXYLayoutEditPolicy(getConfigurationProvider());
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
	}
	
	
//	static class CustomConnectionEditPolicy extends DefaultConnectionEditPolicy {
//
//		public CustomConnectionEditPolicy(IConfigurationProvider configurationProvider) {
//			super(configurationProvider);
//		}
//		
//		@Override
//		protected Command getCreateCommand(CreateRequest request) {
//			// TODO 
//		}
//	}
	
	
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
	
	static class CustomGFBendpointHandle extends GFBendpointHandle {

		private String dragTrackerType;
		org.eclipse.graphiti.ui.internal.util.draw2d.GFCornerHandle h1;
		org.eclipse.graphiti.ui.internal.util.draw2d.GFSurroundingHandle h2;

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
	
	static class CustomShapeContainerAndXYLayoutEditPolicy extends ShapeContainerAndXYLayoutEditPolicy {

		protected CustomShapeContainerAndXYLayoutEditPolicy(IConfigurationProviderInternal configurationProvider) {
			super(configurationProvider);
		}
		
		@Override
		protected EditPolicy createChildEditPolicy(EditPart child) {
			if (child instanceof AdvancedAnchorEditPart) {
				return new CustomGFResizableEditPolicy(getConfigurationProvider());
			}
			if (!(child instanceof ShapeEditPart)) {
				return new NonResizableEditPolicy();
			}
			PictogramElement pictogramElement = ((ShapeEditPart) child).getPictogramElement();
			Shape shape = (Shape) pictogramElement;
			ResizeShapeContext resizeShapeContext = new ResizeShapeContext(shape);
			return new CustomGFResizableEditPolicy(getConfigurationProvider(), resizeShapeContext);
		}
	}
	
	static class CustomGFResizableEditPolicy extends GFResizableEditPolicy {

		private IResizeShapeContext context;
		
		public CustomGFResizableEditPolicy(IConfigurationProviderInternal cfgProvider) {
			super(cfgProvider);
		}
		
		public CustomGFResizableEditPolicy(IConfigurationProviderInternal configurationProvider, IResizeShapeContext resizeShapeContext) {
			super(configurationProvider, resizeShapeContext);
			context = resizeShapeContext;
		}
		
		@Override
		protected SelectEditPartTracker getSelectTracker() {
			return new CustomSelectEditPartTracker(getHost());
		}

		@Override
		protected DragEditPartsTracker getDragTracker() {
			return new CustomDragEditPartsTracker(getHost());
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

			list.add(new CustomGFSurroundingHandle(owner, cp, movable, si));

			if (resizeAllowed) {
				if ((PositionConstants.NORTH_EAST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.NORTH_EAST, supportedResizeDirections,
							movable, si));
				if ((PositionConstants.SOUTH_EAST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.SOUTH_EAST, supportedResizeDirections,
							movable, si));
				if ((PositionConstants.SOUTH_WEST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.SOUTH_WEST, supportedResizeDirections,
							movable, si));
				if ((PositionConstants.NORTH_WEST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.NORTH_WEST, supportedResizeDirections,
							movable, si));
				if ((PositionConstants.NORTH & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.NORTH, supportedResizeDirections, movable, si));
				if ((PositionConstants.EAST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.EAST, supportedResizeDirections, movable, si));
				if ((PositionConstants.SOUTH & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.SOUTH, supportedResizeDirections, movable, si));
				if ((PositionConstants.WEST & supportedResizeDirections) != 0)
					list.add(new CustomGFCornerHandle(owner, cp, PositionConstants.WEST, supportedResizeDirections, movable, si));
			}

			return list;
		}
	}
	
	static class CustomSelectEditPartTracker extends SelectEditPartTracker {

		public CustomSelectEditPartTracker(EditPart owner) {
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
	
	static class CustomDragEditPartsTracker extends DragEditPartsTracker {

		public CustomDragEditPartsTracker(EditPart sourceEditPart) {
			super(sourceEditPart);
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
	
	static class CustomResizeTracker extends ResizeTracker {

		public CustomResizeTracker(GraphicalEditPart owner, int direction) {
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
	
	static class CustomGFSurroundingHandle extends GFSurroundingHandle {

		private boolean movable;

		public CustomGFSurroundingHandle(GraphicalEditPart owner, IConfigurationProviderInternal configurationProvider,
				boolean movable, IShapeSelectionInfo shapeSelectionInfo) {
			super(owner, configurationProvider, movable, shapeSelectionInfo);
			this.movable = movable;
		}
		
		@Override
		protected DragTracker createDragTracker() {
			if (movable) {
				DragEditPartsTracker tracker = new CustomDragEditPartsTracker(getOwner());
				tracker.setDefaultCursor(getCursor());
				return tracker;
			} else {
				return null;
			}
		}
	}
	
	static class CustomGFCornerHandle extends GFCornerHandle {

		private int resizeDirection;
		private boolean movable;

		public CustomGFCornerHandle(GraphicalEditPart owner, IConfigurationProviderInternal configurationProvider,
				int location, int supportedResizeDirections, boolean movable, IShapeSelectionInfo shapeSelectionInfo) {
			super(owner, configurationProvider, location, supportedResizeDirections, movable, shapeSelectionInfo);
			this.resizeDirection = supportedResizeDirections & location;
			this.movable = movable;
		}
		
		@Override
		protected DragTracker createDragTracker() {
			if (resizeDirection != 0) { // if is resizable
				return new CustomResizeTracker(getOwner(), resizeDirection);
			} else if (movable) {
				DragEditPartsTracker tracker = new CustomDragEditPartsTracker(getOwner());
				tracker.setDefaultCursor(getCursor());
				return tracker;
			} else {
				return null;
			}
		}
		
	}
}
