package de.jabc.cinco.meta.runtime.hook

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.IUpdateFeature
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.emf.transaction.util.TransactionUtil
import org.eclipse.emf.transaction.TransactionalEditingDomain
import org.eclipse.emf.transaction.RecordingCommand

abstract class CincoPostCreateHook<T extends EObject> extends CincoRuntimeBaseClass {
	
	Diagram diagram

	def abstract void postCreate(T object)

	def void postCreateAndUpdate(T object, Diagram d) {
		this.diagram = d
		object.transact[
			postCreate(object)
			update(object)
		]
	}

	def private void update(T object) {
		var List<PictogramElement> linkedPictogramElements = Graphiti.getLinkService().
			getPictogramElements(getDiagram(), object)
		// if the element got deleted in the postCreateHook, linked elements will be empty
		if (linkedPictogramElements.isEmpty()) {
			return;
		}
		var UpdateContext uc = new UpdateContext((linkedPictogramElements.get(0) as PictogramElement))
		var IFeatureProvider provider = GraphitiUi.getExtensionManager().createFeatureProvider(getDiagram())
		var IUpdateFeature uf = provider.getUpdateFeature(uc)
		if(uf !== null && uf.canUpdate(uc)) uf.update(uc)
	}

	def Diagram getDiagram() {
		return diagram
	}

	def void setDiagram(Diagram diagram) {
		this.diagram = diagram
	}
}
