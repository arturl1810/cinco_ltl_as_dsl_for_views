package de.jabc.cinco.meta.core.ui.utils;

import graphmodel.Container;
import graphmodel.Edge;
import graphmodel.ModelElement;
import graphmodel.Node;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.graphiti.datatypes.ILocation;
import org.eclipse.graphiti.mm.algorithms.AbstractText;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.pictograms.Anchor;
import org.eclipse.graphiti.mm.pictograms.AnchorContainer;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.PictogramLink;
import org.eclipse.graphiti.mm.pictograms.PictogramsFactory;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.ui.services.GraphitiUi;
import org.eclipse.swt.graphics.Point;

public class CincoCopyUtils {
	private static HashMap<EObject, Anchor> copiedAnchors = new HashMap<>();
	private static HashMap<EObject, EObject> copiedBos = new HashMap<>();
	
	private static Integer xMin = null;
	private static Integer yMin = null;
	private static Integer xMinAbs = null;
	private static Integer yMinAbs = null;

	public static PictogramElement flatCopy(PictogramElement pElement) {
		EObject bo = pElement.getLink().getBusinessObjects().get(0);
		
		if (bo instanceof Container) {
			ContainerShape cs = (ContainerShape) copyContainerShape((ContainerShape) pElement);
			List<PictogramElement> remove = new ArrayList<>();
			for (Shape s : cs.getChildren()) {
				if (s.getGraphicsAlgorithm() instanceof AbstractText)
					continue;
				remove.add(s);
			}
			cs.getChildren().removeAll(remove);
			Container c = (Container) cs.getLink().getBusinessObjects().get(0);
			// TODO: This won't work with the Internal Elements in background
			c.getModelElements().clear();
			return cs;
		}
		
		if (bo instanceof Node) {
			Shape s = copyNodeShape((Shape) pElement);
			return s;
		}
		
		else if (bo instanceof Edge)
			return copyConnection((Connection) pElement);
			
		return null;
	}

	/**
	 * This method copies the subgraph given in @param subGraph and triggers the computation of 
	 * the upper left corner of the subgraph relative to a container and to the diagram 
	 * @param subGraph List containing nodes, containers and edges which should be copied
	 * @param diagram The Graphiti diagram
	 * @return Set containing the copied elements
	 */
	public static Set<PictogramElement> sourceCopy(List<PictogramElement> subGraph, Diagram diagram) {
		 return copy(subGraph, diagram, true);
	}
	
	/**
	 * This method copies the subgraph given in @param subGraph and does not trigger the computation of 
	 * the upper left corner of the subgraph relative to a container and to the diagram.
	 * Use this method to copy the subgraph in the paste method. 
	 * @param subGraph List containing nodes, containers and edges which should be copied
	 * @param diagram The Graphiti diagram
	 * @return Set containing the copied elements
	 */
	public static Set<PictogramElement> targetCopy(List<PictogramElement> subGraph, Diagram diagram) {
		 return copy(subGraph, diagram, false);
	}

	public static Set<PictogramElement> copy(List<PictogramElement> subGraph, Diagram diagram, boolean computeUpperLeft) {
		Set<PictogramElement> copyList = new HashSet<>();
		
		List<Shape> shapes = new ArrayList<>();
		Set<Connection> connections = new HashSet<>();
		
		copiedAnchors.clear();
		copiedBos.clear();
		
		if (computeUpperLeft)
			computeUpperLeft(subGraph);

		for (PictogramElement pe : subGraph) {
			if (pe instanceof Connection) {
				connections.add((Connection) pe);
				
			}
			else shapes.add((Shape) pe);
			
			for (Connection c : diagram.getConnections()) {
				if (isCopied(c, subGraph))
					connections.add(c);
			}
		}
		
		for (Shape s : shapes) {
			EObject bo = (EObject) s.getLink().getBusinessObjects().get(0);
			Shape copy = null;
			if (bo instanceof Node) {
				if (bo instanceof Container) {
					copy = copyContainerShape((ContainerShape) s);
				} else 
					copy = copyNodeShape(s);
			}
			
			copyList.add(copy);
		}
		
		for (Connection c : connections) {
			Connection copy = copyConnection(c);
			copyList.add(copy);
		}
		
		return copyList;
	}
	
	
	
	private static Shape copyContainerShape(ContainerShape cs) {
		HashMap<PictogramElement, Shape> replaceMap = new HashMap<PictogramElement, Shape>();
		ContainerShape shapeCopy = EcoreUtil.copy(cs);
		EObject boOrig = cs.getLink().getBusinessObjects().get(0);
		EObject boCopy = EcoreUtil.copy(boOrig);
		EcoreUtil.setID(boCopy,EcoreUtil.generateUUID());
		((Container) boCopy).getModelElements().clear();
		
		shapeCopy.getLink().setPictogramElement(shapeCopy);
		shapeCopy.getLink().getBusinessObjects().clear();
		shapeCopy.getLink().getBusinessObjects().add(boCopy);
		
		for (Shape child : shapeCopy.getChildren()) {
			EObject childBo = child.getLink().getBusinessObjects().get(0);
			if (childBo.equals(boOrig))
				linkShapeTo(child, boOrig, boCopy);
			else {
				Shape copiedChildShape = null;
				if (childBo instanceof Container) {
					 copiedChildShape = copyContainerShape((ContainerShape) child);
				} else copiedChildShape = copyNodeShape(child);
				replaceMap.put(child, copiedChildShape);
			}
		}
		
		shapeCopy.getChildren().removeAll(replaceMap.keySet());
		shapeCopy.getChildren().addAll(replaceMap.values());
		for (PictogramElement pe : replaceMap.values()) {
			((Container) boCopy).getModelElements().add((ModelElement) pe.getLink().getBusinessObjects().get(0));
		}
		
		copiedAnchors.put(boOrig, shapeCopy.getAnchors().get(0));
		copiedBos.put(boOrig, boCopy);
		
		return shapeCopy;
	}
	
