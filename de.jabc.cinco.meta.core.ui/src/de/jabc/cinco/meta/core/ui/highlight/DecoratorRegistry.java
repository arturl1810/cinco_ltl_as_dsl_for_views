package de.jabc.cinco.meta.core.ui.highlight;


import java.util.Arrays;

import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;

public class DecoratorRegistry extends Registry<PictogramElement, IDecorator>{
	
	public static InstanceRegistry<DecoratorRegistry> INSTANCE = new InstanceRegistry<>(() -> new DecoratorRegistry());
	public static DecoratorRegistry getInstance() { return INSTANCE.get(); }
	
	// generated
	private static final long serialVersionUID = -3975578375529129595L;
	
	/**
	 * Convenience method that adds all registered decorators for a specific PictogramElement
	 * to an existing array of decorators.
	 * 
	 * @param pe  The PictogramElement.
	 * @param decs  An array of decorators. If {@code null} or empty, a new array is created and returned.
	 * @return  An array that results from adding the respective decorators to the original array.
	 */
	public static IDecorator[] complementDecorators(PictogramElement pe, IDecorator[] decs) {
		IDecorator dec = INSTANCE.get().get(pe);
		if (decs != null) {
			if (dec != null) {
				IDecorator[] ret = Arrays.copyOf(decs, decs.length + 1);
				ret[ret.length - 1] = dec;
				return ret;
			} else {
				return decs;
			}
		} else if (dec != null) {
			return new IDecorator[] { dec };
		}
		return new IDecorator[0];
	}
}

