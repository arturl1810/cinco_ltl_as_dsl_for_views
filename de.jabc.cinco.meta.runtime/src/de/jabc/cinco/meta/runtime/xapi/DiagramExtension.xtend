package de.jabc.cinco.meta.runtime.xapi

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.Shape

import static org.eclipse.emf.ecore.util.EcoreUtil.equals

/**
 * Diagram-specific extension methods.
 * 
 * @author Steve Bosselmann
 */
class DiagramExtension {
	
	def getDiagramTypeProvider(Diagram diagram) {
		extension val ext = new WorkbenchExtension
		getEditor(diagram)?.diagramTypeProvider
	}
	
	def getFeatureProvider(Diagram diagram) {
		getDiagramTypeProvider(diagram)?.featureProvider
	}
	
	def getContainerShapes(ContainerShape parent) {
		getContainerShapes(parent, false)
	}
	
	def getContainerShapes(ContainerShape parent, boolean includeParent) {
		val shapes = newArrayList
		if (includeParent)
			shapes.add(parent)
		collectChildShapes(parent, shapes, ContainerShape);
		return shapes;
	}
	
	def getPictogramElement(Diagram diagram, EObject businessObject) {
		diagram.pictogramLinks
			.filter[businessObjects.exists[equals(it, businessObject)]]
			.map[pictogramElement]
			.findFirst[it != null]
	}
	
	def getShapes(ContainerShape parent) {
		getShapes(parent, false)
	}
	
	def getShapes(ContainerShape parent, boolean includeParent) {
		val List<Shape> shapes = newArrayList
		if (includeParent)
			shapes.add(parent)
		collectChildShapes(parent, shapes)
	}
	
	def <T extends Shape> getShapes(ContainerShape parent, Class<T> clazz) {
		getShapes(parent, clazz, false)
	}
	
	def <T extends Shape> getShapes(ContainerShape parent, Class<T> clazz, boolean includeParent) {
		val List<T> shapes = newArrayList
		if (includeParent && clazz.isInstance(parent))
			shapes.add(clazz.cast(parent))
		collectChildShapes(parent, shapes, clazz)
	}
	
	def private <T extends Shape> List<T> collectChildShapes(ContainerShape container, List<T> shapes) {
		collectChildShapes(container, shapes, null)
	}
	
	def private <T extends Shape> List<T> collectChildShapes(ContainerShape container, List<T> shapes, Class<T> cls) {
		container.children
			.filter[child | cls == null || cls.isInstance(child)]
			.forEach[child |
				shapes.add(child as T)
				if (child instanceof ContainerShape)
					collectChildShapes(child, shapes, cls)
			]
			return shapes
	}
	
	def refresh(Diagram diagram) {
		extension val ext = new WorkbenchExtension
		async[| diagram.diagramBehavior?.refreshContent ]
	}
	
	def refreshDiagramEditor(Diagram diagram) {
		extension val ext = new WorkbenchExtension
		async[| diagram.diagramBehavior?.refresh ]
	}
}