	private static Shape copyNodeShape(Shape s) {
		Shape shapeCopy = EcoreUtil.copy(s);
		EObject boOrig = s.getLink().getBusinessObjects().get(0);
		EObject boCopy = EcoreUtil.copy(boOrig);
		EcoreUtil.setID(boCopy,EcoreUtil.generateUUID());
		
		shapeCopy.getLink().setPictogramElement(shapeCopy);
		shapeCopy.getLink().getBusinessObjects().clear();
		shapeCopy.getLink().getBusinessObjects().add(boCopy);
		
		if (shapeCopy instanceof ContainerShape) {
			for (Shape child : ((ContainerShape) shapeCopy).getChildren()) {
				linkShapeTo(child, boOrig, boCopy);
			}
		}
		
		copiedAnchors.put(boOrig, shapeCopy.getAnchors().get(0));
		copiedBos.put(boOrig, boCopy);
		
		return shapeCopy;
	}

	private static void linkShapeTo(Shape s, EObject boOrig, EObject boCopy) {
		if (s.getLink() != null && boOrig.equals(s.getLink().getBusinessObjects().get(0))) {
			s.getLink().getBusinessObjects().clear();
			s.getLink().getBusinessObjects().add(boCopy);
			if (s instanceof ContainerShape) {
				for (Shape child : ((ContainerShape) s).getChildren()) {
					linkShapeTo(child, boOrig, boCopy);
				}
			}
		}
	}
	
	/************************************************************** Connection copy methods **************************************************************/
	private static Connection copyConnection(Connection connection) {
		Connection copy = EcoreUtil.copy(connection);
		EcoreUtil.setID(copy,EcoreUtil.generateUUID());
		
		copy.setStart(copiedAnchors.get(connection.getStart().getParent().getLink().getBusinessObjects().get(0)));
		copy.setEnd(copiedAnchors.get(connection.getEnd().getParent().getLink().getBusinessObjects().get(0)));
		
		/** TODO: Copy bo and pictogramLink **/
		if (connection.getLink() != null)
			copyBOForConnection(copy, connection.getLink().getBusinessObjects().get(0), 
					connection.getStart().getParent().getLink().getBusinessObjects().get(0),
					connection.getEnd().getParent().getLink().getBusinessObjects().get(0));
		
		return copy;
	}
	
	private static void copyBOForConnection(PictogramElement copiedPE, EObject originBO, 
			EObject source, EObject target) {
		
		PictogramLink pl = PictogramsFactory.eINSTANCE.createPictogramLink();
		pl.setPictogramElement(copiedPE);
		EObject copy = EcoreUtil.copy(originBO);
		EcoreUtil.setID(copy,EcoreUtil.generateUUID());
		if (originBO instanceof Edge) {
			((Edge) copy).setSourceElement((Node) copiedBos.get(source));
			((Edge) copy).setTargetElement((Node) copiedBos.get(target));
		}
		pl.getBusinessObjects().add(copy);
		copiedPE.setLink(pl);
	}
	
	private static boolean isCopied(Connection c, List<PictogramElement> subGraph) {
		AnchorContainer source = c.getStart().getParent();
		AnchorContainer target = c.getEnd().getParent();
		boolean srcContained = false, trgContained = false;
		for (PictogramElement pe : subGraph) {
			if (EcoreUtil.isAncestor(pe, source))
				srcContained = true;
			if (EcoreUtil.isAncestor(pe, target))
				trgContained = true;
			if (srcContained && trgContained)
				break;
		}
		
		return (srcContained && trgContained);
	}

	public static Point getUpperLeft() {
		return new Point(xMin, yMin);
	}
	
	public static Point getAbsoluteUpperLeft() {
		return new Point(xMinAbs, yMinAbs);
	}
	
	private static void computeUpperLeft(List<PictogramElement> subGraph) {
		xMin = null;
		yMin = null;
		
		xMinAbs = null;
		yMinAbs = null;
		
		for (Object bo : subGraph) {
			if (bo instanceof Shape) {
				GraphicsAlgorithm ga = ((PictogramElement) bo).getGraphicsAlgorithm();

				if (xMin == null) xMin = ga.getX();
				if (yMin == null) yMin = ga.getY();
				
				ILocation absoluteLocation = GraphitiUi.getUiLayoutService().getLocationRelativeToDiagram((Shape) bo);
				if (xMinAbs == null) xMinAbs = absoluteLocation.getX();
				if (yMinAbs == null) yMinAbs = absoluteLocation.getY();
				
				xMin = Math.min(xMin, ga.getX());
				yMin = Math.min(yMin, ga.getY());
				
				xMinAbs = Math.min(xMinAbs, absoluteLocation.getX());
				yMinAbs = Math.min(yMinAbs, absoluteLocation.getY());	
			}
		}
		
		if (xMin == null) xMin = 0;
		if (yMin == null) yMin = 0;

		if (xMinAbs == null) xMinAbs = 0;
		if (yMinAbs == null) yMinAbs = 0;
		
	}

	private static void mapAnchors(ContainerShape cs, ContainerShape copy) {
		/** Map the anchors in a container shape **/
		for (Shape originChild : cs.getChildren()) {
			for (Shape copyChild : copy.getChildren()) {
				Object oOrigin = originChild.getLink().getBusinessObjects().get(0);
				Object oCopy = copyChild.getLink().getBusinessObjects().get(0);
				if (oOrigin.equals(oCopy)) {
					copiedAnchors.put(originChild.getAnchors().get(0), copyChild.getAnchors().get(0));
				}
			}
		}
	}
}
