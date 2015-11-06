package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import java.util.List;

import graphmodel.ModelElement;


public abstract class CincoValuesProvider <E extends ModelElement, A extends ModelElement> {

	public abstract List<A> getPossibleValues(E modelElement);
	
}
