package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

import mgl.Attribute;
import mgl.Edge;
import mgl.Enumeration;
import mgl.GraphModel;
import mgl.GraphicalModelElement;
import mgl.ModelElement;
import mgl.Node;
import mgl.NodeContainer;
import mgl.UserDefinedType;
import de.jabc.cinco.meta.plugin.gratext.util.KeygenRegistry;
import de.jabc.cinco.meta.plugin.gratext.util.NonEmptyRegistry;


public class GraphModelDescriptor extends Descriptor<GraphModel> {
	
	
	private Set<ModelElement> containables = new HashSet<>();
	
	private NonEmptyRegistry<ModelElement, Set<String>> attributes = new NonEmptyRegistry<>((element) -> new HashSet<>());
	
	private NonEmptyRegistry<ModelElement, Set<ModelElement>> subTypes = new NonEmptyRegistry<>((element) -> new HashSet<>());
	
	private NonEmptyRegistry<ModelElement, ModelElementDescriptor<?>> contexts = new NonEmptyRegistry<>((element) -> {
		if (element instanceof Edge)
			return new EdgeDescriptor((Edge)element, this);
		if (element instanceof NodeContainer)
			return new ContainerDescriptor((NodeContainer)element, this);
		if (element instanceof Node)
			return new NodeDescriptor<Node>((Node)element, this);
		if (element instanceof UserDefinedType)
			return new UserDefinedTypeDescriptor((UserDefinedType)element, this);
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
		initModelElements();
		initAttributes();
		initContainables();
	}
	
	protected void initModelElements() {
		instance().getNodes().forEach(this::initTypeHierarchy);
		instance().getEdges().forEach(this::initTypeHierarchy);
		instance().getTypes().stream()
			.filter(UserDefinedType.class::isInstance)
			.map(UserDefinedType.class::cast)
			.forEach(this::initTypeHierarchy);
	}
	
	protected void initTypeHierarchy(ModelElement elem) {
		elements.add(elem);
		if (elem instanceof Node) {
			if (elem instanceof NodeContainer)
				containers.add((NodeContainer) elem);
			else nonContainers.add((Node) elem);
			initTypeHierarchy((Node) elem, x -> ((Node)x).getExtends());
		} else if (elem instanceof Edge) {
			initTypeHierarchy((Edge) elem, x -> ((Edge)x).getExtends());
		} else if (elem instanceof UserDefinedType) {
			initTypeHierarchy((UserDefinedType) elem, x -> ((UserDefinedType)x).getExtends());
		}
	}
	
	protected void initTypeHierarchy(ModelElement elem, Function<ModelElement, ModelElement> superTypeSupplier) {
		ModelElement ext = superTypeSupplier.apply(elem);
		while (ext != null) {
			subTypes.get(ext).add(elem);
			ext = superTypeSupplier.apply(ext);
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
		Set<ModelElement> set = getContainmentRestrictions(instance());
		if (set.isEmpty()) {
			//System.out.println(instance().getName() + ".containables: ALL");
			containables.addAll(getNodes());
		} else {
			Set<ModelElement> cons = withSubTypes(set);
			//System.out.println(instance().getName() + ".containables: " + cons);
			containables.addAll(cons);
		}
	}
	
	protected Set<ModelElement> getContainmentRestrictions(GraphModel container) {
		Set<ModelElement> restrictions = new HashSet<>();
		container.getContainableElements().forEach(containment -> {
			containment.getTypes().forEach(t -> {
				restrictions.add(t);
			});
		});
		return restrictions;
	}
	
	public boolean canContain(GraphicalModelElement element) {
		return containables.contains(element);
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
	
	public boolean containsEnumeration(String name) {
		return getEnumerations().stream()
				.filter(type -> type.getName().equals(name))
				.findAny().isPresent();
	}
	
	public boolean containsUserDefinedType(String name) {
		return getUserDefinedTypes().stream()
			.filter(type -> type.getName().equals(name))
			.findAny().isPresent();
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
	
	public List<UserDefinedType> getUserDefinedTypes() {
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
