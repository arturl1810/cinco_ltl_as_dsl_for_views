package de.jabc.cinco.meta.plugin.gratext.runtime.generator

import static org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager
import static extension de.jabc.cinco.meta.core.utils.eapi.ResourceEAPI.getGraphModel
import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*

import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry
import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelTransformer
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.LazyDiagram

import graphmodel.Edge
import graphmodel.GraphModel
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Node

import java.util.HashMap
import java.util.List
import java.util.Map

import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EFactory
import org.eclipse.emf.ecore.EPackage
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
import de.jabc.cinco.meta.core.ge.style.generator.runtime.features.CincoAbstractAddFeature

abstract class GratextModelizer {
	
	NonEmptyRegistry<ModelElementContainer,List<EObject>>
		nodesInitialOrder = new NonEmptyRegistry[newArrayList]
	
	GratextModelTransformer transformer

	Map<ModelElement, PictogramElement> pes = new HashMap
	Map<String, ModelElement> byId = new HashMap

	GraphModel model
	LazyDiagram diagram
	IDiagramTypeProvider dtp
	IFeatureProvider fp
	
	new(EFactory modelFct, EPackage modelPkg, EClass modelCls) {
		transformer = new GratextModelTransformer(modelFct, modelPkg, modelCls)
	}
	
	def run(Resource resource) {
		val gratextModel = resource.graphModel
		nodesInitialOrder.clear
		gratextModel.cacheInitialOrder
		diagram = createDiagram
		model = transformer.transform(gratextModel)
		diagram.initialization = [|
			link(diagram, model)
			nodes.forEach[add]
			edges.forEach[add]
			diagram.update
		]
		diagram.avoidInitialization = true
		resource.edit[
			resource.contents.remove(gratextModel)
			resource.contents.add(0, model)
			resource.contents.add(0, diagram)
		]
		diagram.avoidInitialization = false
	}
	
	def LazyDiagram createDiagram()
	
	def void cacheInitialOrder(ModelElementContainer container) {
		val children = nodesInitialOrder.get(container)
		for (Node node : container.allNodes) {
			if (node.index < 0) {
				node.index = children.size
			}
			children.add(node)
			if (node instanceof ModelElementContainer) {
				cacheInitialOrder(node)
			}
		}
	}
	
	def getInitialIndex(Node node) {
		nodesInitialOrder.get(node.container.counterpart).indexOf(node.counterpart)
	}
	
	def add(ModelElement bo) {
		switch bo {
			Edge: add(bo, bo.addContext)
			default: add(bo, bo.getAddContext(diagram))
		}
	}
	
	def add(ModelElement bo, AddContext ctx) {
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
	
	def postprocess(ModelElement bo) {
		val pe = bo.pe
		if (pe == null) {
			warn("Pictogram null. Failed to add " + bo)
		} else switch bo {
			Edge: {
				addBendpoints(bo, pe)
				addDecorators(bo, pe as Connection)
			}
			ModelElementContainer :
				bo.modelElements.forEach[
					add(getAddContext(pe as ContainerShape))
				]
		}
	}
	
	def List<Pair<Integer,Integer>> getBendpoints(Edge edge)
	
	def addBendpoints(Edge edge, PictogramElement pe) {
		(edge.counterpart as Edge).bendpoints?.forEach[ point, i |
			add(point, (pe as FreeFormConnection), i)
		]
	}
	
	def add(Pair<Integer,Integer> p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.key, p.value, index)
		diagramTypeProvider.diagramBehavior.executeFeature(
			featureProvider.getAddBendpointFeature(ctx), ctx);
	}
	
	def addDecorators(Edge edge, Connection con) {
		val size = con.connectionDecorators?.size
		for (var i = 0; i < size; i++)
			con.updateDecorator(i, (edge.counterpart as Edge).getDecoratorLocation(i))
	}
	
	def Pair<Integer,Integer> getDecoratorLocation(Edge edge, int index)
	
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
	
	def getAddContext(ModelElement bo, ContainerShape target) {
		new AddContext(new AreaContext, bo) => [
			targetContainer = target
			x = (bo.counterpart as ModelElement).x
			y = (bo.counterpart as ModelElement).y
			width = (bo.counterpart as ModelElement).width
			height = (bo.counterpart as ModelElement).height
		]
	}
	
	def int getX(ModelElement element)
	
	def int getY(ModelElement element)
	
	def int getWidth(ModelElement element)
	
	def int getHeight(ModelElement element)
	
	def getAddContext(Edge edge) {
		val srcAnchor = edge.sourceElement.pe.anchor
		val tgtAnchor = edge.targetElement.pe.anchor
		if (srcAnchor != null && tgtAnchor != null)
			new AddConnectionContext(srcAnchor, tgtAnchor) => [
				newObject = edge
			]
	}
	
	def getPe(ModelElement elm) {
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
		model.modelElements.filter(Node).sortBy[(counterpart as Node).index]
	}
	
	def int getIndex(ModelElement element)
	
	def void setIndex(ModelElement element, int i)
	
	def link(PictogramElement pe, EObject bo) {
		featureProvider.link(pe,bo)
	}
	
	def getFeatureProvider() {
		fp ?: (fp = diagramTypeProvider.featureProvider)
	}
	
	def getDiagramTypeProvider() {
		dtp ?: (dtp = extensionManager.createDiagramTypeProvider(diagram, diagram.diagramTypeProviderId))
	}
	
	def cache(ModelElement bo, PictogramElement pe) {
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
