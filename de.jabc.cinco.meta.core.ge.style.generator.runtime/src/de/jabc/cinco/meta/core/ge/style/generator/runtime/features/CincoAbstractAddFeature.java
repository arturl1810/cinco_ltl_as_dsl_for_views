package de.jabc.cinco.meta.core.ge.style.generator.runtime.features;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IAddContext;
import org.eclipse.graphiti.features.context.impl.AddBendpointContext;
import org.eclipse.graphiti.features.impl.AbstractAddFeature;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;

import graphmodel.internal.InternalEdge;
import graphmodel.internal._Point;

public class CincoAbstractAddFeature extends AbstractAddFeature {

	protected boolean hook = true;
	
	public CincoAbstractAddFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean canAdd(IAddContext context) {
		return false;
	}

	@Override
	public PictogramElement add(IAddContext context) {
		return null;
	}
	
	public void setHook(boolean activateHook) {
		hook = activateHook;
	}
	
	protected void addBendpoints(InternalEdge edge, Connection conn) {
		if (!(conn instanceof FreeFormConnection)) throw new RuntimeException("Can add bendpoints only to free form connection");
		for (_Point bp : edge.getBendpoints()) {
			CincoAddBendpointFeature af = new CincoAddBendpointFeature(getFeatureProvider());
			AddBendpointContext ac = new AddBendpointContext((FreeFormConnection) conn, bp.getX(), bp.getY(), edge.getBendpoints().indexOf(bp));
			if (af.canAddBendpoint(ac))
				af.addBendpoint(ac);
		}
			
	}
	
}
