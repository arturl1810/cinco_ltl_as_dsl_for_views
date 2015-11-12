package de.jabc.cinco.meta.plugin.gratext.descriptor;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import mgl.Attribute;
import mgl.ModelElement;

public class ModelElementDescriptor<T extends ModelElement> {
	
	private T element;
	private GraphModelDescriptor model;
	
	private List<Attribute> attributes;
	
	public ModelElementDescriptor(T element, GraphModelDescriptor modelDescriptor) {
		this.element = element;
		this.model = modelDescriptor;
		init();
	}
	
	protected void init() {
		attributes = new ArrayList<>();
		initAttributes(instance());
	}
	
	protected void initAttributes(ModelElement element) {
		if (element.getAttributes() != null)
			addAttributes(element.getAttributes());
	}
	
	public T instance() {
		return element;
	}
	
	public GraphModelDescriptor getModel() {
		return model;
	}
	
	public void addAttribute(Attribute attr) {
		attributes.add(attr);
	}
	
	public void addAttributes(List<Attribute> attrs) {
		attributes.addAll(attrs);
	}
	
	public List<Attribute> getAttributes() {
		return attributes;
	}
	
	@SuppressWarnings("unchecked")
	public Set<T> getSubTypes() {
		return (Set<T>) model.getSubTypes(instance());
	}
	
	public Set<T> getNonAbstractSubTypes() {
		return getSubTypes().stream()
				.filter(element -> !element.isIsAbstract())
				.collect(Collectors.toSet());
	}
	
	protected Set<ModelElement> withSubTypes(Collection<ModelElement> elements) {
		return elements.stream()
			.map(this::withSubTypes)
			.flatMap(Set::stream)
			.collect(Collectors.toSet());
	}
	
	protected Set<ModelElement> withSubTypes(ModelElement element) {
		Set<ModelElement> set = new HashSet<>(getSubTypes());
		set.add(element);
		return set;
	}
	
	public T getSuperType() {
		return null;
	}
	
}
