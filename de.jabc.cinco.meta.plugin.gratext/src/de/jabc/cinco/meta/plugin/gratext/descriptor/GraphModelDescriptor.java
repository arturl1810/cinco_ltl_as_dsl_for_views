package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import mgl.Attribute;
import mgl.Edge;
import mgl.Enumeration;
import mgl.GraphModel;
import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.UserDefinedType;
import de.jabc.cinco.meta.plugin.gratext.util.KeygenRegistry;
import de.jabc.cinco.meta.plugin.gratext.util.NonEmptyRegistry;
import de.jabc.cinco.meta.plugin.gratext.util.Registry;


public class GraphModelDescriptor extends Descriptor<GraphModel> {
	
	
	private Set<ModelElement> containables = new HashSet<>();
	
	private Registry<GraphicalModelElement, GraphicalElementContainment> containments = new Registry<>();
	
	private NonEmptyRegistry<ModelElement, Set<String>> attributes = new NonEmptyRegistry<>((element) -> new HashSet<>());
	
	private NonEmptyRegistry<ModelElement, Set<ModelElement>> subTypes = new NonEmptyRegistry<>((element) -> new HashSet<>());
	
	private NonEmptyRegistry<ModelElement, ModelElementDescriptor<?>> contexts = new NonEmptyRegistry<>((element) -> {
		if (element instanceof Edge)
			return new EdgeDescriptor((Edge)element, this);
		if (element instanceof NodeContainer)
			return new ContainerDescriptor((NodeContainer)element, this);
		if (element instanceof Node)
			return new NodeDescriptor<Node>((Node)element, this);
		return new ModelElementDescriptor<ModelElement>(element, this);
	});
	
	private KeygenRegistry<String, ModelElement> elements = new KeygenRegistry<String, ModelElement>(element -> element.getName());
	
	private KeygenRegistry<String, NodeContainer> containers = new KeygenRegistry<String, NodeContainer>(node -> node.getName());
	
	private KeygenRegistry<String, Node> nonContainers = new KeygenRegistry<String, Node>(node -> node.getName());
	
	
	public GraphModelDescriptor(GraphModel model) {
		super(model);
		init(model);
	}
	
	protected void init(GraphModel model) {
		initTypes();
		initAttributes();
		initContainables();
	}
	
	protected void initTypes() {
		instance().getNodes().forEach(node -> {
			elements.add(node);
			if (node instanceof NodeContainer)
				containers.add((NodeContainer) node);
			else nonContainers.add(node);
			initType(node);
		});
		instance().getEdges().forEach(this::initType);
	}
	
	protected void initType(Edge edge) {
		Edge ext = edge.getExtends();
		while (ext != null) {
			System.out.println("Type " + edge.getName() + " > " + ext.getName());
			subTypes.get(ext).add(edge);
			ext = ext.getExtends();
		}
	}
	
	protected void initType(Node node) {
		Node ext = node.getExtends();
		while (ext != null) {
			System.out.println("Type " + node.getName() + " > " + ext.getName() + " prime = " + node.getPrimeReference());
			subTypes.get(ext).add(node);
			ext = ext.getExtends();
		}
	}
	
	protected void initAttributes() {
		elements.values().forEach(element -> {
			List<Attribute> attrs = element.getAttributes();
			if (attrs != null) {
				List<String> types = attrs.stream()
					.map(attr -> attr.getType())
					.collect(Collectors.toList());
				attributes.get(element).addAll(withSubTypesFromNames(types));
			}
		});
	}
	
	protected void initContainables() {
		Set<ModelElement> set = initContainables(instance());
		if (set.isEmpty()) {
			//System.out.println(instance().getName() + ".containables: ALL");
			containables.addAll(getNodes());
		} else {
			Set<ModelElement> cons = withSubTypes(set);
			//System.out.println(instance().getName() + ".containables: " + cons);
			containables.addAll(cons);
		}
	}
	
