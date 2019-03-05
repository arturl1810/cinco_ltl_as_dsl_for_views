package de.jabc.cinco.meta.runtime.layout

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.Container
import graphmodel.ModelElementContainer
import graphmodel.Node
import java.util.List
import java.util.Map

import static de.jabc.cinco.meta.runtime.layout.LayoutConfiguration.*

class ListLayouter extends CincoRuntimeBaseClass {
	
	def void layout(ModelElementContainer it) {
		if (it instanceof Container) layout(layoutConfiguration)
	}

	def void layout(Container it) {
		layout(layoutConfiguration)
	}
	
	def void layout(Container it, Map<LayoutConfiguration,?> layoutConf) {
		layout(layoutConf ?: newHashMap, innerOrder ?: #[], ignoredChildren ?: #[])
	}
		
	def void layout(Container container, Map<LayoutConfiguration,?> layoutConf, List<? extends Class<? extends Node>> order, List<? extends Class<? extends Node>> ignored) {
		
		if (DISABLE_RESIZE.from(layoutConf) != 1) {
			container.applyWidthFrom(layoutConf)
		}
		
		val nodes =
			container.allNodes
				.filter[node | !ignored.exists[cls|!#[node].filter(cls).isEmpty]]
				.sortBy[y]
				.sortBy[node | order.indexOf(order.findFirst[isAssignableFrom(node.class)])]
				.toList
		
		if (nodes.isEmpty) {
			container.applyHeightFrom(layoutConf)
		} else {
			var requiredHeight = nodes.map[height].reduce[h1,h2 | h1 + h2 + PADDING_Y.from(layoutConf)]
			var paddingY = PADDING_Y.from(layoutConf)
			val maxHeight = container.getMaxHeight(layoutConf)
			if (maxHeight >= 0) {
				val availableHeight = maxHeight - PADDING_TOP.from(layoutConf) - PADDING_BOTTOM.from(layoutConf)
				if (requiredHeight > availableHeight) {
					println("Required height > available height: " + requiredHeight + " > " + availableHeight + " for " + nodes.size + " nodes")
					paddingY = paddingY - Math.round((requiredHeight - availableHeight) / (nodes.size - 1))
					println("=> amend padding-y for " + container.class.simpleName + " to " + paddingY)
				}
			}
			
			var x = PADDING_X.from(layoutConf)
			var y = PADDING_TOP.from(layoutConf)
			var toBeNodeWidth = container.width - 2 * PADDING_X.from(layoutConf)
			for (node : nodes) {
				if (x != node.x) node.x = x
				if (y != node.y) node.y = y
				if (toBeNodeWidth != node.width) {
					node.width = toBeNodeWidth
				}
				y += node.height + paddingY
			}
			requiredHeight = y - paddingY + PADDING_BOTTOM.from(layoutConf)
			val desiredHeight
				= if (requiredHeight > container.height
						|| SHRINK_TO_CHILDREN_HEIGHT.from(layoutConf) == 1) {
					requiredHeight
				  } else container.height
			
			container.applyHeightFrom(layoutConf, desiredHeight)
		}
		
		container.allContainers.forEach[layout]
	}
	
	def void applyHeightFrom(Container container, Map<LayoutConfiguration,?> layoutConf) {
		applyHeightFrom(container, layoutConf, container.height)
	}
	
	def void applyHeightFrom(Container container, Map<LayoutConfiguration,?> layoutConf, int desiredHeight) {
		if (DISABLE_RESIZE.from(layoutConf) == 1
			|| DISABLE_RESIZE_HEIGHT.from(layoutConf) == 1) {
				
			return
		}
		val fixedHeight = FIXED_HEIGHT.from(layoutConf)
		if (fixedHeight >= 0 && container.height != fixedHeight) {
			container.height = fixedHeight
		} else {
			var toBeHeight = desiredHeight
			println(container.class.simpleName + " toBeHeight: " + toBeHeight)
			val minHeight = MIN_HEIGHT.from(layoutConf)
			val maxHeight = MAX_HEIGHT.from(layoutConf)
			if (maxHeight >= 0 && maxHeight > minHeight && maxHeight < toBeHeight) {
				toBeHeight = maxHeight
			}
			if (minHeight >= 0 && minHeight > toBeHeight) {
				toBeHeight = minHeight
			}
			if (container.height != toBeHeight) {
				println(container.class.simpleName + " apply height: " + toBeHeight)
				container.height = toBeHeight
			}
		}
	}
	
	def void applyWidthFrom(Container container, Map<LayoutConfiguration,?> layoutConf) {
		if (DISABLE_RESIZE.from(layoutConf) == 1
			|| DISABLE_RESIZE_WIDTH.from(layoutConf) == 1) {
				
			return
		}
		val fixedWidth = FIXED_WIDTH.from(layoutConf)
		if (fixedWidth >= 0 && container.width != fixedWidth) {
			container.width = fixedWidth
		} else {
			val minWidth = MIN_WIDTH.from(layoutConf)
			var toBeWidth = container.width
			val maxWidth = MAX_WIDTH.from(layoutConf)
			if (maxWidth >= 0 && maxWidth > minWidth && maxWidth < toBeWidth) {
				toBeWidth = maxWidth
			}
			if (minWidth >= 0 && minWidth > toBeWidth) {
				toBeWidth = minWidth
			}
			if (container.width != toBeWidth) {
				container.width = toBeWidth
			}
		}
	}
	
	def getMaxHeight(Container container, Map<LayoutConfiguration,?> layoutConf) {
		if (DISABLE_RESIZE.from(layoutConf) == 1
			|| DISABLE_RESIZE_HEIGHT.from(layoutConf) == 1) {
				
			return container.height
		}
		if (FIXED_HEIGHT.from(layoutConf) >= 0) {
			return FIXED_HEIGHT.from(layoutConf)
		}
		return MAX_HEIGHT.from(layoutConf)
	}
	
	// ++++++++++++++++++++++++++++++++++++
	//
	// Container-specific layout constants,
	// to be extended in sub-classes.
	//
	// ++++++++++++++++++++++++++++++++++++
	
	dispatch def Map<LayoutConfiguration,?> getLayoutConfiguration(Container container) {
		null // fallback to defaults
	}
	
	dispatch def List<? extends Class<? extends Node>> getInnerOrder(Container container) {
		null // fallback to defaults
	}
	
	dispatch def List<? extends Class<? extends Node>> getIgnoredChildren(Container container) {
		null // fallback to defaults
	}
}
