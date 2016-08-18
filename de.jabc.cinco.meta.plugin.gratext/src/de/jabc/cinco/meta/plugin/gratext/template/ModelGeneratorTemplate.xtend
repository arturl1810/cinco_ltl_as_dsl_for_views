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

import static extension de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextGenerator.*

import de.jabc.cinco.meta.plugin.gratext.runtime.generator.GratextModelTransformer

import «graphmodel.package».«model.name.toLowerCase».«model.name»
import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Package
import «graphmodel.package».«model.name.toLowerCase».«model.nameFirstUpper»Factory

import «project.basePackage».*
import de.jabc.cinco.meta.core.ge.style.model.features.CincoAbstractAddFeature

import graphmodel.Edge
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Node

import java.util.HashMap
import java.util.List
import java.util.Map

import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EClass
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.AreaContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.Connection
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.services.GraphitiUi

class «model.name»ModelGenerator {
	
	final String FILE_SUFFIX = ""
	final String FILE_EXTENSION = "«graphmodel.fileExtension»"
	final String DTP_ID = "«graphmodel.package».«model.name»DiagramTypeProvider";

	«model.nameFirstUpper»Factory baseModelFct = «model.nameFirstUpper»Factory.eINSTANCE;
	«model.nameFirstUpper»Package baseModelPkg = «model.nameFirstUpper»Package.eINSTANCE;
	EClass baseModelCls = «model.nameFirstUpper»Package.eINSTANCE.get«model.name»
	
	GratextModelTransformer transformer

	Map<ModelElement, PictogramElement> pes = new HashMap
	Map<String, ModelElement> byId = new HashMap

	«model.name» model
	Diagram diagram
	IDiagramTypeProvider dtp
	IFeatureProvider fp
	IProject project
	IFile sourceFile
	String idSuffix
	
	def void doGenerate(IFile file, String folder) {
		idSuffix = "GRATEXT"
		init(file, folder)
		clearCache
		diagram.edit[
			diagram.name = new Path(file.name).removeFileExtension.lastSegment
			save(folder)
		]
	}
	
	def doGenerate(Resource resource) {
		resource.edit[
			init(resource, 0)
			clearCache
			nodes.forEach[add]
			edges.forEach[add]
			update
		]
	}
	
	def init(IFile file, String folder) {
		sourceFile = file
		project = file.project
		val path = file.getFullPath().toOSString()
		val uri = URI.createPlatformResourceURI(path, true)
		val resource = new ResourceSetImpl().getResource(uri, true)
		// model and diagram are generated while creating the resource
		resource.extractContent
	}
	
	def extractContent(Resource resource) {
		diagram = [|
			resource.contents.filter(Diagram).get(0)
		].printException
		model = [|
			resource.contents.filter(«model.name»).get(0)
		].printException
	}
	
	def init(Resource resource, int modelIndex) {
		model = [|
			resource.contents.get(modelIndex) as «model.name»
		].onException[
			model = resource.contents.filter(«model.name»).get(0)
		]
		
		transformer = new GratextModelTransformer(baseModelFct, baseModelPkg, baseModelCls)
		val baseModel = transformer.transform(model, idSuffix)
		
		resource.contents.remove(model)
		resource.contents.add(0, baseModel)
		model = baseModel
		
		diagram = createDiagram("«model.name»")
		resource.contents.add(0, diagram)
		
		dtp = GraphitiUi.extensionManager.createDiagramTypeProvider(diagram, DTP_ID)
		fp = dtp.featureProvider
		fp.link(diagram, model)
	}
	
	def add(ModelElement bo) {
		add(bo, diagram)
	}
	
	def add(ModelElement bo, ContainerShape container) {
		val pe = [|
			addIfPossible(getAddContext(bo, container))
		].printException
		if (pe != null) {
			cache(bo, pe)
			addChildren(bo, pe)
		} else warn("Pictogram null. Failed to add " + bo)
	}
	
	def addChildren(ModelElement bo, PictogramElement pe) {
		if (bo instanceof ModelElementContainer) 
		 	bo.modelElements.forEach[add(pe as ContainerShape)]
	}
	
	def add(Edge edge) {
		val pe = [|	
			edge.addContext?.addIfPossible
		].printException
		if (pe != null) {
			cache(edge, pe)
			postprocess(edge, pe)
		} else warn("Pictogram null. Failed to add " + edge)
	}
	
	def postprocess(Edge edge, PictogramElement pe) {
		val _edge = edge.counterpart as _Edge
		add(_edge.route, pe)
		add(_edge.decorations, pe)
	}
	
	def add(_Route route, PictogramElement pe) {
		route?.points?.forEach[ point, i |
			add(point, (pe as FreeFormConnection), i)
		]
	}
	
	def add(_Point p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.x, p.y, index)
		dtp.diagramBehavior.executeFeature(fp.getAddBendpointFeature(ctx), ctx);
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
		val ftr = fp.getAddFeature(ctx) as CincoAbstractAddFeature
		if (ftr != null) {
			ftr.hook = false
			if (ftr?.canAdd(ctx))
				fp.diagramTypeProvider.diagramBehavior.executeFeature(ftr, ctx) as PictogramElement
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
	
	def cache(ModelElement bo, PictogramElement pe) {
		byId.put(bo.id, bo)
		pes.put(bo, pe)
	}
	
	def clearCache() {
		byId.clear
		pes.clear
	}
	
	def update() {
		val ctx = new UpdateContext(diagram);
		val feature = fp.getUpdateFeature(ctx);
		if (feature.canUpdate(ctx)) 
			feature.update(ctx)
	}

	def save(String folder) {
		val filename = new Path(sourceFile.name).removeFileExtension.toString
		val res = createFile(createFolder(new Path(folder), project).fullPath, filename + FILE_SUFFIX, FILE_EXTENSION)
		res.addContent(diagram, model)
		res.save(null)
	}
	
	def warn(String msg) {
		System.err.println("[" + this.class.simpleName + "] " + msg)
	}
}
'''
}