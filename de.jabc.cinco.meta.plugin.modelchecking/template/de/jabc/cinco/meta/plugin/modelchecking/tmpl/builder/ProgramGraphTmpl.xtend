package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class ProgramGraphTmpl extends FileTemplate {

	override getTargetFileName() '''ProgramGraph.java'''
	
	override init(){
	}

	override template() '''
		package «package»;
		
		import java.util.ArrayList;
		import java.util.List;
		import java.util.stream.Collectors;
		
		public class ProgramGraph<D extends ModelCheckingAdditionalData> {
		
			ArrayList<GraphNode<D>> nodes;
			ArrayList<GraphEdge> edges;
			GraphNode<D> start;
		
			public ProgramGraph() {
				nodes = new ArrayList<>();
				edges = new ArrayList<>();
			}
		
			@SuppressWarnings("unchecked")
			public ProgramGraph(ProgramGraph graph) {
				nodes = (ArrayList<GraphNode<D>>) graph.nodes.clone();
				edges = (ArrayList<GraphEdge>) graph.edges.clone();
			}
		
			public ArrayList<GraphEdge> getEdges() {
				return edges;
			}
		
			public ArrayList<GraphNode<D>> getNodes() {
				return nodes;
			}
		
			public List<GraphNode<D>> getNodesWithModelId(String id) {
				List<GraphNode<D>> result = new ArrayList<>();
				for (GraphNode<D> n : nodes)
					if (n.getContentModelID().equals(id))
						result.add(n);
				return result;
			}
		
			public boolean addNode(GraphNode<D> node) {
				if (nodes.contains(node)) {
					return false;
				} else {
					nodes.add(node);
					return true;
				}
			}
		
			public boolean addEdge(GraphEdge edge) {
				if (edges.contains(edge)) {
					return false;
				} else {
					edges.add(edge);
					return true;
				}
			}
		
			public boolean removeEdge(GraphEdge edge) {
				if (edges.contains(edge)) {
					edges.remove(edge);
					return true;
				} else {
					return false;
				}
			}
		
			public boolean removeNode(GraphNode<D> node) {
				if (nodes.contains(node)) {
					nodes.remove(node);
					edges.removeAll(getAdjacentEdgesOf(node));
					return true;
				} else {
					return false;
				}
			}
		
			public List<GraphEdge> getAdjacentEdgesOf(GraphNode<D> node) {
				List<GraphEdge> result = getInEdgesOf(node);
				result.addAll(getOutEdgesOf(node));
				return result;
			}
		
			public List<GraphEdge> getInEdgesOf(GraphNode<D> node) {
				return edges.stream().filter(e -> e.getEnd().equals(node)).collect(Collectors.toList());
			}
		
			public List<GraphEdge> getOutEdgesOf(GraphNode<D> node) {
				return edges.stream().filter(e -> e.getStart().equals(node)).collect(Collectors.toList());
			}
		
			public List<GraphNode<D>> getInNeighboursOf(GraphNode<D> node) {
				return getEdges().stream().filter(edge -> edge.getEnd().equals(node)).map(edge -> edge.getStart())
						.collect(Collectors.toList());
			}
		
			public List<GraphNode<D>> getOutNeighboursOf(GraphNode<D> node) {
				return getEdges().stream().filter(edge -> edge.getStart().equals(node)).map(edge -> edge.getEnd())
						.collect(Collectors.toList());
			}
		
			public List<GraphEdge> getEdgesWith(GraphNode<D> begin, GraphNode<D> end) {
				return getEdges().stream().filter(edge -> edge.getStart().equals(begin) && edge.getEnd().equals(end))
						.collect(Collectors.toList());
			}
		
			public void setStart(GraphNode<D> startNode) {
				start = startNode;
			}
		
			public GraphNode<D> getStart() {
				return start;
			}
		
			@Override
			public String toString() {
				return "Start: " + start + "\nNodes: " + nodes + "\nEdges: " + edges;
			}
		}

		'''
}
