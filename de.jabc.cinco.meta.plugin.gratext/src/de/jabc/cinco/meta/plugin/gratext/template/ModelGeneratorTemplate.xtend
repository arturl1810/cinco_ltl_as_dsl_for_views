package de.jabc.cinco.meta.plugin.gratext.template

class ModelGeneratorTemplate extends AbstractGratextTemplate {
	
override template()
'''	
package «project.basePackage».generator

import «graphmodel.package».«model.name.toLowerCase».«model.name»

import «project.basePackage».*

import graphmodel.GraphModel
import graphmodel.ModelElement
import graphmodel.ModelElementContainer
import graphmodel.Edge
import graphmodel.Node

import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map

import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.graphiti.dt.IDiagramTypeProvider
import org.eclipse.graphiti.features.IFeatureProvider
import org.eclipse.graphiti.features.context.impl.AddConnectionContext
import org.eclipse.graphiti.features.context.impl.AddContext
import org.eclipse.graphiti.features.context.impl.AreaContext
import org.eclipse.graphiti.features.context.impl.UpdateContext
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.services.Graphiti
import org.eclipse.graphiti.ui.services.GraphitiUi
import org.eclipse.swt.widgets.Display
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection

class «project.targetName»Generator implements IGenerator {
	
	final String FILE_EXTENSION = "«graphmodel.fileExtension»"
	final String DTP_ID = "«graphmodel.package».«model.name»DiagramTypeProvider";

	Map<ModelElement, PictogramElement> pes = new HashMap
	List<_EdgeSource> edgeSources = new ArrayList
	Map<String, ModelElement> byId = new HashMap

	GraphModel model
	Diagram diagram
	IDiagramTypeProvider dtp;
	IFeatureProvider fp;
	

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		init(resource)
		clearCache
		
		Display.getDefault.asyncExec[
			
			model.modelElements.forEach[add]
			
			edgeSources.forEach[source | 
				new ArrayList(source.outgoingEdges).forEach[edge | 
					add(edge, source, (edge as Edge).targetElement) ] ]
			
			update
			save
		]
	}
	
	def init(Resource resource) {
		model = resource.contents.get(0) as «model.name»
		val filename = "«model.name»_" + model.id
		diagram = newDiagram(filename)
		resource.getContents().add(diagram)
		dtp = GraphitiUi.getExtensionManager().createDiagramTypeProvider(diagram, DTP_ID);
		fp = dtp.featureProvider
		fp.link(diagram, model)
	}
	
	def process(ModelElement bo) {
		
	}
	
	def add(ModelElement bo) {
		add(bo, diagram)
	}
	
	def add(ModelElement bo, ContainerShape container) {
		try {
			process(bo)
		} catch(Exception e) {
			e.printStackTrace
		}
		try {
			System.out.println(" > add pictogram for " + bo)
			val pe = fp.addIfPossible(getAddContext(bo, container))
			System.out.println("   => bo.id: " + bo.id)
			System.out.println("   => pe: " + pe)
			cache(bo, pe)
			addChildren(bo, pe)
		} catch(Exception e) {
			e.printStackTrace
		}
	}
	
	def addChildren(ModelElement bo, PictogramElement pe) {
		if (bo instanceof ModelElementContainer) 
		 	bo.modelElements.forEach[child | add(child, pe as ContainerShape)]
	}
	
	def add(_Edge edge, _EdgeSource source, Node target) {
		try {
			System.out.println("Generator.add " + edge)
			System.out.println("  > source " + source)
			System.out.println("  > target " + target)
			
			(edge as graphmodel.Edge).sourceElement = source as graphmodel.Node
			(edge as graphmodel.Edge).targetElement = target as graphmodel.Node
			
			val pe = fp.addIfPossible(getAddContext(edge, (source as ModelElement), (target as ModelElement)))
			cache((edge as ModelElement), pe)
			
			add(edge.route, pe)
			
		} catch(Exception e) {
			e.printStackTrace
		}
	}
	
	def add(_Route route, PictogramElement pe) {
		if (route != null && route.points != null)
			for (var i=0; i < route.points.size; i++)
				add(route.points.get(i), (pe as FreeFormConnection), i)
	}
	
	def add(_Point p, FreeFormConnection connection, int index) {
		val ctx = new AddBendpointContext(connection, p.x, p.y, index)
		dtp.diagramBehavior.executeFeature(fp.getAddBendpointFeature(ctx), ctx);
	}
	
	def getAddContext(ModelElement bo, ContainerShape target) {
		val place = getPlacement(bo)
		val ctx = new AddContext(new AreaContext, bo)
			ctx.targetContainer = target
			ctx.x = place.x
			ctx.y = place.y
			ctx.width = place.width
			ctx.height = place.height
		return ctx
	}
	
	def getAddContext(_Edge edge, ModelElement source, ModelElement target) {
		val ctx = new AddConnectionContext(getAnchor(pes.get(source)), getAnchor(pes.get(target)))
		ctx.setNewObject(edge)
		return ctx
	}
	
	def getAnchor(PictogramElement pe) {
		return (pe as Shape).anchors.get(0)
	}
	
	def cache(ModelElement bo, PictogramElement pe) {
		byId.put(bo.id, bo)
		pes.put(bo, pe)
		if (bo instanceof _EdgeSource)
			edgeSources.add(bo)
	}
	
	def clearCache() {
		byId.clear
		pes.clear
		edgeSources.clear
	}
	
	def update() {
		val ctx = new UpdateContext(diagram);
		val feature = fp.getUpdateFeature(ctx);
		if (feature.canUpdate(ctx)) 
			feature.update(ctx);
	}

	def save() {
		val res = createResource(new Path("Project/src-gen/"), "«model.name»_" + model.id, FILE_EXTENSION)
		addToResource(res, diagram, model)
		res.save(null)
	}

	def createResource(IPath path, String fileName, String fileExtension) {
		val filePath = path.append(fileName).addFileExtension(fileExtension)
		val uri = URI.createPlatformResourceURI(filePath.toOSString(), true)
		return new ResourceSetImpl().createResource(uri)
	}

	def addToResource(Resource res, EObject... objs) {
		objs.forEach[obj | res.contents.add(obj)]
	}

	def newDiagram(String filename) {
		return Graphiti.getPeCreateService().createDiagram("«model.name»", filename, true)
	}

	def newFeatureProvider(Diagram diagram) {
		return GraphitiUi.getExtensionManager().createFeatureProvider(diagram)
	}

	def getPlacement() {
		getPlacement(null as _Placement)
	} 
	
	def getPlacement(ModelElement element) {
		if (element instanceof _Placed)
			getPlacement((element as _Placed).placement)
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
}
'''
}