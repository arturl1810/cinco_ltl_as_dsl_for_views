package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.util.ArrayList;
import java.util.HashMap;

import style.Alingnment;
import style.Appearance;
import style.EdgeStyle;
import style.Style;
import style.Styles;
import de.jabc.cinco.meta.core.utils.CincoUtils;
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.FontType;
import de.jabc.cinco.meta.plugin.papyrus.model.LableAlignment;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledModelElement;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;
import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;

public class ModelParser {
	
	public static ArrayList<StyledModelElement> getStyledModelElements(GraphModel graphModel) {
		return null;
	}
	
	public static ArrayList<StyledEdge> getStyledEdges(GraphModel graphModel, Styles styles) {
		ArrayList<StyledEdge> styledEdges = new ArrayList<StyledEdge>();
		for(Edge edge : graphModel.getEdges()) {
			StyledEdge styledEdge = new StyledEdge();
			String styleName = "";
			ArrayList<String> lables = new ArrayList<String>();
			for(Annotation annotation : edge.getAnnotations()) {
				if(annotation.getName() == "style") {
					styleName = annotation.getValue().get(0);
					for(int i = 1; i < annotation.getValue().size(); i++) {
						lables.add(annotation.getValue().get(i));
					}
				}
			}
			
			styledEdge.setLabel(lables);
			
			Style style = CincoUtils.findStyle(styles, styleName);
			if(style instanceof EdgeStyle) {
				EdgeStyle edgeStyle = (EdgeStyle) style;
			}
			
		}
		return styledEdges;
	}
	
	private static StyledLabel getStyledLabel(Appearance appearance){
		StyledLabel styledLabel = new StyledLabel();
		if(appearance.getParent() != null) {
			styledLabel = getStyledLabel(appearance.getParent());
		}
		if(appearance.getFont() != null){
			styledLabel.setFontName(appearance.getFont().getFontName());			
			if(appearance.getFont().isIsBold()) {
				styledLabel.setFontType(FontType.BOLD);
			}
			else if(appearance.getFont().isIsItalic()) {
				styledLabel.setFontType(FontType.ITALIC);
			}
			else{
				styledLabel.setFontType(FontType.NORMAL);
			}
			styledLabel.setLabelFontSize(appearance.getFont().getSize());
		}
		styledLabel.setLabelColor(appearance.getForeground());
		styledLabel.setLableAlignment(LableAlignment.CENTER);
		return styledLabel;
	}
	
	private static StyledConnector getStyledConnector(Appearance appearance){
		StyledConnector styledConnector = new StyledConnector();
		if(appearance.getParent() != null) {
			styledConnector = getStyledConnector(appearance.getParent());
		}
		if(appearance.getBackground() != null){
			styledConnector.setBackgroundColor(appearance.getBackground());
			styledConnector.setForegroundColor(appearance.getForeground());
			styledConnector.setLineWidth(appearance.getLineWidth());
			styledConnector.set
		}
		return styledLabel;
	}
	
	private static StyledEdge getStyledEdge(Appearance appearance) {
		StyledEdge styledEdge = new StyledEdge();
		if(appearance.getParent() != null) {
			styledEdge = getStyledEdge(appearance.getParent());
		}
		styledEdge.setBackgroundColor(appearance.getBackground());
		styledEdge.setForegroundColor(appearance.getForeground());
		return styledEdge;
		
	}
	
	public static ArrayList<StyledNode> getStyledNodes(GraphModel graphModel) {
		return null;
	}
	
	public static HashMap<String,ArrayList<StyledNode>> getGroupedNodes(GraphModel graphModel) {
		return null;
	}
	
	public static ArrayList<ConnectionConstraint> getValidConnections(GraphModel graphModel) {
		return null;
	}

}
