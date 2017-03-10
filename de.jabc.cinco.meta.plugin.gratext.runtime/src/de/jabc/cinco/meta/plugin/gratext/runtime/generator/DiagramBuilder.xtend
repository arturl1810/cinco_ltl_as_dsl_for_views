package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import graphmodel.Edge
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.Node
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.LazyDiagram
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.AreaContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.swt.SWTException

import java.util.HashMap
import java.util.List
import java.util.Map

import static org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager
import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*


abstract class DiagramBuilder {
	
	extension val ResourceExtension = new ResourceExtension
	
	Map<IdentifiableElement, PictogramElement> pes = new HashMap

	GraphModel model
	LazyDiagram diagram
	IDiagramTypeProvider dtp
	IFeatureProvider fp
	
	new(LazyDiagram diagram, GraphModel model) {
		this.diagram = diagram
		this.model = model
	}
	
	def build(Resource resource) {
		diagram.initialization = [|
			diagram.linkTo(model.internalElement)
			nodes.map[internalElement].forEach[add]
			edges.map[internalElement].forEach[add]
			diagram.update
		]
		diagram.avoidInitialization = true
		resource.transact[
			resource.contents.add(0, diagram)
		]
		diagram.avoidInitialization = false
	}
	
	def add(InternalModelElement it) {
		switch it {
			InternalEdge: add(getAddContext)
			default: add(getAddContext(diagram))
		}
	}
	
	def add(InternalModelElement bo, AddContext ctx) {
		if (ctx != null) [
			bo.cache(ctx.addIfPossible)
			bo.postprocess
		].onException[switch it {
			SWTException case "Invalid thread access".equals(message): {
				bo.cache(featureProvider.getPictogramElementForBusinessObject(bo))
				bo.postprocess
			}
			default: printStackTrace
		}]
	}
	
	def postprocess(InternalModelElement bo) {
		val pe = bo.pe
		if (pe == null) {
			warn("Pictogram null. Failed to add " + bo)
		} else switch bo {
			InternalEdge: {
				addBendpoints(bo, pe)
				addDecorators(bo, pe as Connection)
			}
			InternalModelElementContainer :
				bo.modelElements.forEach[
					add(getAddContext(pe as ContainerShape))
				]
		}
	}
	
	def List<Pair<Integer,Integer>> getBendpoints(InternalEdge edge)
	
	def addBendpoints(InternalEdge edge, PictogramElement pe) {
		edge.bendpoints?.forEach[ point, i |
			add(point, (pe as FreeFormConnection), i)
		]
	}
	
	def add(Pair<Integer,Integer> p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.key, p.value, index)
		diagramTypeProvider.diagramBehavior.executeFeature(
			featureProvider.getAddBendpointFeature(ctx), ctx);
	}
	
	def addDecorators(InternalEdge edge, Connection con) {
		val size = con.connectionDecorators?.size
		for (var i = 0; i < size; i++)
			con.updateDecorator(i, edge.getDecoratorLocation(i))
	}
	
	def Pair<Integer,Integer> getDecoratorLocation(InternalEdge edge, int index)
	
	def updateDecorator(Connection con, int index, Pair<Integer,Integer> location) {
		val ga = [	
			con.connectionDecorators?.get(index)?.graphicsAlgorithm
		].printException
		if (ga != null && location != null) {
			ga.x = location.key
			ga.y = location.value
		} else warn("Failed to retrieve decorator shape (index=" + index + ") of " + con)
	}
	
	def addIfPossible(AddContext ctx) {
		val ftr = featureProvider.getAddFeature(ctx) as CincoAbstractAddFeature
		if (ftr != null) {
			ftr.setHook(false)
			if (ftr?.canAdd(ctx))
				featureProvider.diagramTypeProvider.diagramBehavior
					.executeFeature(ftr, ctx) as PictogramElement
		} else warn("Failed to retrieve AddFeature for " + ctx)
	}
	
	def getAddContext(InternalModelElement bo, ContainerShape target) {
		new AddContext(new AreaContext, bo) => [
			targetContainer = target
			x = bo.x
			y = bo.y
			width = bo.width
			height = bo.height
		]
	}
	
	def int getX(InternalModelElement element)
	
	def int getY(InternalModelElement element)
	
	def int getWidth(InternalModelElement element)
	
	def int getHeight(InternalModelElement element)
	
	def getAddContext(InternalEdge edge) {
		val srcAnchor = [
			edge.sourceElement.internalElement.pe.anchor
		].onException[
			warn("Failed to retrieve source of edge: " + edge.eClass.name + " " + edge.id)
		]
		val tgtAnchor = [
			edge.targetElement.internalElement.pe.anchor
		].onException[
			warn("Failed to retrieve target of edge: " + edge.eClass.name + " " + edge.id)
		]
		if (srcAnchor != null && tgtAnchor != null)
			new AddConnectionContext(srcAnchor, tgtAnchor) => [
				newObject = edge
			]
	}
	
	def getPe(IdentifiableElement elm) {
		pes.get(elm)
	}
	
	def getAnchor(PictogramElement pe) {
		(pe as Shape)?.anchors?.get(0)
	}
	
	def getNodes() {
		model.modelElements.filter(Node).sortBy[index]
	}
	
	def getEdges() {
		model.modelElements.filter(Edge)
	}
	
	def int getIndex(IdentifiableElement element)
	
	def void setIndex(IdentifiableElement element, int i)
	
	def linkTo(PictogramElement pe, EObject bo) {
		featureProvider.link(pe,bo)
	}
	
	def getFeatureProvider() {
		fp ?: (fp = diagramTypeProvider.featureProvider)
	}
	
	def getDiagramTypeProvider() {
		dtp ?: (dtp = extensionManager.createDiagramTypeProvider(diagram, diagram.diagramTypeProviderId))
	}
	
	def cache(IdentifiableElement bo, PictogramElement pe) {
		pes.put(bo, pe)
	}
	
	def clearCache() {
		pes.clear
	}
	
	def update(LazyDiagram diagram) {
		val ctx = new UpdateContext(diagram)
		val feature = featureProvider.getUpdateFeature(ctx)
		if (feature.canUpdate(ctx)) 
			feature.update(ctx)
	}
	
	def warn(String msg) {
		System.err.println("[" + class.simpleName + "] " + msg)
	}
}
