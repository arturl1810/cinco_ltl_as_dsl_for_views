package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import graphmodel.Edge
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.EdgeLayoutUtils.Location

abstract class EdgeLayouter {
	
	static protected final int OFFSET_TO_NODE = 15;
	static protected final int OFFSET_TO_BENDPOINT = 10;
	
	protected extension val EdgeLayoutUtils = new EdgeLayoutUtils
	
	def void apply(Edge edge)
}

class Layouter_C_TOP extends EdgeLayouter {
	override apply(Edge it) {
		replaceBendpoints(#[
			sourceElement.topCenter,
			targetElement.topCenter
		].alignTop(OFFSET_TO_NODE))
	}
}

class Layouter_C_BOTTOM extends EdgeLayouter {
	override apply(Edge it) {
		replaceBendpoints(#[
			sourceElement.bottomCenter,
			targetElement.bottomCenter
		].alignBottom(OFFSET_TO_NODE))
	}
}

class Layouter_C_LEFT extends EdgeLayouter {
	override apply(Edge it) {
		replaceBendpoints(#[
			sourceElement.middleLeft,
			targetElement.middleLeft
		].alignLeft(OFFSET_TO_NODE))
	}
}

class Layouter_C_RIGHT extends EdgeLayouter {
	override apply(Edge it) {
		replaceBendpoints(#[
			sourceElement.middleRight,
			targetElement.middleRight
		].alignRight(OFFSET_TO_NODE))
	}
}

class Layouter_Z_HORIZONTAL extends EdgeLayouter {
	
	Location sourceLoc;
	Location targetLoc;
	
	override apply(Edge it) {
		sourceLoc = sourceElement.absoluteLocation
		targetLoc = targetElement.absoluteLocation
		if (sourceLoc.x <= targetLoc.x)
			applyLeftToRight
		 else applyRightToLeft
	}
	
	def applyLeftToRight(Edge it) {
		if (sourceLoc.y <= targetLoc.y)
			applyLeftToRightAndTopToBottom
		else applyLeftToRightAndBottomToTop
	}
	
	def applyLeftToRightAndTopToBottom(Edge it) {
		val source = sourceElement.bottomCenter
		val target = targetElement.topCenter
		val dY = Math.max(Math.abs(source.y-target.y)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toBottom(dY), target.toTop(dY))
	}
	
	def applyLeftToRightAndBottomToTop(Edge it) {
		val source = sourceElement.topCenter
		val target = targetElement.bottomCenter
		val dY = Math.max(Math.abs(source.y-target.y)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toTop(dY), target.toBottom(dY))
	}
	
	def applyRightToLeft(Edge it) {
		if (sourceLoc.y <= targetLoc.y)
			applyRightToLeftAndTopToBottom
		else applyRightToLeftAndBottomToTop
	}
	
	def applyRightToLeftAndTopToBottom(Edge it) {
		val source = sourceElement.bottomCenter
		val target = targetElement.topCenter
		val dY = Math.max(Math.abs(source.y-target.y)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toBottom(dY), target.toTop(dY))
	}
	
	def applyRightToLeftAndBottomToTop(Edge it) {
		val source = sourceElement.topCenter
		val target = targetElement.bottomCenter
		val dY = Math.max(Math.abs(source.y-target.y)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toTop(dY), target.toBottom(dY))
	}
}

class Layouter_Z_VERTICAL extends EdgeLayouter {
	
	Location sourceLoc;
	Location targetLoc;
	
	override apply(Edge it) {
		sourceLoc = sourceElement.absoluteLocation
		targetLoc = targetElement.absoluteLocation
		if (sourceLoc.y <= targetLoc.y)
			applyTopToBottom
		else applyBottomToTop
	}
	
	def applyTopToBottom(Edge it) {
		if (sourceLoc.x <= targetLoc.x)
			applyTopToBottomAndLeftToRight
		else applyTopToBottomAndRightToLeft
	}
	
	def applyTopToBottomAndLeftToRight(Edge it) {
		val source = sourceElement.middleRight
		val target = targetElement.middleLeft
		val dX = Math.max(Math.abs(source.x-target.x)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toRight(dX), target.toLeft(dX))
	}
	
	def applyTopToBottomAndRightToLeft(Edge it) {
		val source = sourceElement.middleLeft
		val target = targetElement.middleRight
		val dX = Math.max(Math.abs(source.x-target.x)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toLeft(dX), target.toRight(dX))
	}
	
	def applyBottomToTop(Edge it) {
		if (sourceLoc.x <= targetLoc.x)
			applyBottomToTopAndLeftToRight
		else applyBottomToTopAndRightToLeft
	}
	
	def applyBottomToTopAndLeftToRight(Edge it) {
		val source = sourceElement.middleRight
		val target = targetElement.middleLeft
		val dX = Math.max(Math.abs(source.x-target.x)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toRight(dX), target.toLeft(dX))
	}
	
	def applyBottomToTopAndRightToLeft(Edge it) {
		val source = sourceElement.middleLeft
		val target = targetElement.middleRight
		val dX = Math.max(Math.abs(source.x-target.x)/2, OFFSET_TO_NODE)
		replaceBendpoints(source.toLeft(dX), target.toRight(dX))
	}
}

class Layouter_TO_LEFT extends EdgeLayouter {
	override apply(Edge it) {
		moveBendpoints[it => [x -= OFFSET_TO_BENDPOINT]]
	}
}

class Layouter_TO_TOP extends EdgeLayouter {
	override apply(Edge it) {
		moveBendpoints[it => [y -= OFFSET_TO_BENDPOINT]]
	}
}

class Layouter_TO_RIGHT extends EdgeLayouter {
	override apply(Edge it) {
		moveBendpoints[it => [x += OFFSET_TO_BENDPOINT]]
	}
}

class Layouter_TO_BOTTOM extends EdgeLayouter {
	override apply(Edge it) {
		moveBendpoints[it => [y += OFFSET_TO_BENDPOINT]]
	}
}