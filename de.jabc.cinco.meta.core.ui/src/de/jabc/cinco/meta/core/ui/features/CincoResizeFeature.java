package de.jabc.cinco.meta.core.ui.features;

import java.util.List;

import org.eclipse.draw2d.geometry.Dimension;
import org.eclipse.draw2d.geometry.PointList;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.features.context.IResizeShapeContext;
import org.eclipse.graphiti.mm.PropertyContainer;
import org.eclipse.graphiti.mm.algorithms.AbstractText;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.algorithms.Polyline;
import org.eclipse.graphiti.mm.algorithms.styles.Point;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.services.IPeService;
//import info.scce.cinco.product.flowgraph.graphiti.features.layout.FlowGraphLayoutUtils;

public class CincoResizeFeature {
	
	public static final String FIXED = "_fixed";
	public static final String FIXED_WIDTH = "_fixedWidth";
	public static final String FIXED_HEIGHT = "_fixedHeight";
	
	public static final String KEY_INITIAL_POINTS = "initial_points";
	public static final String KEY_INITIAL_PARENT_SIZE = "initial_parent_size";
	
	public static final String KEY_HORIZONTAL = "horizontal";
	public static final String KEY_HORIZONTAL_LEFT = "h_layout_left";
	public static final String KEY_HORIZONTAL_RIGHT = "h_layout_right";
	
	public static final String KEY_VERTICAL = "vertical";
	public static final String KEY_VERTICAL_TOP = "v_layout_top";
	public static final String KEY_VERTICAL_BOTTOM = "v_layout_bottom";
	
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
		
//		//System.out.println(String.format("Size: (%s,%s)", ga.getWidth(), ga.getHeight()));
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
	
	private static void setNewLocationAndSize(GraphicsAlgorithm ga, Rectangle bounds) {
		if (((Shape) ga.getPictogramElement()).getContainer() instanceof Diagram)
			setLocationAndSize(ga, deltaX, deltaY, ga.getWidth() - bounds.width, ga.getHeight() - bounds.height);
		else setLocationAndSize(ga, bounds.x, bounds.y, ga.getWidth() - bounds.width, ga.getHeight() - bounds.height);
	}

	private static void setNewLocationAndSize(GraphicsAlgorithm ga) {
		boolean fixWth = checkPropertyValue(ga, FIXED_WIDTH, FIXED);
		boolean fixHgt = checkPropertyValue(ga, FIXED_HEIGHT, FIXED);
		setLocationAndSize(ga,
				fixWth ? 0 : deltaX,     // x
				fixHgt ? 0 : deltaY,     // y
				fixWth ? 0 : deltaWidth, // width
				fixHgt ? 0 : deltaHeight // height
			); 
	}

	private static void resizeByScale(Polyline polyline) {
		List<Point> points = polyline.getPoints();
		PointList initialPoints = getInitialPoints(polyline);
		Dimension initialParent = getInitialParentSize(polyline);
		Dimension oldParent = new Dimension(oldWidth, oldHeight);
		Dimension newParent = new Dimension(newWidth, newHeight);
		
		if (initialParent != null && initialPoints.size() > 0) {
			if (points.size() == initialPoints.size()) {
				for (int i=0; i<points.size(); i++) {
					Point p = points.get(i);
					p.setX(initialPoints.getPoint(i).x);
					p.setY(initialPoints.getPoint(i).y);
				}
				oldParent.setSize(initialParent.width, initialParent.height);
			} else {
				//System.out.println("WARN Polygon resize: points do not match reference points. "
					//	+ "Resizing based on current state, might be inaccurate.");
			}
		} else {
			//System.out.println("WARN Polygon resize: reference points and/or parent size not found. "
				//	+ "Resizing based on current state, might be inaccurate.");
		}
		
		if (checkPropertyValue(polyline, FIXED_WIDTH, FIXED))
			newParent.width = oldParent.width;
		if (checkPropertyValue(polyline, FIXED_HEIGHT, FIXED))
			newParent.height = oldParent.height;
		
		resizeByScale(points, oldParent, newParent,
				true, //checkPropertyValue(polyline, KEY_HORIZONTAL, KEY_HORIZONTAL_LEFT), // margin left fix
				true, //checkPropertyValue(polyline, KEY_HORIZONTAL, KEY_HORIZONTAL_RIGHT),// margin right fix
				true, //checkPropertyValue(polyline, KEY_VERTICAL, KEY_VERTICAL_TOP),      // margin top fix
				true); //checkPropertyValue(polyline, KEY_VERTICAL, KEY_VERTICAL_BOTTOM));  // margin bottom fix
		
		setNewLocationAndSize(polyline, calcBounds(polyline.getPoints()));
		resizeChildren(polyline);
	}

