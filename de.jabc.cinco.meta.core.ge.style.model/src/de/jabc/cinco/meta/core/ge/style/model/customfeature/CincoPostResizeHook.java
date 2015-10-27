package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import graphicalgraphmodel.CModelElement;

public abstract class CincoPostResizeHook<T extends CModelElement> {

	/**
	 * This method is called after resizing a graphical element on the canvas
	 * 
	 * @param cModelElement The modelElement which is linked to the resized graphical representation
	 * @param direction An integer indicating the resize direction. @see {@link org.eclipse.graphiti.features.context.IResizeShapeContext}. 
	 * Possible values are:
	 * {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_EAST}, 
	 * {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_NORTH}, ...
	 * {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_NORTH_WEST}, ... 
	 * {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_UNSPECIFIED}
	 * @param width The new width
	 * @param height The new height
	 */
	public abstract void postResize(T cModelElement, int direction, int width, int height);
	
}
