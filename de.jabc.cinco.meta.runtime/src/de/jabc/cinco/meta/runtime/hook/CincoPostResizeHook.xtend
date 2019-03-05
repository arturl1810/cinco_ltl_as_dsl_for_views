package de.jabc.cinco.meta.runtime.hook

import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass

abstract class CincoPostResizeHook<T extends EObject> extends CincoRuntimeBaseClass {
	/** 
	 * This method is called after resizing a graphical element on the canvas
	 * @param cModelElement The modelElement which is linked to the resized graphical representation
	 * @param direction An integer indicating the resize direction. @see {@link IResizeShapeContext}. 
	 * Possible values are:{@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_EAST}, {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_NORTH}, ...{@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_NORTH_WEST}, ... {@link org.eclipse.graphiti.features.context.IResizeShapeContext.DIRECTION_UNSPECIFIED}
	 * @param width The new width
	 * @param height The new height
	 */
	def abstract void postResize(T cModelElement, int direction, int width, int height)

}
