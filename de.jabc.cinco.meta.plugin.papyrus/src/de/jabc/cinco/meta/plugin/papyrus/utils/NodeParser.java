package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.util.ArrayList;

import style.AbstractShape;
import style.Appearance;
import style.ContainerShape;
import style.Ellipse;
import style.NodeStyle;
import style.Polygon;
import style.Rectangle;
import style.RoundedRectangle;
import style.Style;
import style.Styles;
import style.Text;
import mgl.Annotation;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.papyrus.model.NodeShape;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;

public class NodeParser {
	/**
	 * Transforms all nodes and containers to styled Nodes
	 * @param graphModel
	 * @param elements
	 * @param styles
	 * @return
	 */
	public static ArrayList<StyledNode> getStyledNodes(GraphModel graphModel, ArrayList<GraphicalModelElement> elements, Styles styles) {
		
		ArrayList<StyledNode> styledNodes = new ArrayList<StyledNode>();
		for(GraphicalModelElement node : elements) {
			
			StyledNode styledNode = new StyledNode();
			styledNode.setModelElement(node);
			String styleName = "";
			ArrayList<String> lables = new ArrayList<String>();
			for(Annotation annotation : node.getAnnotations()) {

				if(annotation.getName().toString().equals("style")) {
					styleName = annotation.getValue().get(0).toString();
					for(int i = 1; i < annotation.getValue().size(); i++) {
						lables.add(annotation.getValue().get(i).toString());
					}
				}
				
				styledNode.setLabel(lables);
			}
			
			Style style = CincoUtils.findStyle(styles, styleName);
			if(style instanceof NodeStyle) {
				NodeStyle nodeStyle = (NodeStyle) style;
				AbstractShape nodeShape = nodeStyle.getMainShape();
				Appearance appearance,shapeAppearance;
				//Get the shape appearance
				appearance = nodeShape.getInlineAppearance();
				if(appearance == null) {
					appearance = nodeShape.getReferencedAppearance();
				}
				appearance.getParent();
				shapeAppearance = ModelParser.getInheritedAppearance(appearance);
				
				styledNode.setBackgroundColor(shapeAppearance.getBackground());
				styledNode.setForegroundColor(shapeAppearance.getForeground());
				styledNode.setLineStyle(shapeAppearance.getLineStyle());
				styledNode.setLineWidth(shapeAppearance.getLineWidth());
				styledNode.setWidth(nodeShape.getSize().getWidth());
				styledNode.setHeight(nodeShape.getSize().getHeight());
				
				if(nodeShape instanceof Rectangle) {
					styledNode.setNodeShape(NodeShape.RECTANGLE);
				}
				else if(nodeShape instanceof RoundedRectangle) {
					RoundedRectangle roundedRectangle = (RoundedRectangle) nodeShape;
					styledNode.setCornerHeight(roundedRectangle.getCornerHeight());
					styledNode.setCornerWidth(roundedRectangle.getCornerWidth());
					styledNode.setNodeShape(NodeShape.ROUNDEDRECTANGLE);
				}
				else if(nodeShape instanceof Ellipse) {
					styledNode.setNodeShape(NodeShape.ELLIPSE);
				}
				else if(nodeShape instanceof Polygon) {
					Polygon polygon = (Polygon) nodeShape;
					styledNode.setNodeShape(NodeShape.POLYGON);
					styledNode.setPolygonPoints(Formatter.getPolygonPoints(polygon.getPoints()));
				}
				
				//Transform the children of the nodestyle
				if(nodeShape instanceof ContainerShape) {
					ContainerShape containerShape = (ContainerShape) nodeShape;
					for(AbstractShape abstractShape :containerShape.getChildren()) {
						if(abstractShape instanceof Text) {
							Text text = (Text) abstractShape;
							StyledLabel styledLabel = ModelParser.getStyledLabel(text);
							styledNode.setStyledLabel(styledLabel);
						}
					}
				}
				styledNodes.add(styledNode);
			}
		}
		return styledNodes;
	}
}
