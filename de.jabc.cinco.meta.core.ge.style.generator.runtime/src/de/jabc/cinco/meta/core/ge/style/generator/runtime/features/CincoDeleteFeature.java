package de.jabc.cinco.meta.core.ui.features;

import graphmodel.Edge;
import graphmodel.GraphModel;
import graphmodel.ModelElementContainer;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.features.IRemoveFeature;
import org.eclipse.graphiti.features.context.IDeleteContext;
import org.eclipse.graphiti.features.context.IMultiDeleteInfo;
import org.eclipse.graphiti.features.context.IRemoveContext;
import org.eclipse.graphiti.features.context.impl.RemoveContext;
import org.eclipse.graphiti.features.impl.DefaultRemoveFeature;
import org.eclipse.graphiti.mm.pictograms.CompositeConnection;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.features.DefaultDeleteFeature;

public abstract class CincoDeleteFeature extends DefaultDeleteFeature {

	public CincoDeleteFeature(IFeatureProvider fp) {
		super(fp);
		// TODO Auto-generated constructor stub
	}

	public abstract boolean canDelete(IDeleteContext dc, boolean apiCall);
	
	@Override
	public void preDelete(IDeleteContext context) {
		super.preDelete(context);
	}
	
	@Override
	public void postDelete(IDeleteContext context) {
		Object object = getBusinessObjectForPictogramElement(getDiagram());
		
		if (!(object instanceof GraphModel))
			return;
		
		ModelElementContainer mec = (ModelElementContainer) object;
		deleteDanglingEdges(mec);
	}

	/*
	 * (non-Javadoc)
	 * @see org.eclipse.graphiti.ui.features.DefaultDeleteFeature#delete(org.eclipse.graphiti.features.context.IDeleteContext)
	 * Copied the method from @see org.eclipse.graphiti.ui.features.DefaultDeleteFeature#delete(org.eclipse.graphiti.features.context.IDeleteContext)
	 * with one change: The required remove feature is created instead of retrieved from the feature provider. As consequence, it is possible to 
	 * disable the default "Remove" entry in the context menu. 
	 */
	@Override
	public void delete(IDeleteContext context) {
		// we need this reset, since the an instance of this feature can be
				// used multiple times, e.g. as a part of a pattern
				setDoneChanges(false);

				IMultiDeleteInfo multiDeleteInfo = context.getMultiDeleteInfo();
				if (multiDeleteInfo != null && multiDeleteInfo.isDeleteCanceled()) {
					return;
				}
				PictogramElement pe = context.getPictogramElement();
				Object[] businessObjectsForPictogramElement = getAllBusinessObjectsForPictogramElement(pe);
				if (businessObjectsForPictogramElement != null && businessObjectsForPictogramElement.length > 0) {
					if (multiDeleteInfo == null) {
						if (!getUserDecision(context)) {
							return;
						}
					} else {
						if (multiDeleteInfo.isShowDialog()) {
							boolean okPressed = getUserDecision(context);
							if (okPressed) {
								// don't show further dialogs
								multiDeleteInfo.setShowDialog(false);
							} else {
								multiDeleteInfo.setDeleteCanceled(true);
								return;
							}
						}
					}
				}

				preDelete(context);
				if (pe instanceof CompositeConnection) {
					// Find all domain objects for the children connections of the
					// composite connection...
					List<Object> compositeChildConnectionsBOs = collectCompositeConnectionsBOs((CompositeConnection) pe);
					// ... and add them to the list of BOs to delete (no duplicates)
					for (Object object : businessObjectsForPictogramElement) {
						if (!compositeChildConnectionsBOs.contains(object)) {
							compositeChildConnectionsBOs.add(object);
						}
					}
					// Update BOs to delete
					businessObjectsForPictogramElement = compositeChildConnectionsBOs
							.toArray(new Object[compositeChildConnectionsBOs.size()]);
				}
				IRemoveContext rc = new RemoveContext(pe);
				IRemoveFeature removeFeature = new DefaultRemoveFeature(getFeatureProvider());
				if (removeFeature != null) {
					removeFeature.remove(rc);
					// Bug 347421: Set hasDoneChanges flag only after first modification
					setDoneChanges(true);
				}

				deleteBusinessObjects(businessObjectsForPictogramElement);

				postDelete(context);
		
	}
	
	private void deleteDanglingEdges(ModelElementContainer mec) {
		List<Edge> danglingEdges = mec.getAllEdges().stream().filter(e -> e.getSourceElement() == null || e.getTargetElement() == null).collect(Collectors.toList());
		List<PictogramElement> pes = Graphiti.getLinkService().getPictogramElements(getDiagram(), danglingEdges.stream().map(e -> (EObject) e).collect(Collectors.toList()), true);
		deleteBusinessObjects(danglingEdges.toArray(new graphmodel.Edge[0]));
		deleteBusinessObjects(pes.toArray(new PictogramElement[pes.size()]));
		mec.getAllContainers().forEach(c -> deleteDanglingEdges(c));
	}

	private List<Object> collectCompositeConnectionsBOs(CompositeConnection composite) {
		List<Object> result = new ArrayList<Object>();
		for (Connection childConnection : composite.getChildren()) {
			Object[] allBusinessObjectsForChildConnection = getAllBusinessObjectsForPictogramElement(childConnection);
			for (Object object : allBusinessObjectsForChildConnection) {
				if (!result.contains(object)) {
					result.add(object);
				}
			}
		}
		return result;
	}
	
}
