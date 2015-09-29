package de.jabc.cinco.meta.core.ui.features;

import graphmodel.Container;
import graphmodel.GraphModel;
import graphmodel.Node;
//import info.scce.cinco.product.flowgraph.graphiti.features.layout.FlowGraphLayoutUtils;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.mm.algorithms.AbstractText;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.Polyline;
import org.eclipse.graphiti.mm.algorithms.styles.Point;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.services.Graphiti;

public class CincoResizeFeature {
	
	public static final String FIXED = "_fixed";
	public static final String FIXED_WIDTH = "_fixedWidth";
	public static final String FIXED_HEIGHT = "_fixedHeight";
	private static EObject bo;
	
	private static int oldWidth, oldHeight, newWidth, newHeight, contextX, contextY, deltaWidth, deltaHeight, deltaX, deltaY;
	private static double scaleX, scaleY;
	
	public static void resize(final IResizeShapeContext context) {
		EList<EObject> businessObjects = context.getPictogramElement().getLink().getBusinessObjects();
		if (businessObjects != null && !businessObjects.isEmpty())
			bo = businessObjects.get(0);
		
		Shape shape = context.getShape();
		GraphicsAlgorithm ga = shape.getGraphicsAlgorithm();

		oldWidth = ga.getWidth();
		oldHeight = ga.getHeight();
		
		newWidth = context.getWidth();
		newHeight = context.getHeight();
		
		scaleX = (double) newWidth / (double) oldWidth;
		scaleY = (double) newHeight / (double) oldHeight;
		
		deltaWidth = oldWidth - newWidth; 
		deltaHeight = oldHeight - newHeight;
		
		deltaX = context.getX() - ga.getX();
		deltaY = context.getY() - ga.getY();
		
		contextX = context.getX();
		contextY = context.getY();
		
		resize(shape);
		
//		System.out.println(String.format("Size: (%s,%s)", ga.getWidth(), ga.getHeight()));
//		System.err.println(String.format("Pos: (%s,%s)", ga.getX(), ga.getY()));
	}
	
	private static void resize(Shape shape) {
		GraphicsAlgorithm ga = shape.getGraphicsAlgorithm();
		if (ga instanceof Polyline)
			resizeByScale((Polyline) ga);
		else resizeByDelta(ga);
	}
	
	private static void resizeByDelta(GraphicsAlgorithm ga) {
		setNewLocationAndSize(ga);
		resizeChildren(ga);
	}

	private static void setNewLocationAndSize(GraphicsAlgorithm ga) {
		String fWidth = Graphiti.getPeService().getPropertyValue(ga, FIXED_WIDTH);
		String fHeight = Graphiti.getPeService().getPropertyValue(ga, FIXED_HEIGHT);
		
		int dX = deltaX, dY = deltaY, dWidth = deltaWidth, dHeight = deltaHeight;
		
		if (FIXED.equals(fWidth)) {
			dX = 0;
			dWidth = 0;
		}
		if (FIXED.equals(fHeight)) {
			dY = 0;
			dHeight = 0;
		}
		setLocationAndSize(ga, dX, dY, dWidth, dHeight);
	}

	private static void resizeByScale(Polyline polyline) {
		String fWidth = Graphiti.getPeService().getPropertyValue(polyline, FIXED_WIDTH);
		String fHeight = Graphiti.getPeService().getPropertyValue(polyline, FIXED_HEIGHT);
		
		double sX = scaleX, sY = scaleY;
		
		if (FIXED.equals(fWidth)) {
			sX = 1;
		}
		if (FIXED.equals(fHeight)) {
			sY = 1;
		}
		
		scalePoints(polyline.getPoints(), sX, sY);
		setNewLocationAndSize(polyline);
		resizeChildren(polyline);
	}
	

	private static void scalePoints(EList<Point> points, double scaleX, double scaleY) {
		for (Point p : points) {
			p.setX((int) (scaleX * p.getX()));
			p.setY((int) (scaleY * p.getY()));
		}
	}
	
	private static void resizeChildren(GraphicsAlgorithm ga) {
		if (ga.getPictogramElement() instanceof ContainerShape) {
			for (Shape s : ((ContainerShape) ga.getPictogramElement()).getChildren()) {
				if (isResizable(s)) {
					resize(s);
				}
			}
		}
	}

	private static void setLocationAndSize(GraphicsAlgorithm ga, int deltaX, int deltaY, int deltaWidth, int deltaHeight) {
		EObject boGa = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(ga.getPictogramElement());
		EObject boparent = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement((PictogramElement) ga.getPictogramElement().eContainer());
		if (!boGa.equals(boparent)) 
			Graphiti.getGaService().setLocationAndSize(ga, ga.getX() + deltaX, ga.getY() + deltaY, ga.getWidth() - deltaWidth, ga.getHeight() - deltaHeight);
		else Graphiti.getGaService().setLocationAndSize(ga, ga.getX(), ga.getY(), ga.getWidth() - deltaWidth, ga.getHeight() - deltaHeight);
	}
	
	
//	private static void moveByDelta(Shape shape, int deltaX, int deltaY) {
//		GraphicsAlgorithm ga = shape.getGraphicsAlgorithm();
//		if (ga != null && isInnerShape(ga)) {
//			if (ga instanceof Polyline)
//				movePointsByDelta((Polyline) ga, deltaX, deltaY);
//			Graphiti.getGaService().setLocation(ga, ga.getX() + deltaX, ga.getY() + deltaY);
//			if (shape instanceof ContainerShape) {
//				for (Shape child : ((ContainerShape) shape).getChildren()) {
//					moveByDelta(child, deltaX, deltaY);
//				}
//			}
//		}
//	}
	
	private static boolean isResizable(Shape s) {
		EList<EObject> bos = s.getLink() != null ? s.getLink().getBusinessObjects() : null;
		EObject currentBo = null;
		if (bos != null && !bos.isEmpty())
			currentBo = bos.get(0);
		return (currentBo == null || currentBo.equals(bo)) && !(s.getGraphicsAlgorithm() instanceof AbstractText);
	}
	
	private static void movePointsByDelta(Polyline polyline, int deltaY, int deltaX) {
		polyline.getPoints().forEach(p -> p.setX(p.getX() + deltaX));
		polyline.getPoints().forEach(p -> p.setY(p.getY() + deltaY));
	}
	
//	private static boolean isInnerShape(GraphicsAlgorithm ga) {
//		if (ga instanceof AbstractText
//				|| Graphiti.getPeService().getProperty(ga, FlowGraphLayoutUtils.KEY_HORIZONTAL).equals(FlowGraphLayoutUtils.KEY_HORIZONTAL_UNDEFINED))
//			return true;
//		if (bo instanceof Node)
//			return false;
//		return !(bo instanceof Container && sharesBusinessObject(ga));
//	}

	private static boolean sharesBusinessObject(GraphicsAlgorithm ga) {
		EObject linkedBO = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(ga.getPictogramElement());
		while (linkedBO == null) {
			linkedBO = Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement((PictogramElement) ga.getPictogramElement().eContainer());
		}
		return (bo.equals(linkedBO));
	}
	
	
	
}
