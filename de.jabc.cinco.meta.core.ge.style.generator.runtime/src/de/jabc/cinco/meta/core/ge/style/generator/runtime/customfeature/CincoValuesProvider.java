package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature;

import java.util.Map;

import graphmodel.ModelElement;


public abstract class CincoValuesProvider <E extends ModelElement, A extends ModelElement> {

	public abstract Map<A, String> getPossibleValues(E modelElement);
	
}
