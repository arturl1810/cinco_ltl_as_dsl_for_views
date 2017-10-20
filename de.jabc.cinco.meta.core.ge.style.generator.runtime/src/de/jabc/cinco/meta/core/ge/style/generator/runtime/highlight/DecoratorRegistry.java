package de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight;


import java.util.Arrays;
import java.util.Stack;
import java.util.function.Function;

import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IDecorator;

import de.jabc.cinco.meta.core.utils.registry.InstanceRegistry;
import de.jabc.cinco.meta.core.utils.registry.NonEmptyRegistry;

public class DecoratorRegistry extends NonEmptyRegistry<PictogramElement, Stack<IDecorator>>{
	
	public static InstanceRegistry<DecoratorRegistry> INSTANCE = new InstanceRegistry<>(() -> new DecoratorRegistry(pe -> new Stack<>()));
	public static DecoratorRegistry getInstance() { return INSTANCE.get(); }
	
	// generated
	private static final long serialVersionUID = -3975578375529129595L;

	
	public DecoratorRegistry(Function<PictogramElement, Stack<IDecorator>> valueSupplier) {
		super(valueSupplier);
	}
	
	/**
	 * Convenience method that adds all registered decorators for a specific PictogramElement
	 * to an existing array of decorators.
	 * 
	 * @param pe  The PictogramElement.
	 * @param decs  An array of decorators. If {@code null} or empty, a new array is created and returned.
	 * @return  An array that results from adding the respective decorators to the original array.
	 */
	public static IDecorator[] complementDecorators(PictogramElement pe, IDecorator[] decs) {
		Stack<IDecorator> stack = INSTANCE.get().get(pe);
		if (decs != null) {
			if (!stack.isEmpty()) {
				IDecorator[] ret = Arrays.copyOf(decs, decs.length + 1);
				ret[ret.length - 1] = stack.lastElement();
				return ret;
			} else {
				return decs;
			}
		} else if (!stack.isEmpty()) {
			return new IDecorator[] { stack.lastElement() };
		}
		return new IDecorator[0];
	}
}

