package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import de.jabc.cinco.meta.core.mgl.model.constraints.ContainmentConstraint;
import mgl.GraphicalModelElement;
import mgl.ModelElement;
import mgl.NodeContainer;

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
		} else {
			Set<ModelElement> cons = getModel().withSubTypes(set);
			containables.addAll(cons);
		}
	}
	
	protected Set<ModelElement> getContainmentRestrictions(NodeContainer container) {
		Set<ModelElement> restrictions = (container.getExtends() != null && container.getExtends() instanceof NodeContainer) 
				? getContainmentRestrictions((NodeContainer) container.getExtends())
				: new HashSet<>();
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
	
	public List<ContainmentConstraint> getContainmentConstraints() {
		List<ContainmentConstraint> constraints = new ArrayList<>();
		return constraints;
	}
	
	public Set<ModelElement> getContainables() {
		return containables;
	}
	
	public Set<ModelElement> getNonAbstractContainables() {
		return containables.stream()
				.filter(cont -> !cont.isIsAbstract())
				.collect(Collectors.toSet());
	}
}
