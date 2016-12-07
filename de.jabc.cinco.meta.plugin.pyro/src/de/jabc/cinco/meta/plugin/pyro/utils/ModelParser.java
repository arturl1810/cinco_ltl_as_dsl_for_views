package de.jabc.cinco.meta.plugin.pyro.utils;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.util.EcoreUtil;

import de.jabc.cinco.meta.plugin.pyro.CreatePyroPlugin;
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint;
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint;
import de.jabc.cinco.meta.plugin.pyro.model.LabelAlignment;
import de.jabc.cinco.meta.plugin.pyro.model.StyledConnector;
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge;
import de.jabc.cinco.meta.plugin.pyro.model.StyledLabel;
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode;
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
import mgl.ReferencedEClass;
import mgl.UserDefinedType;
import style.AbstractShape;
import style.Appearance;
import style.BooleanEnum;
import style.Color;
import style.ContainerShape;
import style.Font;
import style.LineStyle;
import style.StyleFactory;
import style.Text;

public class ModelParser {
	
	public static String GROUP_ANNOTATION = "palette";
	public static String DISABLE_ANNOTATION = "disable";
	public static String DISABLE_MOVE_ANNOTATION = "move";
	public static String DISABLE_CREATE_ANNOTATION = "create";
	public static String DISABLE_DELETE_ANNOTATION = "delete";
	
	public static List<GraphicalModelElement> getInheritanceChildren(GraphicalModelElement gme, GraphModel graphModel)
	{
		List<GraphicalModelElement> elements = new LinkedList<GraphicalModelElement>();
		if(gme instanceof Node){
			for(Node node:graphModel.getNodes()){
				if(node.getExtends() != null){
					if(node.getExtends().getName().equals(gme.getName())){
						elements.add(node);
					}
				}
			}
		}
		if(gme instanceof Edge){
			for(Edge node:graphModel.getEdges()){
				if(node.getExtends() != null){
					if(node.getExtends().getName().equals(gme.getName())){
						elements.add(node);
					}
				}
			}
		}
		if(gme instanceof NodeContainer){
			for(NodeContainer node:getNodeContainers(graphModel)) {
				if(node.getExtends() != null){
					if(node.getExtends().getName().equals(gme.getName())){
						elements.add(node);
					}
				}
			}
		}
		return elements;
	}

	private static List<NodeContainer> getNodeContainers(GraphModel graphModel) {
		return graphModel.getNodes().stream().filter(n -> n instanceof NodeContainer ).map(nc -> (NodeContainer) nc).collect(Collectors.toList());
	}
	
	public static List<StyledNode> getNotDisbaledCreate(List<StyledNode> nodes){
		List<StyledNode> notDisbaledNodes = new LinkedList<StyledNode>();
		for(StyledNode n:nodes){
			if(!isDisabledCreate(n.getModelElement())){
				notDisbaledNodes.add(n);
			}
		}
		return notDisbaledNodes;
	}
	
	public static boolean isDisabledMove(GraphicalModelElement gme){
		return containsDisableValue(gme, DISABLE_MOVE_ANNOTATION);
	}
	
	public static boolean isDisabledCreate(GraphicalModelElement gme){
		return containsDisableValue(gme, DISABLE_CREATE_ANNOTATION);
	}
	
	public static boolean isDisabledDelete(GraphicalModelElement gme){
		return containsDisableValue(gme, DISABLE_DELETE_ANNOTATION);
	}
	
	private static boolean containsDisableValue(GraphicalModelElement gme,String value){
		for(Annotation a:gme.getAnnotations()) {
			if(a.getName().equals(DISABLE_ANNOTATION)){
				for(String s:a.getValue()){
					if(s.equals(value)){
						return true;
					}
				}
			}
		}
		return false;
	}
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
	
	public static boolean isContainable(GraphicalModelElement containment, NodeContainer container){
		for(GraphicalElementContainment gec:container.getContainableElements()){
			for(GraphicalModelElement gme:gec.getTypes()) {
				if(isContainable(gme, containment)){
					return true;
				}
			}
		}
		return false;
	}
	
	private static boolean isContainable(GraphicalModelElement conditional,GraphicalModelElement containment)
	{
		if(conditional.getName().equals(containment.getName())){
			return true;
		}
		if(containment instanceof Node){
			if(((Node) containment ).getExtends() != null){
				return isContainable(conditional, ((Node) containment ).getExtends());				
			}
		}
		else if(containment instanceof NodeContainer){
			if(((NodeContainer) containment ).getExtends() != null){
				return isContainable(conditional, ((NodeContainer) containment ).getExtends());				
			}
		}
		return false;
	}
	
