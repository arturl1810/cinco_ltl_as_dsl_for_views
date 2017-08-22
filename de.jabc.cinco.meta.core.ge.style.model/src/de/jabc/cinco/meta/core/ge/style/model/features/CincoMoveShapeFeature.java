package de.jabc.cinco.meta.core.ge.style.model.features;

import org.eclipse.graphiti.datatypes.ILocation;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IMoveShapeContext;
import org.eclipse.graphiti.features.context.impl.MoveShapeContext;
import org.eclipse.graphiti.features.impl.DefaultMoveShapeFeature;
import org.eclipse.graphiti.internal.datatypes.impl.LocationImpl;
import org.eclipse.graphiti.ui.services.GraphitiUi;

import de.jabc.cinco.meta.core.ge.style.model.errorhandling.ECincoError;

public class CincoMoveShapeFeature extends DefaultMoveShapeFeature {

	public CincoMoveShapeFeature(IFeatureProvider fp) {
		super(fp);
	}

	@Override
	protected void moveAllBendpoints(IMoveShapeContext context) {
		MoveShapeContext msc = new MoveShapeContext(context.getShape());
		msc.setSourceContainer(context.getSourceContainer());
		msc.setTargetContainer(context.getTargetContainer());
		msc.setDeltaX(context.getDeltaX());
		msc.setDeltaY(context.getDeltaY());
		msc.setX(context.getX());
		msc.setY(context.getY());
		computeLocationsShift(msc);
		super.moveAllBendpoints(msc);
	}

	private void computeLocationsShift(MoveShapeContext msc) {
		ILocation trgLoc = GraphitiUi.getUiLayoutService().getLocationRelativeToDiagram(msc.getTargetContainer());
		ILocation srcLoc = GraphitiUi.getUiLayoutService().getLocationRelativeToDiagram(msc.getSourceContainer());

		ILocation location = new LocationImpl(trgLoc.getX() - srcLoc.getX(), trgLoc.getY() - srcLoc.getY());
		msc.setX(msc.getX() + location.getX());
		msc.setY(msc.getY() + location.getY());
				
	}
	
	public boolean canMoveShape(IMoveShapeContext context, boolean apiCall) {
		return canMoveShape(context); // default implementation ignores apiCall flag
	}
	
	public ECincoError getError() {
		return null;
	}
}
