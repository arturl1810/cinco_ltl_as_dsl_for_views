package de.jabc.cinco.meta.core.ge.style.model.appearance;

import mgl.ModelElement;
import style.Appearance;
import style.ContainerShape;
import style.EdgeStyle;
import style.NodeStyle;
import style.Shape;

public interface StyleAppearanceProvider<T> {
	
	final String CONNECTION = "connection";
	
	/**
	 * 
	 * @param modelElement The underlying {@link ModelElement} for the graphical representation in the editor 
	 * @param styleElementName The name of the {@link ContainerShape} or {@link Shape} of the corresponding 
	 * {@link NodeStyle} {@link EdgeStyle} respectively
	 * 
	 * @return The appearance for the graphical element named {@link styleElementName} depending 
	 * on the state of the underlying {@link ModelElement}
	 */
	public Appearance getAppearance(T modelElement, String styleElementName);
}
