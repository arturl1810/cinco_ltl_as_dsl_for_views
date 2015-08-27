package de.jabc.cinco.meta.core.mgl.model.constraints;

import graphmodel.Node;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.EList;

public class ContainmentConstraint {
	
	private int lowerBound;
	
	private int upperBound;
	private List<Class<?>> types;
	
	/**
	 * This class represents a constraint for element containments in the MGL.
	 * specified like this:<p>
	 * <pre>{types}[lowerBound,upperBound]</pre>
	 * </p>
	 * with:<p/>
	 * @param lowerBound - lower bound of constraint 
	 * @param upperBound - upper bound of constraint
	 * @param types - list of types of containable elements
	 */
	public ContainmentConstraint(int lowerBound, int upperBound,Class<?>... types){
		
		this.types = Arrays.asList(types);
		this.lowerBound = lowerBound;
		this.upperBound = upperBound!=-1?upperBound:Integer.MAX_VALUE;
		
	}
	/**
	 * Checks Upper bound
	 * @param container - {@link graphmodel.ModelElementContainer} to check.
	 * @return <b><code>true</code></b> if sum of elements in container of type included in constraint complies to the upper bound, else <b><code>false</code></b>
	 */
	public boolean checkUpperBound(graphmodel.ModelElementContainer container){
		
		int sum = sumMatchingElementsInContainer(container);
		return sum <= this.upperBound;
		
		
	}
	/**
	 * Checks Lower bound
	 * @param container - {@link graphmodel.ModelElementContainer} to check. 
	 * @return <b><code>true</code></b> if sum of elements in container of type included in constraint complies to the lower bound, else <b><code>false</code></b>
	 */
	public boolean checkLowerBound(graphmodel.ModelElementContainer container ){
		int sum = sumMatchingElementsInContainer(container);
		return sum >= this.lowerBound;
	}
	
	/**
	 * Checks if constraint is followed in given model element container
	 * @param container - {@link graphmodel.ModelElementContainer} to check.
	 * @return - <b><code>true</code></b> if constraint is followed, <b><code>false</code></b> else.
	 */
	public boolean checkConstraint(graphmodel.ModelElementContainer container){
		int sum = sumMatchingElementsInContainer(container);
		return sum >= this.lowerBound && sum <= this.upperBound;
		
	}
	
	/**
	 * When a node is inserted into container with other nodes, a check is required if other nodes will violate constraints.
	 * @param toInsert
	 * @param otherInsertedNodes
	 * @param container
	 * @return
	 */
	public boolean violationAfterInsert(Class<? extends Node> toInsert, List<Class<? extends Node>> otherInsertedNodes,graphmodel.ModelElementContainer container){
		
		return !isInTypes(toInsert)|| sumMatchingElementsInContainer(container)+sumElementsByType(otherInsertedNodes)>=upperBound;
	}
	
	public boolean violationAfterInsert(Node toInsert,graphmodel.ModelElementContainer container){
		return !isInstance(toInsert)|| sumMatchingElementsInContainer(container)>=upperBound;
	}
	
	public boolean violationAfterDelete(graphmodel.ModelElementContainer container,List<Class<? extends Node>> nodes){
		int suitableElementsSum = sumElementsByType(nodes);
		int containedElementsSum = sumMatchingElementsInContainer(container);
		return !(containedElementsSum-suitableElementsSum>=lowerBound);
	}
	
	/**
	 * Sums all Nodes in container that match this constraint's types.
	 * @param container : ModelElementContainer that contains model elements
	 * @return number of elements in container that are included in constraint 
	 */
	public int sumMatchingElementsInContainer(graphmodel.ModelElementContainer container){
		List<Class<? extends Node>> elements = container.getAllNodes().stream().collect(Collectors.mapping(e -> e.getClass(), Collectors.toList()));
		return sumElementsByType(elements);
	}
	
	/**
	 * Sums all Nodes in list that match this constraints types. 
	 * @param nodes - List of nodes
	 * @return sum of nodes, that match at least one of this constraints types.
	 */
	private int sumElementsByType(List<Class<? extends Node>> nodes) {
		return nodes.stream().filter(e -> isInTypes(e)).collect(Collectors.toList()).size();
	}
	
	
	private  boolean isInstance(Node e) {
		return types.stream().anyMatch(nt -> nt.isInstance(e));
		
	}
	
	private boolean isInTypes(Class<? extends Node> nodeClass){
		return types.contains(nodeClass);
		
	}
	// Getter
	
	public int getLowerBound() {
		return lowerBound;
	}
	public int getUpperBound() {
		return upperBound;
	}
	public List<Class<?>> getTypes() {
		return types;
	}
	
	public Set<Class<?>> getContainables(graphmodel.ModelElementContainer container){
		HashSet<Class<?>> containables = new HashSet<>();
		if(sumMatchingElementsInContainer(container) < upperBound)
			containables.addAll(getTypes());
		
		return containables;
	}
	
}
