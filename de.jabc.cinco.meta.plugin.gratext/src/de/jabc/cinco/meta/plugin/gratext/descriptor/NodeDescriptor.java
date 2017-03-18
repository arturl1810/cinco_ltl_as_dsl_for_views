package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import mgl.Edge;
import mgl.GraphicalModelElement;
import mgl.IncomingEdgeElementConnection;
import mgl.ModelElement;
import mgl.Node;
import mgl.OutgoingEdgeElementConnection;
import mgl.ReferencedType;

public class NodeDescriptor<T extends Node> extends ModelElementDescriptor<T> {
	
	Set<Edge> incomingEdges;
	Set<Edge> outgoingEdges;
	
	public NodeDescriptor(T node, GraphModelDescriptor model) {
		super(node, model);
	}
	
	@Override
	protected void init() {
		super.init();
		incomingEdges = new HashSet<>();
		outgoingEdges = new HashSet<>();
		initIncomingEdgeConnections(instance());
		initOutgoingEdgeConnections(instance());
	}
	
	@Override
	protected void initAttributes(ModelElement element) {
		super.initAttributes(element);
		if (((Node)element).getExtends() != null) {
			initAttributes(((Node)element).getExtends());
		}
	}
	
	protected void initIncomingEdgeConnections(Node node) {
		List<IncomingEdgeElementConnection> connections = node.getIncomingEdgeConnections();
		if (connections != null) connections.forEach(connection -> {
			ArrayList<ModelElement> edges = new ArrayList<>(connection.getConnectingEdges());
			if (edges.isEmpty())
				edges = new ArrayList<>(getModel().getEdges());
			getModel().withSubTypes(edges).forEach(edge -> {
				incomingEdges.add((Edge) edge);
				getModel().withSubTypes(node).forEach(n -> getModel().resp((Edge) edge).addTargetNode((Node)n));
			});
		});
		if (node.getExtends() != null) {
			initIncomingEdgeConnections(node.getExtends());
		}
	}
	
	protected void initOutgoingEdgeConnections(Node node) {
		List<OutgoingEdgeElementConnection> connections = node.getOutgoingEdgeConnections();
		if (connections != null) connections.forEach(connection -> {
			ArrayList<ModelElement> edges = new ArrayList<>(connection.getConnectingEdges());
			if (edges.isEmpty())
				edges = new ArrayList<>(getModel().getEdges());
			getModel().withSubTypes(edges).forEach(obj -> {
				outgoingEdges.add((Edge)obj);
				getModel().withSubTypes(node).forEach(n -> getModel().resp((Edge)obj).addSourceNode((Node)n));
			});
		});
		if (node.getExtends() != null)
			initOutgoingEdgeConnections(node.getExtends());
	}
	
	public boolean isEdgeSource() {
		return !outgoingEdges.isEmpty();
	}
	
	public boolean isEdgeTarget() {
		return !incomingEdges.isEmpty();
	}
	
	public Set<Edge> getIncomingEdges() {
		return incomingEdges;
	}
	
	public Set<GraphicalModelElement> getNonAbstractIncomingEdges() {
		return incomingEdges.stream()
				.filter(edge -> !edge.isIsAbstract())
				.collect(Collectors.toSet());
	}
	
	public Set<Edge> getOutgoingEdges() {
		return outgoingEdges;
	}
	
	public Set<GraphicalModelElement> getNonAbstractOutgoingEdges() {
		return outgoingEdges.stream()
				.filter(edge -> !edge.isIsAbstract())
				.collect(Collectors.toSet());
	}
	
	@SuppressWarnings("unchecked")
	public T getSuperType() {
		return (T) instance().getExtends();
	}
	
	@Override
	public ReferencedType getPrimeReference() {
		ReferencedType prime = instance().getPrimeReference();
		if (prime == null) {
			T superType = getSuperType();
			if (superType != null) {
				return getModel().resp(superType).getPrimeReference();
			}
		}
		return prime;
	}
}
