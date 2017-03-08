package de.jabc.cinco.meta.core.utils

import java.net.URL
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Set
import java.util.stream.Collectors
import mgl.Annotation
import mgl.Attribute
import mgl.ComplexAttribute
import mgl.ContainingElement
import mgl.Edge
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.IncomingEdgeElementConnection
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.OutgoingEdgeElementConnection
import mgl.PrimitiveAttribute
import mgl.Type
import org.eclipse.emf.common.util.TreeIterator
import org.eclipse.emf.ecore.EObject
import style.Image
import style.Styles
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils

class MGLUtil {

	static extension GeneratorUtils = new GeneratorUtils

	def static Set<ContainingElement> getNodeContainers(GraphModel gm) {
		var Set<ContainingElement> nodeContainers = gm.getNodes().stream().filter([n|(n instanceof ContainingElement)]).
			map([nc|typeof(ContainingElement).cast(nc)]).collect(Collectors::toSet())
		nodeContainers.add(gm)
		return nodeContainers
	}

	def static Set<Node> getPossibleTargets(Edge ce) {
		val HashSet<Node> targets = new HashSet()
		ce.getEdgeElementConnections().stream().filter([eec|eec instanceof IncomingEdgeElementConnection]).forEach([ieec |
			targets.add((ieec.eContainer() as Node))
		])
		return targets
	}

	def static Set<Node> getPossibleSuccessors(Node n) {
		var Set<Node> possSucc = new HashSet<Node>()
		var Set<Edge> outs = getOutgoingConnectingEdges(n)
		for (Edge e : outs) {
			possSucc.addAll(getPossibleTargets(e))
		}
		return possSucc
	}

	def static Set<Node> getPossiblePredecessors(Node n) {
		var Set<Node> possPreds = new HashSet<Node>()
		var Set<Edge> outs = getIncomingConnectingEdges(n)
		for (Edge e : outs) {
			possPreds.addAll(getPossibleSources(e))
		}
		return possPreds
	}

	def static Set<Node> getPossibleSources(Edge ce) {
		val HashSet<Node> sources = new HashSet()
		ce.getEdgeElementConnections().stream().filter([eec|eec instanceof OutgoingEdgeElementConnection]).forEach([oeec |
			sources.add((oeec.eContainer() as Node))
		])
		return sources
	}

	def static Set<Edge> getIncomingConnectingEdges(Node n) {
		val HashSet<Edge> connectingEdges = new HashSet<Edge>()
		n.getIncomingEdgeConnections().forEach([ieec|connectingEdges.addAll(ieec.getConnectingEdges())])
		return connectingEdges
	}

	def static Set<Edge> getOutgoingConnectingEdges(Node n) {
		val HashSet<Edge> connectingEdges = new HashSet<Edge>()
		n.getOutgoingEdgeConnections().forEach([oeec|connectingEdges.addAll(oeec.getConnectingEdges())])
		return connectingEdges
	}

	def static Set<Node> getContainableNodes(ContainingElement ce) {
		var GraphModel gm
		if(ce instanceof NodeContainer) gm = ((ce as NodeContainer)).getGraphModel() else gm = ce as GraphModel
		var Set<Node> nodes = gm.getNodes().stream().filter([n|isContained(ce, n)]).collect(Collectors::toSet())
		return nodes
	}

	def static Set<ContainingElement> getPossibleContainers(Node n) {
		var GraphModel gm = getRootElement(n)
		var Set<ContainingElement> containers = getNodeContainers(gm).stream().filter([nc |
			getContainableNodes(nc).contains(n)
		]).collect(Collectors::toSet())
		return containers
	}

	def private static GraphModel getRootElement(Type t) {
		if(t instanceof GraphModel) return (t as GraphModel) else return getRootElement((t.eContainer() as Type))
	}

	def private static boolean isContained(ContainingElement ce, Node n) {
		if(ce instanceof GraphModel && ce.getContainableElements().isEmpty()) return true
		var Set<GraphicalElementContainment> containments = ce.getContainableElements().stream().filter([ec |
			(ec.getTypes().size() === 0 || ec.getTypes().contains(n)) &&
				(ec.getUpperBound() > 0 || ec.getUpperBound() === -1)
		]).collect(Collectors::toSet())
		return containments.size() > 0
	}

	/** 
	 * This methods retrieves all images used in the MGL and Style specification.
	 * @param gm The {@link GraphModel} which should be searched for images
	 * @return HashMap containing the defined path in the meta description and the URL of the 
	 * actual image file.
	 */
	def static HashMap<String, URL> getAllImages(GraphModel gm) {
		var HashMap<String, URL> paths = new HashMap()
		var URL url = null
		for (var TreeIterator<EObject> it = gm.eResource().getAllContents(); it.hasNext();) {
			var EObject o = it.next()
			if (o instanceof Annotation) {
				var Annotation a = (o as Annotation)
				if ("icon".equals(a.getName())) {
					if (a.getValue().size() === 1 && PathValidator::isRelativePath(o, a.getValue().get(0))) {
						url = PathValidator::getURLForString(o, a.getValue().get(0))
						paths.put(a.getValue().get(0), url)
					} else if (a.getValue().size() > 1 && PathValidator::isRelativePath(o, a.getValue().get(1))) {
						url = PathValidator::getURLForString(o, a.getValue().get(1))
						paths.put(a.getValue().get(1), url)
					}
				}
			}
			if (o instanceof GraphModel) {
				var String iconPath = ((o as GraphModel)).getIconPath()
				if(iconPath !== null && !iconPath.isEmpty()) paths.put(iconPath,
					PathValidator::getURLForString(gm, iconPath))
			}
		}
		var Styles styles = CincoUtils::getStyles(gm)
		for (var TreeIterator<EObject> it = styles.eResource().getAllContents(); it.hasNext();) {
			var EObject o = it.next()
			if (o instanceof Image) {
				var Image img = (o as Image)
				var String path = img.getPath()
				if (PathValidator::isRelativePath(img, path)) {
					url = PathValidator::getURLForString(img, path)
					paths.put(path, url)
				}
			}
		}
		return paths
	}

	/** 
	 * This methods returns all annotation values of the given name annotated at the modelElement
	 * @param annotationName
	 * @param gm The model element for which the annotation should be searched 
	 * @return A list containing all annotation values with the given name
	 */
	def static List<String> getAllAnnotation(String annotationName, ModelElement me) {
		var List<String> values = me.getAnnotations().stream().filter([a|a.getName().equals(annotationName)]).map([a |
			a.getValue().get(0)
		]).collect(Collectors::toList())
		return values
	}
	
	def static getType(Attribute attr) {
	 	switch attr {
	 		ComplexAttribute : attr.type.name
	 		PrimitiveAttribute : attr.type.getName
	 	}
	 }
	 
	 def static getPostCreateHooks(GraphModel it) {
	 	modelElements.map[annotations.filter[name == "postCreate"]].map[postCreates].join("\n")
	 }
	 
	 private def static postCreates(Iterable<Annotation> it) {
	 	if (!empty) 
	 	'''
		private def postCreates(«(get(0).parent as ModelElement).fqBeanName» me) {
			«map[generatePostCreateCall].join("\n")»
		}'''
	 	else ""
	 }
	 
	 private def static generatePostCreateCall(Annotation it)
	 '''new «value.get(0)»().postCreate(me)''' 
	 
	 def static postCreate(Type it, String varname) {
	 	if (annotations.filter[name == "postCreate"].isEmpty) "" else '''«varname».postCreates'''
	 }
	 
}
