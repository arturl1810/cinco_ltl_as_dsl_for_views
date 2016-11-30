package de.jabc.cinco.meta.core.ge.style.model.features;

import graphmodel.Edge;
import graphmodel.Node;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IReconnectionContext;
import org.eclipse.graphiti.features.context.impl.ReconnectionContext;
import org.eclipse.graphiti.features.impl.DefaultReconnectionFeature;
import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.AnchorContainer;

public class CincoReconnectFeature extends DefaultReconnectionFeature{

	public CincoReconnectFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canReconnect(IReconnectionContext context) {
		String reconnectionType = context.getReconnectType();
		Anchor anchor = context.getNewAnchor();
//		Node node = getNodeForAnchor(anchor);
		EObject edge= context.getConnection().getLink().getBusinessObjects().get(0);
		if (!(edge instanceof Edge))
			return false;
			
		if (ReconnectionContext.RECONNECT_SOURCE.equals(reconnectionType)) {
//			return ((Edge) edge).getEdgeView().canReconnectSource(node);
		}
		if (ReconnectionContext.RECONNECT_TARGET.equals(reconnectionType)) {
//			return ((Edge) edge).getEdgeView().canReconnectTarget(node);
		}
		return false; 
	}
	
	@Override
	public void postReconnect(IReconnectionContext context) {
		String reconnectionType = context.getReconnectType();
		Anchor anchor = context.getNewAnchor();
		Node node = getNodeForAnchor(anchor);
		EObject edge= context.getConnection().getLink().getBusinessObjects().get(0);
		if (!(edge instanceof Edge))
			return;
		
		if (ReconnectionContext.RECONNECT_SOURCE.equals(reconnectionType)) {
//			((Edge) edge).getEdgeView().reconnectSource(node);
		}
		if (ReconnectionContext.RECONNECT_TARGET.equals(reconnectionType)) {
//			((Edge) edge).getEdgeView().reconnectTarget(node);
		}
	}
	
	private Node getNodeForAnchor(Anchor anchor) {
		AnchorContainer parent = anchor.getParent();
		EObject obj = parent.getLink().getBusinessObjects().get(0);
		if (obj instanceof Node) {
			return (Node) obj;
		}
		
		return null;
	}
}