	protected Set<ModelElement> initContainables(GraphModel container) {
		Set<ModelElement> set = new HashSet<>();
		container.getContainableElements().forEach(containment -> {
			containment.getTypes().forEach(t -> {
				set.add(t);
				containments.put(t, containment);
			});
		});
		return set;
	}
	
	protected Set<ModelElement> getSubTypes(ModelElement element) {
		return subTypes.get(element);
	}
	
	protected Set<ModelElement> withSubTypes(Collection<ModelElement> elements) {
		return elements.stream()
			.map(this::withSubTypes)
			.flatMap(Set::stream)
			.collect(Collectors.toSet());
	}
	
	protected Set<ModelElement> withSubTypes(ModelElement element) {
		Set<ModelElement> set = (Set<ModelElement>) getSubTypes(element);
		set.add(element);
		return set;
	}
	
	protected Set<String> withSubTypesFromNames(Collection<String> types) {
		return types.stream()
				.map(this::withSubTypes)
				.flatMap(Set::stream)
				.collect(Collectors.toSet());
	}
	
	protected Set<String> withSubTypes(String type) {
		//System.out.println(" Type " + type);
		Set<String> retVal = new HashSet<>(Arrays.asList(new String[] {type}));
		ModelElement node = elements.get(type);
		if (node != null) {
			retVal.addAll(subTypes.get(node).stream()
				.map(t -> t.getName())
				.collect(Collectors.toSet()));
		}
		return retVal;
	}
	
	public boolean contains(String name) {
		return elements.containsKey(name);
	}
	
	public List<NodeContainer> getContainers() {
		return containers.values();
	}
	
	public List<NodeContainer> getNonAbstractContainers() {
		return containers.values().stream()
				.filter(node -> !node.isIsAbstract())
				.collect(Collectors.toList());
	}
	
	public List<Node> getNodes() {
		return instance().getNodes();
	}
	
	public List<Node> getNonAbstractNodes() {
		return instance().getNodes().stream()
				.filter(node -> !node.isIsAbstract())
				.collect(Collectors.toList());
	}
	
	public List<Node> getNonContainerNodes() {
		return nonContainers.values();
	}
	
	public List<Node> getNonAbstractNonContainerNodes() {
		return nonContainers.values().stream()
			.filter(node -> !node.isIsAbstract())
			.collect(Collectors.toList());
	}
	
	public List<Edge> getEdges() {
		return instance().getEdges();
	}
	
	public List<Edge> getNonAbstractEdges() {
		return instance().getEdges().stream()
			.filter(edge -> !edge.isIsAbstract())
			.collect(Collectors.toList());
	}
	
	public List<Enumeration> getEnumerations() {
		return instance().getTypes().stream()
				.filter(Enumeration.class::isInstance)
				.map(Enumeration.class::cast)
				.collect(Collectors.toList());
	}
	
	public List<UserDefinedType> getTypes() {
		return instance().getTypes().stream()
				.filter(UserDefinedType.class::isInstance)
				.filter(type -> !(type instanceof Enumeration))
				.map(UserDefinedType.class::cast)
				.collect(Collectors.toList());
	}
	
	public Set<ModelElement> getContainables() {
		return containables;
	}
	
	public Set<ModelElement> getNonAbstractContainables() {
		return containables.stream()
				.filter(cont -> !cont.isIsAbstract())
				.collect(Collectors.toSet());
	}
	
	@SuppressWarnings("unchecked")
	public ModelElementDescriptor<ModelElement> resp (ModelElement element) {
		return (ModelElementDescriptor<ModelElement>) contexts.get(element);
	}
	
	public ContainerDescriptor resp(NodeContainer container) {
		return (ContainerDescriptor) contexts.get(container);
	}
	
	@SuppressWarnings("unchecked")
	public NodeDescriptor<Node> resp(Node node) {
		return (NodeDescriptor<Node>) contexts.get(node);
	}
	
	public EdgeDescriptor resp(Edge edge) {
		return (EdgeDescriptor) contexts.get(edge);
	}
	
	
}
