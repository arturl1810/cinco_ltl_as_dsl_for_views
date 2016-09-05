package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor

class ModelGeneratorTemplate extends AbstractGratextTemplate {
	
def generator() {
	fileFromTemplate(GratextGeneratorTemplate)
}

def nameFirstUpper(GraphModelDescriptor model) {
	model.name.toLowerCase.toFirstUpper
}
	
override template()
'''	
package «project.basePackage».generator

import static org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager
import static extension de.jabc.cinco.meta.core.utils.WorkspaceUtil.eapi
import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*

import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractAddFeature
import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelTransformer

import «graphmodel.package».«model.name.toLowerCase».«model.name»
import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package
import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Factory

import «project.basePackage».*

import graphmodel.Edge
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Node

import java.util.HashMap
import java.util.List
import java.util.Map

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.AreaContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.swt.SWTException

class «model.name»ModelGenerator {
	
	final String DTP_ID = "«graphmodel.package».«model.name»DiagramTypeProvider";

	«model.nameFirstUpper»Factory baseModelFct = «model.nameFirstUpper»Factory.eINSTANCE;
	«model.nameFirstUpper»Package baseModelPkg = «model.nameFirstUpper»Package.eINSTANCE;
	
	GratextModelTransformer transformer

	Map<ModelElement, PictogramElement> pes = new HashMap
	Map<String, ModelElement> byId = new HashMap

	«model.name» model
	Diagram diagram
	IDiagramTypeProvider dtp
	IFeatureProvider fp
	
	def doGenerate(Resource resource) {
		val gratextModel = resource.eapi.getGraphModel(«model.name»)
		model = gratextModel.transform
		diagram = new «model.name»Diagram([|
			link(diagram, model)
			nodes.forEach[add]
			edges.forEach[add]
		])
		resource.edit[
			resource.contents.remove(gratextModel)
			resource.contents.add(0, model)
			resource.contents.add(0, diagram)
		]
	}
	
	def transform(«model.name» model) {
		transformer = new GratextModelTransformer(
			baseModelFct, baseModelPkg, baseModelPkg.get«model.name»
		)
		transformer.transform(model)
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
				val _edge = bo.counterpart as _Edge
				add(_edge.route, pe)
				add(_edge.decorations, pe)
			}
			ModelElementContainer :
				bo.modelElements.forEach[
					add(getAddContext(pe as ContainerShape))
				]
		}
	}
	
	def add(_Route route, PictogramElement pe) {
		route?.points?.forEach[ point, i |
			add(point, (pe as FreeFormConnection), i)
		]
	}
	
	def add(_Point p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.x, p.y, index)
		diagramTypeProvider.diagramBehavior.executeFeature(
			featureProvider.getAddBendpointFeature(ctx), ctx);
	}
	
	def add(List<_Decoration> decs, PictogramElement pe) {
		if (decs != null)
			for (var i=0; i < decs.size; i++)
				update(decs.get(i), (pe as Connection), i)
	}
	
	def update(_Decoration dec, Connection con, int index) {
		val ga = [|	
			con.connectionDecorators?.get(index)?.graphicsAlgorithm
		].printException
		if (ga != null) {
			ga.x = dec?.location?.x
			ga.y = dec?.location?.y
		} else warn("Failed to retrieve decorator shape (index=" + index + ") of " + con)
	}
	
	def addIfPossible(AddContext ctx) {
		val ftr = featureProvider.getAddFeature(ctx) as CincoAbstractAddFeature
		if (ftr != null) {
			ftr.hook = false
			if (ftr?.canAdd(ctx))
				featureProvider.diagramTypeProvider.diagramBehavior
					.executeFeature(ftr, ctx) as PictogramElement
		} else warn("Failed to retrieve AddFeature for " + ctx)
	}
	
	def getAddContext(ModelElement bo, ContainerShape target) {
		val place = getPlacement(bo)
		new AddContext(new AreaContext, bo) => [
			targetContainer = target
			x = place.x
			y = place.y
			width = place.width
			height = place.height
		]
	}
	
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
		model.modelElements.filter(Node)
	}

	def getPlacement() {
		getPlacement(null as _Placement)
	} 
	
	def getPlacement(ModelElement element) {
		val cp = element.counterpart
		if (cp != null && cp instanceof _Placed)
			getPlacement((cp as _Placed).placement)
		else
			getPlacement
	}
	
	def getPlacement(_Placement placement) {
		val plm = «project.targetName»Factory.eINSTANCE.create_Placement
		if (placement != null) {
			if (placement.x != 0) plm.x = placement.x
			if (placement.y != 0) plm.y = placement.y
			if (placement.width >= 0) plm.width = placement.width
			if (placement.height >= 0) plm.height = placement.height
		}
		return plm;
	}
	
	def link(PictogramElement pe, EObject bo) {
		featureProvider.link(pe,bo)
	}
	
	def getFeatureProvider() {
		fp ?: (fp = diagramTypeProvider.featureProvider)
	}
	
	def getDiagramTypeProvider() {
		dtp ?: (dtp = extensionManager.createDiagramTypeProvider(diagram, DTP_ID))
	}
	
	def cache(ModelElement bo, PictogramElement pe) {
		byId.put(bo.id, bo)
		pes.put(bo, pe)
	}
	
	def clearCache() {
		byId.clear
		pes.clear
	}
	
	def warn(String msg) {
		System.err.println("[" + this.class.simpleName + "] " + msg)
	}
}
'''
}