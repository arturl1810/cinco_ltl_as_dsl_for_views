package de.jabc.cinco.meta.plugin.papyrus.utils;

import java.util.ArrayList;
import java.util.HashMap;

import org.eclipse.emf.ecore.util.EcoreUtil;

import mgl.Annotation;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
import style.Appearance;
import style.BooleanEnum;
import style.Color;
import style.Font;
import style.LineStyle;
import style.StyleFactory;
import style.Text;
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.EmbeddingConstraint;
import de.jabc.cinco.meta.plugin.papyrus.model.LabelAlignment;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledConnector;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledLabel;
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode;

public class ModelParser {
	
	public static String GROUP_ANNOTATION = "group";
	
	public static Node getInheritedNode(Node node){
		if(node.getExtends() == null){
			return node;
		}
		Node parent = getInheritedNode(node.getExtends());
		node.getAttributes().addAll(parent.getAttributes());
		if(node.getIncomingEdgeConnections()== null || node.getIncomingEdgeConnections().isEmpty()){
			node.getIncomingEdgeConnections().addAll(parent.getIncomingEdgeConnections());
		}
		if(node.getOutgoingEdgeConnections() == null || node.getOutgoingEdgeConnections().isEmpty()){
			node.getOutgoingEdgeConnections().addAll(parent.getOutgoingEdgeConnections());
		}
		return node;
	}
	
	public static NodeContainer getInheritedNodeContainer(NodeContainer nodeContainer){
		if(nodeContainer.getExtends() == null){
			return nodeContainer;
		}
		NodeContainer parent = getInheritedNodeContainer(nodeContainer.getExtends());
		nodeContainer.getAttributes().addAll(parent.getAttributes());
		if(nodeContainer.getIncomingEdgeConnections()== null || nodeContainer.getIncomingEdgeConnections().isEmpty()){
			nodeContainer.getIncomingEdgeConnections().addAll(parent.getIncomingEdgeConnections());
		}
		if(nodeContainer.getOutgoingEdgeConnections() == null || nodeContainer.getOutgoingEdgeConnections().isEmpty()){
			nodeContainer.getOutgoingEdgeConnections().addAll(parent.getOutgoingEdgeConnections());
		}
		if(nodeContainer.getContainableElements() == null || nodeContainer.getContainableElements().isEmpty()) {
			nodeContainer.getContainableElements().addAll(parent.getContainableElements());
		}
		return nodeContainer;
	}
	
	public static Edge getInheritedEdge(Edge edge){
		if(edge.getExtends() == null){
			return edge;
		}
		Edge parent = getInheritedEdge(edge.getExtends());
		edge.getAttributes().addAll(parent.getAttributes());
		return edge;
	}
	
	
	public static HashMap<String,ArrayList<StyledNode>> getGroupedNodes(ArrayList<GraphicalModelElement> graphicalModelElements) {
		HashMap<String,ArrayList<StyledNode>> groupedNodes = new HashMap<String,ArrayList<StyledNode>>();
		for(GraphicalModelElement gme : graphicalModelElements) {
			if(gme.isIsAbstract())continue;
			StyledNode styledNode = new StyledNode();
			styledNode.setModelElement(gme);
			String groupName;
			if(gme instanceof NodeContainer) {
				groupName = "Containers";
			}
			else {
				groupName = "Nodes";
			}
			for(Annotation annotation : gme.getAnnotations()) {
				if(annotation.getName().equals(GROUP_ANNOTATION)) {
					groupName = annotation.getValue().get(0);
					break;
				}
			}
			
			if(groupedNodes.containsKey(groupName)) {
				groupedNodes.get(groupName).add(styledNode);
			}
			else {
				ArrayList<StyledNode> styledNodes = new ArrayList<StyledNode>();
				styledNodes.add(styledNode);
				groupedNodes.put(groupName,styledNodes);
			}
		}
		return groupedNodes;
	}
	
	public static ArrayList<ConnectionConstraint> getValidConnections(GraphModel graphModel) {
		ArrayList<ConnectionConstraint> connectionConstraints = new ArrayList<ConnectionConstraint>();
		for(Node sourceNode : graphModel.getNodes()) {
			sourceNode = ModelParser.getInheritedNode(sourceNode);
			for(OutgoingEdgeElementConnection outgoingConnection : sourceNode.getOutgoingEdgeConnections()) {
				
					
				for(Edge outgoingEdge : outgoingConnection.getConnectingEdges()) {
					// Get the connectable nodes
					for(Node targetNode : graphModel.getNodes()) {
						targetNode = ModelParser.getInheritedNode(targetNode);
						for(IncomingEdgeElementConnection incommingConnection : targetNode.getIncomingEdgeConnections()) {
							
							
							for(Edge incommingEdge : incommingConnection.getConnectingEdges()) {
								
								if(incommingEdge.getName().equals(outgoingEdge.getName())) {
									
									ConnectionConstraint cc = new ConnectionConstraint();
									
									StyledNode styledSourceNode = new StyledNode();
									styledSourceNode.setModelElement(sourceNode);
									cc.setSourceNode(styledSourceNode);
									
									StyledNode styledTargetNode = new StyledNode();
									styledTargetNode.setModelElement(targetNode);
									cc.setTargetNode(styledTargetNode);
									
									StyledEdge styledEdge = new StyledEdge();
									styledEdge.setModelElement(outgoingEdge);
									cc.setConnectingEdge(styledEdge);
									
									cc.setSourceCardinalityLow(outgoingConnection.getLowerBound());
									cc.setSourceCardinalityHigh(outgoingConnection.getUpperBound());
									
									cc.setTargetCardinalityLow(incommingConnection.getLowerBound());
									cc.setTargetCardinalityHigh(incommingConnection.getUpperBound());
									
									connectionConstraints.add(cc);
								}
							}
							
						}
					}
					
				}
				
			}
		}
		return connectionConstraints;
	}
	
