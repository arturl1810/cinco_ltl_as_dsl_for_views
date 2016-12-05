package de.jabc.cinco.meta.core.utils.eapi;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.PictogramLink;
import org.eclipse.graphiti.mm.pictograms.Shape;

import de.jabc.cinco.meta.core.utils.WorkbenchUtil;

import static de.jabc.cinco.meta.core.utils.WorkbenchUtil.eapi;

public class DiagramEAPI {

	private Diagram diagram;
	
	public DiagramEAPI(Diagram diagram) {
		this.diagram = diagram;
	}
	
	public void getEditor() {
		WorkbenchUtil.getEditor(editor -> 
			eapi(editor).getResource() == diagram.eResource());
	}
	
	public List<ContainerShape> getContainerShapes() {
		return getContainerShapes(diagram);
	}
	
	public List<ContainerShape> getContainerShapes(boolean includeParent) {
		return getContainerShapes(diagram, includeParent);
	}
	
	public List<ContainerShape> getContainerShapes(ContainerShape parent) {
		return getContainerShapes(parent, false);
	}
	
	public List<ContainerShape> getContainerShapes(ContainerShape parent, boolean includeParent) {
		ArrayList<ContainerShape> shapes = new ArrayList<ContainerShape>();
		if (includeParent)
			shapes.add(parent);
		collectChildShapes(parent, shapes, ContainerShape.class);
		return shapes;
	}
	
	public PictogramElement getPictogramElement(EObject businessObject) {
		PictogramElement result = null;
		for (PictogramLink link : diagram.getPictogramLinks()) {
			for (EObject obj : link.getBusinessObjects()) {
				if (EcoreUtil.equals(businessObject, obj)) {
					PictogramElement pe = link.getPictogramElement();
					if (pe != null) {
						result = pe;
					}
					break;
				}
			}
			if (result != null) {
				break;
			}
		}
		return result;
	}
	
	public List<Shape> getShapes() {
		return getShapes(diagram);
	}
	
	public List<Shape> getShapes(boolean includeParent) {
		return getShapes(diagram, includeParent);
	}
	
	public List<Shape> getShapes(ContainerShape parent) {
		return getShapes(parent, false);
	}
	
	public List<Shape> getShapes(ContainerShape parent, boolean includeParent) {
		ArrayList<Shape> shapes = new ArrayList<Shape>();
		if (includeParent)
			shapes.add(parent);
		collectChildShapes(parent, shapes);
		return shapes;
	}
	
	public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz) {
		return getShapes(clazz, diagram);
	}
	
	public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz, ContainerShape parent) {
		return getShapes(clazz, parent, false);
	}
	
	public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz, ContainerShape parent, boolean includeParent) {
		ArrayList<T> shapes = new ArrayList<T>();
		if (includeParent && clazz.isInstance(parent))
			shapes.add(clazz.cast(parent));
		collectChildShapes(parent, shapes, clazz);
		return shapes;
	}
	
	private static <T extends Shape> void collectChildShapes(ContainerShape container, ArrayList<T> shapes) {
		collectChildShapes(container, shapes, null);
	}
	
	@SuppressWarnings("unchecked")
	private static <T extends Shape> void collectChildShapes(ContainerShape container, ArrayList<T> shapes, Class<T> cls) {
		container.getChildren().stream()
			.filter((cls != null) ? cls::isInstance : x -> true)
			.forEach(child -> {
				shapes.add((T) child);
				if (child instanceof ContainerShape)
					collectChildShapes((ContainerShape) child, shapes, cls);
			});
	}
}