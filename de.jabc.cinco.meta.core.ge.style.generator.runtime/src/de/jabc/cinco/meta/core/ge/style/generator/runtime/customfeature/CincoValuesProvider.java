package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature;

import java.util.Map;

import org.eclipse.emf.ecore.EObject;

import graphmodel.ModelElement;
import mgl.GraphModel;

/**
 * This class returns a map with possible "display" strings for an attribute of type <A>
 * @author kopetzki
 *
 * @param <E> The {@link ModelElement} type which contains the attribute
 * @param <A> The {@link ModelElement}'s attribute type
 */
public abstract class CincoValuesProvider <E extends ModelElement, A extends Object> {

	/**
	 * 
	 * @param modelElement The {@link ModelElement} containing the attribute
	 * @return The mapping from {@link mgl.Attribute} to its display value i.e. maps from attribute type to {@link String}
	 * */
	public abstract Map<A, String> getPossibleValues(E modelElement);
	
}
