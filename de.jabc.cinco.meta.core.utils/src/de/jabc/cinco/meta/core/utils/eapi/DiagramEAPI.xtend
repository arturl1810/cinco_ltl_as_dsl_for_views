package de.jabc.cinco.meta.core.utils.eapi

import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.Diagram
import org.eclipse.graphiti.mm.pictograms.Shape

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workbench.getEditor
import static org.eclipse.emf.ecore.util.EcoreUtil.equals

import static extension de.jabc.cinco.meta.core.utils.eapi.EditorPartEAPI.*

class DiagramEAPI {
	
	private Diagram diagram;
	
	new(Diagram diagram) {
		this.diagram = diagram;
	}
	
	def static eapi(Diagram diagram) {
		new DiagramEAPI(diagram)
	}
	
	def getEditor() {
		getEditor(diagram)
	}
	
	def static getEditor(Diagram diagram) {
		getEditor(editor | editor.resource == diagram.eResource)
	}
	
	def getContainerShapes() {
		getContainerShapes(diagram)
	}
	
	def getContainerShapes(boolean includeParent) {
		getContainerShapes(diagram, includeParent)
	}
	
	def static getContainerShapes(ContainerShape parent) {
		getContainerShapes(parent, false)
	}
	
	def static getContainerShapes(ContainerShape parent, boolean includeParent) {
		val shapes = newArrayList
		if (includeParent)
			shapes.add(parent)
		collectChildShapes(parent, shapes, ContainerShape);
		return shapes;
	}
	
	def getPictogramElement(EObject businessObject) {
		getPictogramElement(diagram, businessObject);
	}
	
	def static getPictogramElement(Diagram diagram, EObject businessObject) {
		diagram.pictogramLinks
			.filter[businessObjects.exists[equals(it, businessObject)]]
			.map[pictogramElement]
			.findFirst[it != null]
	}
	
	def getShapes() {
		getShapes(diagram)
	}
	
	def getShapes(boolean includeParent) {
		getShapes(diagram, includeParent)
	}
	
	def static getShapes(ContainerShape parent) {
		getShapes(parent, false)
	}
	
	def static getShapes(ContainerShape parent, boolean includeParent) {
		val List<Shape> shapes = newArrayList
		if (includeParent)
			shapes.add(parent)
		collectChildShapes(parent, shapes)
	}
	
	def <T extends Shape> getShapes(Class<T> clazz) {
		getShapes(diagram, clazz)
	}
	
	def <T extends Shape> getShapes(Class<T> clazz, boolean includeParent) {
		getShapes(diagram, clazz, includeParent)
	}
	
	def static <T extends Shape> getShapes(ContainerShape parent, Class<T> clazz) {
		getShapes(parent, clazz, false)
	}
	
	def static <T extends Shape> getShapes(ContainerShape parent, Class<T> clazz, boolean includeParent) {
		val List<T> shapes = newArrayList
		if (includeParent && clazz.isInstance(parent))
			shapes.add(clazz.cast(parent))
		collectChildShapes(parent, shapes, clazz)
	}
	
	def private static <T extends Shape> List<T> collectChildShapes(ContainerShape container, List<T> shapes) {
		collectChildShapes(container, shapes, null)
	}
	
	def private static <T extends Shape> List<T> collectChildShapes(ContainerShape container, List<T> shapes, Class<T> cls) {
		container.children
			.filter[child | cls == null || cls.isInstance(child)]
			.forEach[child |
				shapes.add(child as T)
				if (child instanceof ContainerShape)
					collectChildShapes(child, shapes, cls)
			]
			return shapes
	}
}