package de.jabc.cinco.meta.plugin.pyro.utils;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.filebuffers.manipulation.ContainerCreator;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.FileLocator;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.URIUtil;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EClassifier;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.osgi.framework.Bundle;

import mgl.Annotation;
import mgl.Attribute;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
import mgl.UserDefinedType;
import style.Appearance;
import style.BooleanEnum;
import style.Color;
import style.Font;
import style.LineStyle;
import style.StyleFactory;
import style.Text;
import de.jabc.cinco.meta.core.utils.PathValidator;
import de.jabc.cinco.meta.plugin.pyro.CreatePyroPlugin;
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint;
import de.jabc.cinco.meta.plugin.pyro.model.LabelAlignment;
import de.jabc.cinco.meta.plugin.pyro.model.StyledConnector;
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge;
import de.jabc.cinco.meta.plugin.pyro.model.StyledLabel;
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode;
import de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.pages.PyroTemplate;

public class ModelParser {
	
	public static String GROUP_ANNOTATION = "group";
	
	public static GraphicalModelElement getInheritedNode(GraphicalModelElement gme){
		if(gme instanceof Node){
			Node node = (Node) gme;
			if(node.getExtends() == null){
				return node;
			}
			Node parent = (Node) getInheritedNode(node.getExtends());
			node.getAttributes().addAll(parent.getAttributes());
			if(node.getIncomingEdgeConnections()== null || node.getIncomingEdgeConnections().isEmpty()){
				node.getIncomingEdgeConnections().addAll(parent.getIncomingEdgeConnections());
			}
			if(node.getOutgoingEdgeConnections() == null || node.getOutgoingEdgeConnections().isEmpty()){
				node.getOutgoingEdgeConnections().addAll(parent.getOutgoingEdgeConnections());
			}
			return node;
		}
		if(gme instanceof NodeContainer) {
			NodeContainer nodeContainer = (NodeContainer) gme;
			return getInheritedNodeContainer(nodeContainer);
		}
		return null;
		
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
		
		ArrayList<Node> nodes = new ArrayList<>(graphModel.getNodes());
		nodes.addAll((Collection<? extends Node>) graphModel.getNodeContainers());
		
		ArrayList<ConnectionConstraint> connectionConstraints = new ArrayList<ConnectionConstraint>();
		for(GraphicalModelElement sourceNode : nodes) {
			sourceNode = ModelParser.getInheritedNode(sourceNode);
			for(OutgoingEdgeElementConnection outgoingConnection : sourceNode.getOutgoingEdgeConnections()) {
				
					
				for(Edge outgoingEdge : outgoingConnection.getConnectingEdges()) {
					// Get the connectable nodes
					for(GraphicalModelElement targetNode : nodes) {
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
	
	public static ArrayList<ConnectionConstraint> filterForSource(String name,ArrayList<ConnectionConstraint> ccs)
	{
		ArrayList<ConnectionConstraint> connectionConstraints = new ArrayList<ConnectionConstraint>();
		for(ConnectionConstraint cc:ccs){
			boolean contains = false;
			if(!cc.getSourceNode().getModelElement().getName().equals(name)){
				continue;
			}
			for(ConnectionConstraint icc:connectionConstraints){
				if(icc.getConnectingEdge().getModelElement().getName().equals(cc.getConnectingEdge().getModelElement().getName()))
				{
					contains=true;
					break;
				}
			}
			if(!contains){
				connectionConstraints.add(cc);
			}
		}
		return connectionConstraints;
	}
	
	public static ArrayList<ConnectionConstraint> filterForEdge(ArrayList<ConnectionConstraint> ccs)
	{
		ArrayList<ConnectionConstraint> connectionConstraints = new ArrayList<ConnectionConstraint>();
		for(ConnectionConstraint cc:ccs){
			boolean contains = false;
			for(ConnectionConstraint icc:connectionConstraints){
				if(icc.getConnectingEdge().getModelElement().getName().equals(cc.getConnectingEdge().getModelElement().getName()))
				{
					contains=true;
					break;
				}
			}
			if(!contains){
				connectionConstraints.add(cc);
			}
		}
		return connectionConstraints;
	}
	
	public static boolean isCustomeAction(mgl.ModelElement modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("contextMenuAction")){
				return true;
			}
		}
		return false;
	}
	
	public static boolean isCustomeAction(mgl.GraphModel modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("contextMenuAction")){
				return true;
			}
		}
		return false;
	}
	
	public static boolean isCustomeActionAvailable(mgl.GraphModel modelElement)
	{
		if(ModelParser.isCustomeAction(modelElement)) {
			return true;
		}
		List<mgl.ModelElement> modelElements = new ArrayList<mgl.ModelElement>();
		modelElements.addAll(modelElement.getEdges());
		modelElements.addAll(modelElement.getNodeContainers());
		modelElements.addAll(modelElement.getNodes());
		for (mgl.ModelElement modelElement2 : modelElements) {
			if(isCustomeAction(modelElement2)) {
				return true;
			}
		}
		return false;
	}
	
	public static String getCustomeActionName(mgl.ModelElement modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("contextMenuAction")){
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split(".");
					if(parts.length == 0){
						return value;
					}
					return parts[parts.length-1];
				}
			}
		}
		return null;
	}
	
	public static ArrayList<String> getCustomActionNames(mgl.ModelElement modelElement){
		ArrayList<String> customeActionNames = new ArrayList<String>();
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("contextMenuAction")){
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split(".");
					if(parts.length == 0){
						customeActionNames.add(value);
					}
					else {
						customeActionNames.add(parts[parts.length-1]);						
					}
				}
			}
		}
		return customeActionNames;
	}
	
	public static ArrayList<String> getCustomActionNames(mgl.GraphModel modelElement){
		ArrayList<String> customeActionNames = new ArrayList<String>();
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("contextMenuAction")){
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split(".");
					if(parts.length == 0){
						customeActionNames.add(value);
					}
					else {
						customeActionNames.add(parts[parts.length-1]);						
					}
				}
			}
		}
		return customeActionNames;
	}
	
	public static String getCustomActionName(mgl.Annotation annotation){
		if(annotation.getName().equals("contextMenuAction")){
			if(annotation.getValue().size()>=1){
				String value = annotation.getValue().get(0);
				String[] parts = value.split("\\.");
				if(parts.length == 0){
					return value;
				}
				return parts[parts.length-1];
			}
		}
		return null;
	}
	
	public static String getCustomActionName(String anno){
		String[] parts = anno.split("\\.");
		if(parts.length == 0){
			return anno;
		}
		return parts[parts.length-1];
	}
	
	public static boolean isUserDefinedType(mgl.Attribute attribute,ArrayList<mgl.Type> types)
	{
		for (mgl.Type type : types) {
			if(type.getName().equals(attribute.getType()) && type instanceof UserDefinedType){
				return true;
			}
		}
		return false;
	}
	
	public static List<mgl.Attribute> getNoUserDefinedAttributtes(List<mgl.Attribute> attributes,ArrayList<mgl.Type> types)
	{
		List<Attribute> noUseDefinedAttributes = new ArrayList<Attribute>();
		for (Attribute attribute : attributes) {
			if(!ModelParser.isUserDefinedType(attribute, types)){
				noUseDefinedAttributes.add(attribute);
			}
		}
		return noUseDefinedAttributes;
	}
	
	public static boolean isPrimeRefernceAvailable(mgl.GraphModel graphModel)
	{
		//Prime Refs
		for(mgl.Annotation annotation: graphModel.getAnnotations()){
			if(annotation.getName().equals(CreatePyroPlugin.PRIME)){
				return true;
			}
		}
		return false;
	}
	
	public static List<mgl.ReferencedType> getPrimeReferencedModelElements(mgl.GraphModel graphModel,boolean selfReferencingIncluded)
	{
		List<mgl.ReferencedType> elements = new ArrayList<mgl.ReferencedType>();
		for(mgl.Node node:graphModel.getNodes()) {
			if(node.getPrimeReference() != null) {
				if(!selfReferencingIncluded) {
					ArrayList<ModelElement> modelElements = new ArrayList<ModelElement>();
					modelElements.addAll(graphModel.getNodeContainers());
					modelElements.addAll(graphModel.getNodes());
					modelElements.addAll(graphModel.getEdges());
					boolean selfReferencing = false;
					for(ModelElement modelElement:modelElements){
						if(modelElement.getName().equals(node.getPrimeReference().getType().getName())){
							selfReferencing = true;
							break;
						}
					}
					if(!selfReferencing){
						elements.add(node.getPrimeReference());					
					}
				}
				else {
					elements.add(node.getPrimeReference());		
				}
			}
		}
		
		return elements;
	}
	
	public static String getPrimeAttributeLabel(mgl.ReferencedType referencedType)
	{
		for(Annotation annotation:referencedType.getAnnotations())
		{
			if(annotation.getName().equals(CreatePyroPlugin.PRIME_LABEL)) {
				if(annotation.getValue().size() > 0){
					return annotation.getValue().get(0);
				}
			}
		}
		return "Name";
	}
	
	public static String getPrimeRefName(mgl.Node node)
	{
		if(node.getPrimeReference() != null){
			return node.getPrimeReference().getType().getName();
		}
		return "";
	}
	
	public static String getPrimeAttrName(mgl.Node node)
	{
		if(node.getPrimeReference() != null){
			return node.getPrimeReference().getName();
		}
		return "";
	}
	
	public static ModelElement getReferencedModelType(mgl.GraphModel graphmodel,mgl.Attribute attribute){
		List<ModelElement> modelElements = new ArrayList<ModelElement>();
		modelElements.addAll(graphmodel.getEdges());
		modelElements.addAll(graphmodel.getNodeContainers());
		modelElements.addAll(graphmodel.getNodes());
		
		for(ModelElement modelElement : modelElements) {
			if(modelElement.getName().equals(attribute.getType())){
				return modelElement;
			}
		}
		
		return null;
	}
	
	public static boolean isReferencedModelType(mgl.GraphModel graphmodel,mgl.Attribute attribute){
		return getReferencedModelType(graphmodel, attribute)!=null;
	}

}
