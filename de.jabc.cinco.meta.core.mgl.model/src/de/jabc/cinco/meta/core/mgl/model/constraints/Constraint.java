package de.jabc.cinco.meta.core.mgl.model.constraints;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.EList;

import graphmodel.Node;

public class Constraint {
	
	private int lowerBound;
	
	private float upperBound;
	private List<Class<?>> types;

	public Constraint(int lowerBound, int upperBound,Class<?>... types){
		
		this.types = Arrays.asList(types);
		this.lowerBound = lowerBound;
		this.upperBound = upperBound!=-1?upperBound:Float.POSITIVE_INFINITY;
		
	}
	/**
	 * Checks Upper bound
	 * @return <code>true</code> if sum of elements in container of type included in constraint abides the upper bound, else <code>false</code>
	 */
	public boolean checkUpperBound(graphmodel.ModelElementContainer container){
		
		int sum = sumElements(container);
		return sum <= this.upperBound;
		
		
	}
	/**
	 * Checks Lower bound
	 * @return <code>true</code> if sum of elements in container of type included in constraint abides the lower bound, else <code>false</code>
	 */
	public boolean checkLowerBound(graphmodel.ModelElementContainer container ){
		int sum = sumElements(container);
		return sum >= this.lowerBound;
	}
	
	public boolean checkConstraint(graphmodel.ModelElementContainer container){
		int sum = sumElements(container);
		return sum >= this.lowerBound && sum <= this.upperBound;
		
	}
	
	/**
	 * 
	 * @param container : ModelElementContainer that contains model elements
	 * @return number of elements in container that are included in constraint 
	 */
	public int sumElements(graphmodel.ModelElementContainer container){
		EList<Node> elements = container.getAllNodes();
		return elements.stream().filter(e -> types.stream().anyMatch(nt -> nt.isInstance(e))).collect(Collectors.toList()).size();
	}
	
	
	// Getter
	
	public int getLowerBound() {
		return lowerBound;
	}
	public float getUpperBound() {
		return upperBound;
	}
	public List<Class<?>> getTypes() {
		return types;
	}
	
}
