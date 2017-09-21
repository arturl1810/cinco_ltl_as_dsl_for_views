package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.LazyDiagram
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.GraphModel
import graphmodel.IdentifiableElement
import graphmodel.Node
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import graphmodel.internal._Point
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.impl.EObjectImpl
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

import static org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager

import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*

abstract class GratextModelizer {
	
	extension val ResourceExtension = new ResourceExtension
	
	NonEmptyRegistry<IdentifiableElement,List<EObject>>
		nodesInitialOrder = new NonEmptyRegistry[newArrayList]
	
	GratextModelTransformer transformer

	Map<IdentifiableElement, PictogramElement> pes = new HashMap
	Map<String, IdentifiableElement> byId = new HashMap

	protected GraphModel model
	LazyDiagram diagram
	IDiagramTypeProvider dtp
	IFeatureProvider fp
	
	new(EFactory modelFct, EPackage modelPkg, EClass modelCls) {
		transformer = new GratextModelTransformer(modelFct, modelPkg, modelCls)
	}
	
	def run(Resource resource) {
		val gratextModel = resource.getContent(InternalGraphModel)
		nodesInitialOrder.clear
		gratextModel.cacheInitialOrder
		diagram = createDiagram
		model = transformer.transform(gratextModel).element
		diagram.initialization = [|
			link(diagram, model)
			link(diagram, model.internalElement)
			nodes.map[internalElement].forEach[add]
			edges.forEach[add]
			diagram.update
		]
		diagram.avoidInitialization = true
		val internal = (model as EObjectImpl).eInternalContainer()
		resource.edit[
			resource.contents.remove(gratextModel)
			resource.contents.add(0, model.internalElement)
			resource.contents.add(0, diagram)
		]
		model.internalElement = internal as InternalGraphModel
		diagram.avoidInitialization = false
	}
	
	def LazyDiagram createDiagram()
	
	def void cacheInitialOrder(InternalModelElementContainer container) {
		val children = nodesInitialOrder.get(container)
		for (InternalModelElement node : container.modelElements) {
			if (node.index < 0) {
				node.index = children.size
			}
			children.add(node)
			if (node instanceof InternalModelElementContainer) {
				cacheInitialOrder(node)
			}
		}
	}
	
	def getInitialIndex(InternalModelElement node) {
		nodesInitialOrder.get(node.container.counterpart).indexOf(node.counterpart)
	}
	
	def add(InternalModelElement bo) {
		switch bo {
			InternalEdge: add(bo, bo.getAddContext)
			default: add(bo, bo.getAddContext(diagram))
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
		(edge.counterpart as InternalEdge).bendpoints?.forEach[ point, i |
			add(point, (pe as FreeFormConnection), i)
		]
	}
	
	def add(_Point p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.x, p.y, index)
		diagramTypeProvider.diagramBehavior.executeFeature(
			featureProvider.getAddBendpointFeature(ctx), ctx);
	}
	
	def addDecorators(InternalEdge edge, Connection con) {
		val size = con.connectionDecorators?.size
		for (var i = 0; i < size; i++)
			con.updateDecorator(i, (edge.counterpart as InternalEdge).getDecoratorLocation(i))
	}
	
	def Pair<Integer,Integer> getDecoratorLocation(InternalEdge edge, int index)
	
	def updateDecorator(Connection con, int index, Pair<Integer,Integer> location) {
		val ga = [	
			con.connectionDecorators?.get(index)?.graphicsAlgorithm
		].printException
		if (ga != null && location != null) {
			ga.x = location?.key
			ga.y = location?.value
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
			x = (bo.counterpart as InternalModelElement).x
			y = (bo.counterpart as InternalModelElement).y
			width = (bo.counterpart as InternalModelElement).width
			height = (bo.counterpart as InternalModelElement).height
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
	
	def getCounterpart(EObject elm) {
		transformer.getCounterpart(elm)
	}
	
	def getEdges() {
		transformer.edges
	}
	
	def getNodes() {
		model.modelElements.filter(Node).sortBy[(counterpart as InternalNode).index]
	}
	
	def int getIndex(IdentifiableElement element)
	
	def void setIndex(IdentifiableElement element, int i)
	
	def link(PictogramElement pe, EObject bo) {
		featureProvider.link(pe,bo)
	}
	
	def getFeatureProvider() {
		fp ?: (fp = diagramTypeProvider.featureProvider)
	}
	
	def getDiagramTypeProvider() {
		dtp ?: (dtp = extensionManager.createDiagramTypeProvider(diagram, diagram.diagramTypeProviderId))
	}
	
	def cache(IdentifiableElement bo, PictogramElement pe) {
		byId.put(bo.id, bo)
		pes.put(bo, pe)
	}
	
	def clearCache() {
		byId.clear
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
