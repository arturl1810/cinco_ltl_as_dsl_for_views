package de.jabc.cinco.meta.runtime.layout

import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.Container
import graphmodel.ModelElementContainer
import graphmodel.Node
import java.util.List
import java.util.Map

import static de.jabc.cinco.meta.runtime.layout.LayoutConfiguration.*
import static java.lang.Math.max

class ListLayouter extends CincoRuntimeBaseClass {
	
	def void layout(ModelElementContainer it) {
		if (it instanceof Container) layout(layoutConfiguration)
	}

	def void layout(Container it) {
		layout(layoutConfiguration)
	}
	
	def void layout(Container it, Map<LayoutConfiguration,Integer> layoutConf) {
		layout(layoutConf, innerOrder ?: #[], ignoredChildren ?: #[])
	}
		
	def void layout(Container container, Map<LayoutConfiguration,Integer> layoutConf, List<? extends Class<? extends Node>> order, List<? extends Class<? extends Node>> ignored) {
		val nodes =
			container.allNodes
				.filter[node | !ignored.exists[cls|!#[node].filter(cls).isEmpty]]
				.sortBy[y]
				.sortBy[node | order.indexOf(order.findFirst[isAssignableFrom(node.class)])]
				
		var x = PADDING_X.from(layoutConf)
		var y = PADDING_TOP.from(layoutConf)
		if (container.width < MIN_WIDTH.from(layoutConf)) {
			container.width = MIN_WIDTH.from(layoutConf)
		}
		var width = container.width - 2 * PADDING_X.from(layoutConf)
		for (node : nodes) {
			if (x != node.x) node.x = x
			if (y != node.y) node.y = y
			if (width != node.width) node.width = width
			y += node.height + PADDING_Y.from(layoutConf)
		}
		val height
			= if (nodes.isEmpty) MIN_HEIGHT.from(layoutConf)
			  else max(MIN_HEIGHT.from(layoutConf), y + PADDING_BOTTOM.from(layoutConf))
		if (height != container.height) container.height = height
		container.allContainers.forEach[layout]
	}
	
	// ++++++++++++++++++++++++++++++++++++
	//
	// Container-specific layout constants,
	// to be extended in sub-classes.
	//
	// ++++++++++++++++++++++++++++++++++++
	
	dispatch def getLayoutConfiguration(Container container) {
		#{/* fallback to defaults */} as Map<LayoutConfiguration,Integer>
	}
	
	dispatch def List<? extends Class<? extends Node>> getInnerOrder(Container container) {
		null
	}
	
	dispatch def List<? extends Class<? extends Node>> getIgnoredChildren(Container container) {
		null
	}
}
