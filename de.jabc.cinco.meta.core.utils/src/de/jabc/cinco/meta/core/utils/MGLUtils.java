package de.jabc.cinco.meta.core.utils;

import java.net.URL;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;

import style.Image;
import style.Styles;
import mgl.Annotation;
import mgl.ContainingElement;
import mgl.Edge;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.IncomingEdgeElementConnection;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.OutgoingEdgeElementConnection;
import mgl.Type;

public class MGLUtils {

	public static Set<ContainingElement> getNodeContainers(GraphModel gm) {
		Set<ContainingElement> nodeContainers = gm.getNodes().stream().
				filter(n -> (n instanceof ContainingElement)).
				map(nc -> ContainingElement.class.cast(nc)).
				collect(Collectors.toSet());
		nodeContainers.add(gm);
		return nodeContainers;
	}
	
	public static Set<Node> getPossibleTargets(Edge ce) {
		HashSet<Node> targets = new HashSet<>();
		
		ce.getEdgeElementConnections().stream().filter(eec -> 
			eec instanceof IncomingEdgeElementConnection).forEach(ieec -> 
			targets.add((mgl.Node) ieec.eContainer()
		));
		
		return targets;
	}
	
	public static Set<Node> getPossibleSources(Edge ce) {
		HashSet<Node> sources = new HashSet<>();
		
		ce.getEdgeElementConnections().stream().filter(eec -> 
			eec instanceof OutgoingEdgeElementConnection).forEach(oeec -> 
			sources.add((mgl.Node) oeec.eContainer()
		));
		
		return sources;
	}

	public static Set<Edge> getIncomingConnectingEdges(Node n) {
		HashSet<Edge> connectingEdges = new HashSet<Edge>();
		n.getIncomingEdgeConnections().forEach(ieec ->
		connectingEdges.addAll(ieec.getConnectingEdges()));
		
		return connectingEdges;
	}
	
	public static Set<Edge> getOutgoingConnectingEdges(Node n) {
		HashSet<Edge> connectingEdges = new HashSet<Edge>();
		n.getOutgoingEdgeConnections().forEach(oeec ->
			connectingEdges.addAll(oeec.getConnectingEdges()));
		return connectingEdges;
	}
	
	public static Set<Node> getContainableNodes(ContainingElement ce) {
		GraphModel gm;
		if (ce instanceof NodeContainer)
			gm = ((NodeContainer) ce).getGraphModel();
		else gm = (GraphModel) ce;
		
		Set<Node> nodes = gm.getNodes().stream().
			filter(n -> isContained(ce, n)).
			collect(Collectors.toSet());
		return nodes;
	}
	
	public static Set<ContainingElement> getPossibleContainers(Node n) {
		GraphModel gm = getRootElement(n);
		
		Set<ContainingElement> containers = 
				getNodeContainers(gm).stream().
				filter(nc -> getContainableNodes(nc).contains(n)).
				collect(Collectors.toSet());
		
		return containers;
	}
	
	private static GraphModel getRootElement(mgl.Type t) {
		if (t instanceof GraphModel)
			return (GraphModel) t;
		else return getRootElement((Type) t.eContainer());
	}

	private static boolean isContained(ContainingElement ce, Node n) {
		if (ce instanceof GraphModel && ce.getContainableElements().isEmpty())
			return true;
		Set<GraphicalElementContainment> containments = ce.getContainableElements().stream().
		filter(ec -> (ec.getTypes().size() == 0 || ec.getTypes().contains(n)) && 
				(ec.getUpperBound() > 0 || ec.getUpperBound() == -1)).
		collect(Collectors.toSet());
		
		return containments.size() > 0;
	}
	
	/** This methods retrieves all images used in the MGL and Style specification.
	 * @param gm The {@link GraphModel} which should be searched for images
	 * @return HashMap containing the defined path in the meta description and the URL of the 
	 * actual image file.
	 */
	public static HashMap<String, URL> getAllImages(GraphModel gm) {
		HashMap<String, URL> paths = new HashMap<>();
		URL url = null;
		for (TreeIterator<EObject> it = gm.eResource().getAllContents(); it.hasNext(); ){
			EObject o = it.next();
			if (o instanceof Annotation) {
				Annotation a  = (Annotation) o;
				if ("icon".equals(a.getName())) {
					if (a.getValue().size() == 1 && PathValidator.isRelativePath(o,a.getValue().get(0))) {
						url = PathValidator.getURLForString(o, a.getValue().get(0));
						paths.put(a.getValue().get(0), url);
					}
					else if (a.getValue().size() > 1 && PathValidator.isRelativePath(o,a.getValue().get(1))){
							url = PathValidator.getURLForString(o, a.getValue().get(1));
							paths.put(a.getValue().get(1), url);
					}
					
				}
			}
			if (o instanceof GraphModel) {
				String iconPath = ((GraphModel) o).getIconPath();
				if (iconPath != null && !iconPath.isEmpty())
					paths.put(iconPath, PathValidator.getURLForString(gm, iconPath));
			}
		}
		
		Styles styles = CincoUtils.getStyles(gm);
		for (TreeIterator<EObject> it = styles.eResource().getAllContents(); it.hasNext();){
			EObject o = it.next();
			if (o instanceof Image) {
				Image img  = (Image) o;
				String path = img.getPath();
				if (PathValidator.isRelativePath(img, path)) {
					url = PathValidator.getURLForString(img, path);
					paths.put(path, url);
				}
			}
		}
		return paths;
	}
}