	private static void resizeByScale(List<Point> polypoints, Dimension oldParent, Dimension newParent,
			boolean marginLftFix, boolean marginRgtFix, boolean marginTopFix, boolean marginBtmFix) {
		
		Rectangle bounds = calcBounds(polypoints);
		double marginLft = bounds.x;
		double marginTop = bounds.y;
		double marginRgt = oldParent.width - bounds.width - marginLft;
		double marginBtm = oldParent.height - bounds.height - marginTop;
		
		double scaleX = (double) newParent.width / oldParent.width;
		double scaleY = (double) newParent.height / oldParent.height;
		
		double newWidth = newParent.width
				- marginLft * (marginLftFix ? 1 : scaleX)
				- marginRgt * (marginRgtFix ? 1 : scaleX);
		
		double newHeight = newParent.height
				- marginTop * (marginTopFix ? 1 : scaleY)
				- marginBtm * (marginBtmFix ? 1 : scaleY);
		
		moveByDelta(polypoints, - marginLft, - marginTop);
		
		scalePoints(polypoints,
				bounds.width > 0  ? newWidth / (double) bounds.width : 1.0,    // scaleX
				bounds.height > 0 ? newHeight / (double) bounds.height : 1.0); // scaleY
				
		moveByDelta(polypoints,
				marginLft * (marginLftFix ? 1 : scaleX),  // deltaX
				marginTop * (marginTopFix ? 1 : scaleY)); // deltaY
	}
	
	private static Rectangle calcBounds(List<Point> points) {
		int minX = getMinX(points);
		int minY = getMinY(points);
		return new Rectangle(minX, minY, getMaxX(points) - minX, getMaxY(points) - minY);
	}
	
	private static int getMinX(List<Point> points) {
		return points.stream().min((p1, p2) -> Integer.compare(p1.getX(), p2.getX())).get().getX();
	}
	
	private static int getMinY(List<Point> points) {
		return points.stream().min((p1, p2) -> Integer.compare(p1.getY(), p2.getY())).get().getY();
	}

	private static int getMaxX(List<Point> points) {
		return points.stream().max((p1, p2) -> Integer.compare(p1.getX(), p2.getX())).get().getX();
	}
	
	private static int getMaxY(List<Point> points) {
		return points.stream().max((p1, p2) -> Integer.compare(p1.getY(), p2.getY())).get().getY();
	}
	
	private static void moveByDelta(List<Point> points, double deltaX, double deltaY) {
		for (Point p : points) {
			p.setX(p.getX() + (int) deltaX);
			p.setY(p.getY() + (int) deltaY);
		}
	}
	
	private static Dimension getInitialParentSize(Polyline polyline) {
		IPeService peService = Graphiti.getPeService();
		String value = peService.getPropertyValue(polyline, KEY_INITIAL_PARENT_SIZE);
		if (value != null) {
			String[] values = value.split(",");
			return new Dimension(Integer.parseInt(values[0]), Integer.parseInt(values[1]));
		}
		return null;
	}

	private static PointList getInitialPoints(Polyline polyline) {
		PointList points = new PointList();
		IPeService peService = Graphiti.getPeService();
		String value = peService.getPropertyValue(polyline, KEY_INITIAL_POINTS);
		if (value != null) {
			String[] values = value.split(",");
			for (int i = 0; i < values.length; i += 2) {
				org.eclipse.draw2d.geometry.Point p = new org.eclipse.draw2d.geometry.Point(
						Integer.parseInt(values[i]),
						Integer.parseInt(values[i+1]));
				points.addPoint(p);
			}
		}
		return points;
	}
	
	private static boolean checkPropertyValue(PropertyContainer pc, String key, String value) {
		return value.equals(Graphiti.getPeService().getPropertyValue(pc, key));
	}

	private static void scalePoints(List<Point> points, double scaleX, double scaleY) {
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