	public static boolean canContain(GraphModel c, GraphicalModelElement n) {
		for(GraphicalElementContainment gec:c.getContainableElements()) {
			for(GraphicalModelElement gme: gec.getTypes()){
				if(gme.getName().equals(n.getName()) && gec.getUpperBound() > 0){
					return true;
				}
			}
		}
		return false;
	}

	
	public static StyledNode getStyledNode(List<StyledNode> nodes,String name){
		for(StyledNode sn:nodes){
			if(sn.getModelElement().getName().equals(name)){
				return sn;
			}
		}
		return null;
	}
		
	
	
	public static NodeContainer getInheritedNodeContainer(NodeContainer nodeContainer){
		if(nodeContainer.getExtends() == null){
			return nodeContainer;
		}
		NodeContainer parent = getInheritedNodeContainer((NodeContainer) nodeContainer.getExtends());
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
	
	
	public static HashMap<String,List<StyledNode>> getGroupedNodes(List<GraphicalModelElement> graphicalModelElements) {
		HashMap<String,List<StyledNode>> groupedNodes = new HashMap<String,List<StyledNode>>();
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
				List<StyledNode> styledNodes = new LinkedList<StyledNode>();
				styledNodes.add(styledNode);
				groupedNodes.put(groupName,styledNodes);
			}
		}
		return groupedNodes;
	}
	
	public static ArrayList<ConnectionConstraint> getValidConnections(GraphModel graphModel) {
		
		ArrayList<Node> nodes = new ArrayList<>(graphModel.getNodes());
//		nodes.addAll((Collection<? extends Node>) graphModel.getNodeContainers());
		
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
		for(NodeContainer container : getNodeContainers(graphModel)) {
			container = ModelParser.getInheritedNodeContainer(container);
			for(GraphicalElementContainment gec : container.getContainableElements()) {
				EmbeddingConstraint ec = new EmbeddingConstraint();
				ArrayList<GraphicalModelElement> validNodes = new ArrayList<GraphicalModelElement>();
				
				ec.setContainer(container);
				if(gec.getTypes().isEmpty()){
					for(Node node : graphModel.getNodes()) {
						validNodes.add(node);
					}
					for(NodeContainer nodeContainer : getNodeContainers(graphModel)) {
						validNodes.add(nodeContainer);
					}
				}
				else{
					for(GraphicalModelElement gme:gec.getTypes() ){
						if(gme instanceof Node || gme instanceof NodeContainer) {
							validNodes.add(gme);
						}											
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
	
	public static boolean isCustomeHook(mgl.ModelElement modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("postCreate")){
				return true;
			}
		}
		if(modelElement instanceof Node){
			if(((Node)modelElement).getExtends() != null){
				return isCustomeHook(((Node)modelElement).getExtends());
			}
		}
		if(modelElement instanceof NodeContainer){
			if(((NodeContainer)modelElement).getExtends() != null){
				return isCustomeHook(((NodeContainer)modelElement).getExtends());
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
	
	public static boolean isCustomeHook(mgl.GraphModel modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("postCreate")){
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
//		modelElements.addAll(modelElement.getNodeContainers());
		modelElements.addAll(modelElement.getNodes());
		for (mgl.ModelElement modelElement2 : modelElements) {
			if(isCustomeAction(modelElement2)) {
				return true;
			}
		}
		return false;
	}

	
	public static boolean isCustomeHookAvailable(mgl.GraphModel modelElement)
	{
		if(ModelParser.isCustomeHook(modelElement)) {
			return true;
		}
		List<mgl.ModelElement> modelElements = new ArrayList<mgl.ModelElement>();
		modelElements.addAll(modelElement.getEdges());
//		modelElements.addAll(modelElement.getNodeContainers());
		modelElements.addAll(modelElement.getNodes());
		for (mgl.ModelElement modelElement2 : modelElements) {
			if(isCustomeHook(modelElement2)) {
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
					String[] parts = value.split("\\.");
					if(parts.length == 0){
						return value;
					}
					return parts[parts.length-1];
				}
			}
		}
		return null;
	}
	
	public static String getCustomeHookName(mgl.ModelElement modelElement)
	{
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("postCreate")){
				String prefix = "postCreate";
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split("\\.");
					if(parts.length == 0){
						return prefix+value;
					}
					return prefix+parts[parts.length-1];
				}
			}
		}
		if(modelElement instanceof Node){
			if(((Node)modelElement).getExtends() != null){
				return getCustomeHookName(((Node)modelElement).getExtends());
			}
		}
		if(modelElement instanceof NodeContainer){
			if(((NodeContainer)modelElement).getExtends() != null){
				return getCustomeHookName(((NodeContainer)modelElement).getExtends());
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
					String[] parts = value.split("\\.");
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
	
	public static ArrayList<String> getCustomHookNames(mgl.ModelElement modelElement){
		ArrayList<String> customeActionNames = new ArrayList<String>();
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("postCreate")){
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split("\\.");
					if(parts.length == 0){
						customeActionNames.add("PostCreate"+value);
					}
					else {
						customeActionNames.add("PostCreate"+parts[parts.length-1]);						
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
					String[] parts = value.split("\\.");
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
	
	public static ArrayList<String> getCustomHookNames(mgl.GraphModel modelElement){
		ArrayList<String> customeActionNames = new ArrayList<String>();
		for(mgl.Annotation annotation:modelElement.getAnnotations()) {
			if(annotation.getName().equals("postCreate")){
				if(annotation.getValue().size()>=1){
					String value = annotation.getValue().get(0);
					String[] parts = value.split("\\.");
					if(parts.length == 0){
						customeActionNames.add("PostCreate"+value);
					}
					else {
						customeActionNames.add("PostCreate"+parts[parts.length-1]);						
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
	
	public static String getCustomHookName(mgl.Annotation annotation){
		if(annotation.getName().equals("postCreate")){
			String prefix = "PostCreate";
			if(annotation.getValue().size()>=1){
				String value = annotation.getValue().get(0);
				String[] parts = value.split("\\.");
				if(parts.length == 0){
					return prefix+value;
				}
				return prefix+parts[parts.length-1];
			}
		}
		return null;
	}
	
	public static String getFileName(String path){
		Path p = Paths.get(path);
		return p.getFileName().toString();
	}
	
	public static String getCustomActionName(String anno){
		String[] parts = anno.split("\\.");
		if(parts.length == 0){
			return anno;
		}
		return parts[parts.length-1];
	}
	
	public static String getCustomHookName(String anno){
		String prefix = "PostCreate";
		String[] parts = anno.split("\\.");
		if(parts.length == 0){
			return anno;
		}
		return prefix+parts[parts.length-1];
	}
	
	public static boolean isUserDefinedType(mgl.Attribute attribute,List<mgl.Type> types)
	{
		for (mgl.Type type : types) {
			if(type.getName().equals(attribute.getType()) && type instanceof UserDefinedType){
				return true;
			}
		}
		return false;
	}
	
	public static List<mgl.Attribute> getNoUserDefinedAttributtes(List<mgl.Attribute> attributes,List<mgl.Type> types)
	{
		List<Attribute> noUseDefinedAttributes = new LinkedList<Attribute>();
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
//					modelElements.addAll(graphModel.getNodeContainers());
					modelElements.addAll(graphModel.getNodes());
					modelElements.addAll(graphModel.getEdges());
					boolean selfReferencing = false;
					for(ModelElement modelElement:modelElements){
						
						// TODO: Check if this workes - unchecked cast to ReferencedEClass
						if(modelElement.getName().equals(((ReferencedEClass)node.getPrimeReference()).getType().getName())){
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
			// TODO: Check if this workes - unchecked cast to ReferencedEClass
			return ((ReferencedEClass)node.getPrimeReference()).getType().getName();
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
//		modelElements.addAll(graphmodel.getNodeContainers());
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
	
	public static Appearance getShapeAppearnce(AbstractShape shape)
	{
		Appearance appearance;
		//Get the shape appearance
		appearance = shape.getInlineAppearance();
		if(appearance == null) {
			appearance = shape.getReferencedAppearance();
		}
		//appearance.getParent();
		return ModelParser.getInheritedAppearance(appearance);
		
	}
	
	public static Map<Text,Integer> getTextShapes(AbstractShape shape,int i){
		Map<Text,Integer> texts = new HashMap<Text,Integer>();
		if(shape instanceof Text){
			texts.put((Text)shape,i);
			return texts;
		}
		if(shape instanceof ContainerShape){
			
			for(AbstractShape abstractShape:((ContainerShape)shape).getChildren()){
				i++;
				texts.putAll(getTextShapes(abstractShape,i));
			}
		}
		return texts;
		
	}
	
	public static ArrayList<String> getStyleAnnotationValues(ModelElement modelElement){
		ArrayList<String> labels = new ArrayList<String>();
		for(Annotation annotation:modelElement.getAnnotations()){
			if(annotation.getName().equals("style")){
				labels.addAll(annotation.getValue().subList(1,annotation.getValue().size()));
			}
		}
		return labels;
	}
	

}