	/**
	 * 
	 * @param appearance
	 * @return
	 */
	public static Appearance getInheritedAppearance(Appearance appearance) {
		if(appearance == null) {
			return getDefaultAppearance();
		}
		Appearance parentAppearance = getInheritedAppearance(appearance.getParent());
		//Overriding
		if(appearance.getBackground() != null)parentAppearance.setBackground(EcoreUtil.copy(appearance.getBackground()));
		if(appearance.getForeground() != null)parentAppearance.setForeground(EcoreUtil.copy(appearance.getForeground()));
		if(appearance.getFont() != null) {
			parentAppearance.setFont(EcoreUtil.copy(appearance.getFont()));
		}
		if(appearance.getLineStyle() != null && appearance.getLineStyle() != LineStyle.UNSPECIFIED)parentAppearance.setLineStyle(appearance.getLineStyle());
		if(appearance.getLineWidth() >= 0)parentAppearance.setLineWidth(appearance.getLineWidth());
		if(appearance.getAngle() >= 0)parentAppearance.setAngle(appearance.getAngle());
		if(appearance.getFilled() != null)parentAppearance.setFilled(appearance.getFilled());
		if(appearance.getLineInVisible() != null)parentAppearance.setLineInVisible(appearance.getLineInVisible());
		if(appearance.getTransparency() >= 0)parentAppearance.setTransparency(appearance.getTransparency());
		return parentAppearance;
		
	}
	
	private static Appearance getDefaultAppearance() {
		Appearance appearance = StyleFactory.eINSTANCE.createAppearance();
		
		appearance.setAngle(0);
		appearance.setFilled(BooleanEnum.TRUE);
		appearance.setParent(null);
		appearance.setName(null);
		
		//FONT
		Font font = StyleFactory.eINSTANCE.createFont();
		font.setFontName("Arial");
		font.setIsBold(false);
		font.setIsItalic(false);
		font.setSize(6);
		appearance.setFont(font);
		
		//COLORS
		appearance.setBackground(getColor(255, 255, 255));
		
		//COLORS
		appearance.setForeground(getColor(0, 0, 0));
		
		appearance.setLineInVisible(false);
		appearance.setLineStyle(LineStyle.SOLID);
		appearance.setLineWidth(1);
		appearance.setTransparency(0);
		
		return appearance;
	}
	
	public static Color getColor(int r,int g,int b) {
		Color foreGroundColor = StyleFactory.eINSTANCE.createColor();
		foreGroundColor.setR(r);
		foreGroundColor.setG(g);
		foreGroundColor.setB(b);
		return foreGroundColor;
	}
	
	public static StyledConnector getDefaultConnector() {
		StyledConnector styledConnector = new StyledConnector();	
		styledConnector.setBackgroundColor(getColor(255, 255, 255));
		styledConnector.setForegroundColor(getColor(0, 0, 0));
		styledConnector.setLineStyle(LineStyle.SOLID);
		styledConnector.setLineWidth(2.0);
		styledConnector.setPolygonPoints(Formatter.getEdgeConnector(null,2.0));
		
		return styledConnector;
	}
	
	public static StyledLabel getStyledLabel(Text text) {
		
		StyledLabel styledLabel = new StyledLabel();
		styledLabel.setValue(text.getValue());
		
		// Get appearance for the text decorator
		Appearance appearance = text.getInlineAppearance();
		if(appearance == null) {
			appearance = text.getReferencedAppearance();
		}
		appearance = ModelParser.getInheritedAppearance(appearance);
		
		if(appearance != null) {
			if(appearance.getFont() != null) {
				styledLabel.setFontName(appearance.getFont().getFontName());
				styledLabel.setFontType(Formatter.toFontType(appearance.getFont()));
				styledLabel.setLabelFontSize(appearance.getFont().getSize());
			}
			styledLabel.setLabelColor(appearance.getForeground());
		}
		
		if(text.getColor() != null) {
			styledLabel.setLabelColor(text.getColor());							
		}
		styledLabel.setLableAlignment(LabelAlignment.CENTER);
		
		return styledLabel;
	}

	public static ArrayList<EmbeddingConstraint> getValidEmbeddings(GraphModel graphModel) {
		ArrayList<EmbeddingConstraint> ecs = new ArrayList<EmbeddingConstraint>();
		for(NodeContainer container : graphModel.getNodeContainers()) {
			container = ModelParser.getInheritedNodeContainer(container);
			for(GraphicalElementContainment gec : container.getContainableElements()) {
				EmbeddingConstraint ec = new EmbeddingConstraint();
				ArrayList<GraphicalModelElement> validNodes = new ArrayList<GraphicalModelElement>();
				
				ec.setContainer(container);
				if(gec.getType() == null){
					for(Node node : graphModel.getNodes()) {
						validNodes.add(node);
					}
					for(NodeContainer nodeContainer : graphModel.getNodeContainers()) {
						validNodes.add(nodeContainer);
					}
				}
				else{
					if(gec.getType() instanceof Node || gec.getType() instanceof NodeContainer) {
						validNodes.add(gec.getType());
					}					
				}
				ec.setLowBound(gec.getLowerBound());
				ec.setHighBound(gec.getUpperBound());
				ec.setValidNode(validNodes);
				ecs.add(ec);
			}
		}
		return ecs;
	}

}
