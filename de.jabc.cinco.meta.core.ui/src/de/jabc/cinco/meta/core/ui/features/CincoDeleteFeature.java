package de.jabc.cinco.meta.core.ui.features;

import graphmodel.Edge;
import graphmodel.GraphModel;
import graphmodel.ModelElementContainer;
import graphmodel.Node;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.graphiti.features.IDeleteFeature;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.context.IDeleteContext;
import org.eclipse.graphiti.features.context.impl.DeleteContext;
import org.eclipse.graphiti.features.context.impl.RemoveContext;
import org.eclipse.graphiti.features.impl.DefaultRemoveFeature;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.features.DefaultDeleteFeature;

public class CincoDeleteFeature extends DefaultDeleteFeature {

	public CincoDeleteFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

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
		Object bo = getBusinessObjectForPictogramElement(context.getPictogramElement());
		if (bo instanceof Node) {
			List<Edge> all = new ArrayList<Edge>();
			all.addAll(((Node) bo).getIncoming());
			all.addAll(((Node) bo).getOutgoing());
			for (Edge e : all) {
				PictogramElement pe = Graphiti.getLinkService().getPictogramElements(getDiagram(), e).get(0);
				DeleteContext dc = new DeleteContext(pe);
				IDeleteFeature df = getFeatureProvider().getDeleteFeature(dc);
				if (df.canDelete(dc))
					df.delete(dc);
				RemoveContext rc = new RemoveContext(pe);
				DefaultRemoveFeature drf = new DefaultRemoveFeature(getFeatureProvider());
				if (drf.canRemove(rc))
					drf.remove(rc);
			}
		}
		super.delete(context);
		RemoveContext rc = new RemoveContext(context.getPictogramElement());
		DefaultRemoveFeature drf = new DefaultRemoveFeature(getFeatureProvider());
		if (drf.canRemove(rc))
			drf.remove(rc);
	}
	
	private void deleteDanglingEdges(ModelElementContainer mec) {
		List<Edge> danglingEdges = mec.getAllEdges().stream().filter(e -> e.getSourceElement() == null || e.getTargetElement() == null).collect(Collectors.toList());
		deleteBusinessObjects(danglingEdges.toArray(new graphmodel.Edge[0]));
		mec.getAllContainers().forEach(c -> deleteDanglingEdges(c));
	}

	
	
}
