package de.jabc.cinco.meta.core.ui.features;

import graphmodel.Edge;
import graphmodel.GraphModel;
import graphmodel.ModelElementContainer;

import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IDeleteContext;
import org.eclipse.graphiti.ui.features.DefaultDeleteFeature;

public abstract class CincoDeleteFeature extends DefaultDeleteFeature {

	public CincoDeleteFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	public abstract boolean canDelete(IDeleteContext dc, boolean apiCall);
	
	@Override
	public void postDelete(IDeleteContext context) {
		Object object = getBusinessObjectForPictogramElement(getDiagram());
		if (!(object instanceof GraphModel))
			return;
		
		ModelElementContainer mec = (ModelElementContainer) object;
		deleteDanglingEdges(mec);
	}

	@Override
	public void delete(IDeleteContext context) {
		super.delete(context);
	}
	
	private void deleteDanglingEdges(ModelElementContainer mec) {
		List<Edge> danglingEdges = mec.getAllEdges().stream().filter(e -> e.getSourceElement() == null || e.getTargetElement() == null).collect(Collectors.toList());
		deleteBusinessObjects(danglingEdges.toArray(new graphmodel.Edge[0]));
		mec.getAllContainers().forEach(c -> deleteDanglingEdges(c));
	}

	
	
}
