package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.draw2d.Bendpoint;
import org.eclipse.draw2d.ConnectionLocator;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.gef.ConnectionEditPart;
import org.eclipse.gef.EditPolicy;
import org.eclipse.gef.Handle;
import org.eclipse.gef.handles.BendpointHandle;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.tb.IConnectionSelectionInfo;
import org.eclipse.graphiti.ui.internal.config.IConfigurationProviderInternal;
import org.eclipse.graphiti.ui.internal.policy.ConnectionBendpointEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.ConnectionHighlightEditPolicy;
import org.eclipse.graphiti.ui.internal.policy.DefaultEditPolicyFactory;
import org.eclipse.graphiti.ui.internal.util.draw2d.GFBendpointHandle;

public class CincoEditPolicyFactory extends DefaultEditPolicyFactory {

	public CincoEditPolicyFactory(IConfigurationProviderInternal configurationProvider) {
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
					list.add(new CincoBendpointHandle(connEP, bendPointIndex, i, getConfigurationProvider(),
							GFBendpointHandle.Type.CREATE, csi));

					// If the current user bendpoint matches a bend location, show a
					// move handle
					if (i < points.size() - 1 && bendPointIndex < bendPoints.size()
							&& currBendPoint.equals(points.getPoint(i + 1))) {
						// CHANGED: create GFBendpointMoveHandle instead of
						// BendpointMoveHandle
						list.add(new CincoBendpointHandle(connEP, bendPointIndex, i + 1, getConfigurationProvider(),
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
	
//	public EditPolicy createConnectionDeleteEditPolicy(IConfigurationProvider configurationProvider) {
//		return new CustomConnectionEditPolicy(configurationProvider);
//	}
	
	public EditPolicy createShapeXYLayoutEditPolicy() {
		
		return new CincoShapeContainerAndXYLayoutEditPolicy(getConfigurationProvider());
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
					list.add(new CincoConnectionEndpointHandle((ConnectionEditPart) getHost(), ConnectionLocator.SOURCE));
				}
				if (targetReconnectionFeature == null || targetReconnectionFeature.canStartReconnect(targetCtx)) {
					list.add(new CincoConnectionEndpointHandle((ConnectionEditPart) getHost(), ConnectionLocator.TARGET));
				}
				return list;
			}
		};
	}
}
