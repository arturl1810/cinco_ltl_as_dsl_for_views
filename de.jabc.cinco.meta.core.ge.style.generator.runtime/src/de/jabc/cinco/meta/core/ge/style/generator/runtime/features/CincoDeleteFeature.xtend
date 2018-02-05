package de.jabc.cinco.meta.core.ge.style.generator.runtime.features

import de.jabc.cinco.meta.runtime.contentadapter.CincoEContentAdapter
import graphmodel.internal.InternalContainer
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import java.util.ArrayList
import java.util.List
import java.util.stream.Collectors
import org.eclipse.emf.common.notify.Adapter
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IRemoveFeature
import org.eclipse.graphiti.features.context.IDeleteContext
import org.eclipse.graphiti.features.context.IMultiDeleteInfo
import org.eclipse.graphiti.features.context.IRemoveContext
import org.eclipse.graphiti.features.context.impl.RemoveContext
import org.eclipse.graphiti.features.impl.DefaultRemoveFeature
import org.eclipse.graphiti.mm.pictograms.CompositeConnection
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.features.DefaultDeleteFeature

abstract class CincoDeleteFeature extends DefaultDeleteFeature {
	 
	 new(IFeatureProvider fp) {
		super(fp)// TODO Auto-generated constructor stub
		
	}
	
	def abstract boolean canDelete(IDeleteContext dc, boolean apiCall) 
	
	override void preDelete(IDeleteContext context) {
		super.preDelete(context) 
		var Object bo=getBusinessObjectForPictogramElement(context.getPictogramElement()) 
		switch (bo) {
			InternalEdge: bo.removeAdapter
			InternalNode: {
				bo.outgoing.forEach[removeAdapter]
				bo.incoming.forEach[removeAdapter]
				bo.removeAdapter
			}
		}
	}
	override void postDelete(IDeleteContext context) {
		var Object object=getBusinessObjectForPictogramElement(getDiagram()) 
		if (!(object instanceof InternalGraphModel)) return;
		var InternalModelElementContainer mec=(object as InternalModelElementContainer) 
		deleteDanglingEdges(mec) 
	}
	/**
	 * 
	 * @see DefaultDeleteFeature#delete(org.eclipse.graphiti.features.context.IDeleteContext)
	 * Copied the method from @see DefaultDeleteFeature#delete(org.eclipse.graphiti.features.context.IDeleteContext)
	 * with one change: The required remove feature is created instead of retrieved from the feature provider. As consequence, it is possible to 
	 * disable the default "Remove" entry in the context menu. 
	 */
	override void delete(IDeleteContext context) {
		// we need this reset, since the an instance of this feature can be
		// used multiple times, e.g. as a part of a pattern
		setDoneChanges(false) 
		var IMultiDeleteInfo multiDeleteInfo=context.getMultiDeleteInfo() 
		if (multiDeleteInfo !== null && multiDeleteInfo.isDeleteCanceled()) {
			return;
		}
		var PictogramElement pe=context.getPictogramElement() 
		var Object[] businessObjectsForPictogramElement=getAllBusinessObjectsForPictogramElement(pe) 
		if (businessObjectsForPictogramElement !== null && businessObjectsForPictogramElement.length > 0) {
			if (multiDeleteInfo === null) {
				if (!getUserDecision(context)) {
					return;
				}
			} else {
				if (multiDeleteInfo.isShowDialog()) {
					var boolean okPressed=getUserDecision(context) 
					if (okPressed) {
						// don't show further dialogs
						multiDeleteInfo.setShowDialog(false) 
					} else {
						multiDeleteInfo.setDeleteCanceled(true) 
						return;
					}
				}
			}
		}
		preDelete(context) 
		if (pe instanceof CompositeConnection) {
			// Find all domain objects for the children connections of the
			// composite connection...
			var List<Object> compositeChildConnectionsBOs=collectCompositeConnectionsBOs((pe as CompositeConnection)) 
			// ... and add them to the list of BOs to delete (no duplicates)
			for (Object object : businessObjectsForPictogramElement) {
				if (!compositeChildConnectionsBOs.contains(object)) {
					compositeChildConnectionsBOs.add(object) 
				}
			}
			// Update BOs to delete
			businessObjectsForPictogramElement=compositeChildConnectionsBOs.toArray(newArrayOfSize(compositeChildConnectionsBOs.size())) 
		}
		var IRemoveContext rc=new RemoveContext(pe) 
		var IRemoveFeature removeFeature=new DefaultRemoveFeature(getFeatureProvider()) 
		if (removeFeature !== null) {
			removeFeature.remove(rc) 
			// Bug 347421: Set hasDoneChanges flag only after first modification
			setDoneChanges(true) 
		}
		deleteBusinessObjects(businessObjectsForPictogramElement) 
		postDelete(context) 
	}
	
	def private void deleteDanglingEdges(InternalModelElementContainer mec) {
		var List<InternalEdge> danglingEdges=mec.getModelElements().stream().filter([e | e instanceof InternalEdge]).map([e | (e as InternalEdge)]).filter([e | e.get_sourceElement() === null || e.get_targetElement() === null]).collect(Collectors.toList()) 
		var List<PictogramElement> pes=Graphiti.getLinkService().getPictogramElements(getDiagram(), danglingEdges.stream().map([e | (e as EObject)]).collect(Collectors.toList()), true) 
		//		List<PictogramElement> pes = Graphiti.getLinkService().getPictogramElements(getDiagram(), danglingEdges.stream().map(e -> (EObject) e).collect(Collectors.toList()), false);
		deleteBusinessObjects(danglingEdges.toArray(newArrayOfSize(0))) 
		deleteBusinessObjects(pes.toArray(newArrayOfSize(pes.size()))) 
		mec.getModelElements().stream().filter([me | me instanceof InternalContainer]).forEach([c | deleteDanglingEdges((c as InternalModelElementContainer))]) 
	}
	def private List<Object> collectCompositeConnectionsBOs(CompositeConnection composite) {
		var List<Object> result=new ArrayList<Object>() 
		for (Connection childConnection : composite.getChildren()) {
			var Object[] allBusinessObjectsForChildConnection=getAllBusinessObjectsForPictogramElement(childConnection) 
			for (Object object : allBusinessObjectsForChildConnection) {
				if (!result.contains(object)) {
					result.add(object) 
				}
			}
		}
		return result 
	}
	def private void removeAdapter(InternalModelElement me) {
		var int index=-1 
		for (Adapter a : me.eAdapters()) {
			if (a instanceof CincoEContentAdapter) {
				index=me.eAdapters().indexOf(a) 
			}
		}
		if (index >= 0) me.eAdapters().remove(index) 
	}
}