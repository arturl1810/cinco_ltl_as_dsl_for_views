package de.jabc.cinco.meta.plugin.pyro.utils;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.pyro.model.NodeShape;
import de.jabc.cinco.meta.plugin.pyro.model.StyledLabel;
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode;
import mgl.Annotation;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.Node;
import mgl.NodeContainer;
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

public class NodeParser{
	/**
	 * Transforms all nodes and containers to styled Nodes
	 * @param graphModel
	 * @param elements
	 * @param styles
	 * @return
	 */
	public static List<StyledNode> getStyledNodes(GraphModel graphModel, List<GraphicalModelElement> elements, Styles styles) {
		
		List<StyledNode> styledNodes = new LinkedList<StyledNode>();
		for(GraphicalModelElement node : elements) {
			if(node.isIsAbstract())continue;
			StyledNode styledNode = new StyledNode();
			if(node instanceof Node){
				styledNode.setModelElement(ModelParser.getInheritedNode((Node)node));				
			}
			else if(node instanceof NodeContainer){
				styledNode.setModelElement(ModelParser.getInheritedNodeContainer((NodeContainer)node));
			}
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
				//appearance.getParent();
				shapeAppearance = ModelParser.getInheritedAppearance(appearance);
				
				styledNode.setStyle(style);
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
