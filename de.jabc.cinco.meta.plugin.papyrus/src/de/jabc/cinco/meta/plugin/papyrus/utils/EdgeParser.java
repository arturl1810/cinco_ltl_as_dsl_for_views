package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.util.ArrayList;

import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import style.Appearance;
import style.ConnectionDecorator;
import style.EdgeStyle;
import style.PredefinedDecorator;
import style.Style;
import style.Styles;
import style.Text;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel;

public class EdgeParser {
	public static ArrayList<StyledEdge> getStyledEdges(GraphModel graphModel, Styles styles) {
		ArrayList<StyledEdge> styledEdges = new ArrayList<StyledEdge>();
		for(Edge edge : graphModel.getEdges()) {
			StyledEdge styledEdge = new StyledEdge();
			styledEdge.setModelElement(edge);
			String styleName = "";
			ArrayList<String> lables = new ArrayList<String>();
			for(Annotation annotation : edge.getAnnotations()) {

				if(annotation.getName().toString().equals("style")) {
					styleName = annotation.getValue().get(0).toString();
					for(int i = 1; i < annotation.getValue().size(); i++) {
						lables.add(annotation.getValue().get(i).toString());
					}
				}
			}
			
			styledEdge.setLabel(lables);
			
			Style style = CincoUtils.findStyle(styles, styleName);
			if(style instanceof EdgeStyle) {
				EdgeStyle edgeStyle = (EdgeStyle) style;
				Appearance edgeShapeAppearance, shapeAppearance;
				//Transform the Edge-shape appearance
				shapeAppearance = edgeStyle.getInlineAppearance();
				if(shapeAppearance == null) {
					shapeAppearance = edgeStyle.getReferencedAppearance();
				}
				edgeShapeAppearance = ModelParser.getInheritedAppearance(shapeAppearance);
				styledEdge.setBackgroundColor(edgeShapeAppearance.getBackground());
				styledEdge.setForegroundColor(edgeShapeAppearance.getForeground());
				styledEdge.setLineStyle(edgeShapeAppearance.getLineStyle());
				styledEdge.setLineWidth(edgeShapeAppearance.getLineWidth());
				styledEdge.setTransperancy(edgeShapeAppearance.getTransparency());
				
				//Transform the target and source decorator
				for(ConnectionDecorator decorator :edgeStyle.getDecorator()) {
					//Get connection decorator appearance
					StyledConnector styledConnector = new StyledConnector();
					PredefinedDecorator connectorPredefinedDecorator = decorator.getPredefinedDecorator();
					Appearance decoratorAppearance, appearance;
					
					//Edge-Label TEXT
					if(connectorPredefinedDecorator == null) {
						
						StyledLabel styledLabel = ModelParser.getStyledLabel((Text) decorator.getDecoratorShape());
						styledLabel.setLocation(decorator.getLocation());
						styledEdge.setStyledLabel(styledLabel);
						continue;
						
					}
					
					//Edge-Connector
					else{
						appearance = connectorPredefinedDecorator.getInlineAppearance();
						if(appearance == null) {
							appearance = connectorPredefinedDecorator.getReferencedAppearance();
						}
						decoratorAppearance = ModelParser.getInheritedAppearance(appearance);
						
						//transform the decorator appearance
						styledConnector.setBackgroundColor(decoratorAppearance.getBackground());
						styledConnector.setForegroundColor(decoratorAppearance.getForeground());
						styledConnector.setLineWidth(decoratorAppearance.getLineWidth());
						styledConnector.setLineStyle(decoratorAppearance.getLineStyle());
						
						styledConnector.setPolygonPoints(Formatter.getEdgeConnector(decorator.getPredefinedDecorator().getShape()));
						if(decorator.getLocation() == 0.0){
							styledEdge.setSourceConnector(styledConnector);
						}
						else if(decorator.getLocation() == 1.0) {
							styledEdge.setTargetConnector(styledConnector);
						}
						
					}
					
				}
				styledEdges.add(styledEdge);
			}
		}
		return styledEdges;
	}
	
}
