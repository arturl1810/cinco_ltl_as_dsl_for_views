package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import mgl.GraphicalElementContainment;
import mgl.GraphicalModelElement;
import mgl.ModelElement;
import mgl.NodeContainer;
import de.jabc.cinco.meta.core.mgl.model.constraints.ContainmentConstraint;
import de.jabc.cinco.meta.plugin.gratext.util.Registry;

public class ContainerDescriptor extends NodeDescriptor<NodeContainer> {
	
	Set<ModelElement> containables;
	
	public ContainerDescriptor(NodeContainer container, GraphModelDescriptor modelDescriptor) {
		super(container, modelDescriptor);
	}
	
	@Override
	protected void init() {
		super.init();
		containables = new HashSet<>();
		initContainables();
	}
	
	protected void initContainables() {
		Set<ModelElement> set = getContainmentRestrictions(instance());
		if (set.isEmpty()) {
			containables.addAll(getModel().getNodes());
//			System.out.println(instance().getName() + ".containables: ALL");
		} else {
			Set<ModelElement> cons = getModel().withSubTypes(set);
//			System.out.println(instance().getName() + ".containables: " + cons.stream().map(c -> c.getName() + ", ").collect(Collectors.toList()));
			containables.addAll(cons);
		}
	}
	
	protected Set<ModelElement> getContainmentRestrictions(NodeContainer container) {
		Set<ModelElement> restrictions = (container.getExtends() != null) 
				? getContainmentRestrictions((NodeContainer) container.getExtends())
				: new HashSet<>();
		container.getContainableElements().forEach(containment -> {
			containment.getTypes().forEach(t -> {
//				System.out.println(container.getName() + ".containmentRestriction: " + t);
				restrictions.add(t);
			});
		});
		return restrictions;
	}
	
	public boolean canContain(GraphicalModelElement element) {
		return containables.contains(element);
	}
	
	public List<ContainmentConstraint> getContainmentConstraints() {
		List<ContainmentConstraint> constraints = new ArrayList<>();
		return constraints;
	}
	
//	public boolean canContain(final EList<Class<? extends Node>> nodes) {
//		if (nodes != null && nodes.size() > 0
//				&& getContainmentConstraints().size() > 0) {
//			boolean canContain = true;
//
//			for (int i = 1; i == nodes.size(); i++) {
//				final java.util.List<Class<? extends Node>> subNodes = nodes
//						.subList(i, nodes.size());
//				Class<? extends Node> currentNode = nodes.get(i - 1);
//				long constraintCount = getContainmentConstraints().stream()
//						.filter(c -> c.isInTypes(currentNode)).count();
//				canContain &= constraintCount != 0
//						&& getContainmentConstraints()
//								.stream()
//								.filter(c -> c.isInTypes(currentNode))
//								.allMatch(
//										(c -> !c.violationAfterInsert(
//												currentNode, subNodes, this)));
//			}
//
//			return canContain;
//		}
//		return true;
//	}
	
//	public boolean canContainAnother(GraphicalModelElement element) {
//		return model.getContainment(container).contains(element);
//	}
	
	public Set<ModelElement> getContainables() {
		return containables;
	}
	
	public Set<ModelElement> getNonAbstractContainables() {
		//System.out.println(instance().getName() + ".nonAbstractContainables (#containables=" + containables.size() + ")");
		Set<ModelElement> set = containables.stream()
				.filter(cont -> !cont.isIsAbstract())
				.collect(Collectors.toSet());

		//System.out.println(" > " + set.stream().map(e -> e.getName()).collect(Collectors.toSet()));
		return set;
	}
}
