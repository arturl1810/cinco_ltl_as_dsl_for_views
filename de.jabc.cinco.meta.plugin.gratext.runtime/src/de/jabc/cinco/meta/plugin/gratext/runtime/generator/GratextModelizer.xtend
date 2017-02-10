package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.LazyDiagram
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import graphmodel.IdentifiableElement
import graphmodel.internal.InternalEdge
import graphmodel.internal.InternalGraphModel
import graphmodel.internal.InternalModelElement
import graphmodel.internal.InternalModelElementContainer
import graphmodel.internal.InternalNode
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.core.runtime.IConfigurationElement
import org.eclipse.core.runtime.IExtension
import org.eclipse.core.runtime.IExtensionPoint
import org.eclipse.core.runtime.IExtensionRegistry
import org.eclipse.core.runtime.Platform
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.AreaContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.swt.SWTException

import static org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager

import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*
import org.eclipse.graphiti.features.context.impl.UpdateContext
import graphmodel.GraphModel
import graphmodel.ModelElement
import graphmodel.Node
import graphmodel.Edge
import graphmodel.ModelElementContainer
import org.eclipse.emf.ecore.impl.EObjectImpl

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
		model = transformer.transform(gratextModel)
		println("returned: " + model)
		println(" > eInternalContainer: " + (model as EObjectImpl).eInternalContainer())
		diagram.initialization = [|
			println("on diagram init: " + model)
			println(" > eInternalContainer: " + (model as EObjectImpl).eInternalContainer())
			link(diagram, model.internalElement)
			nodes.map[internalElement].forEach[add]
			edges.forEach[add]
			diagram.update
		]
		diagram.avoidInitialization = true
		println("before resource edit: " + model)
		println(" > eInternalContainer: " + (model as EObjectImpl).eInternalContainer())
		println(" > resource.size: " + resource.contents.size)
		val internal = (model as EObjectImpl).eInternalContainer()
		resource.edit[
			resource.contents.remove(gratextModel)
			resource.contents.add(0, model.internalElement)
			resource.contents.add(0, diagram)
		]
		println("after resource edit: " + model)
		println(" > resource.size: " + resource.contents.size)
		model.internalElement = internal as InternalGraphModel
		println("after re-adding of internal: " + model)
		println(" > eInternalContainer: " + (model as EObjectImpl).eInternalContainer())
		println(" > resource.size: " + resource.contents.size)
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
		println("Add " + bo)
		switch bo {
			InternalEdge: add(bo, bo.getAddContext)
			default: add(bo, bo.getAddContext(diagram))
		}
	}
	
	def add(InternalModelElement bo, AddContext ctx) {
		if (ctx != null) [| 
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
	
	def add(Pair<Integer,Integer> p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.key, p.value, index)
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
		val ga = [|	
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
		println("Add edge: " + edge)
		println("Add edge.source: " + edge.sourceElement)
		val srcAnchor = edge.sourceElement.internalElement.pe.anchor
		val tgtAnchor = edge.targetElement.internalElement.pe.anchor
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
		println("getCounterpart: " + elm)
		transformer.getCounterpart(elm)
	}
	
	def getEdges() {
		transformer.edges
	}
	
	def getNodes() {
		println("getNodes.model: " + model)
		println("getNodes.model.internalContainer: " + model.internalContainerElement)
		println("getNodes.model.internalContainer.modelElements: " + model.internalContainerElement.modelElements)
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
