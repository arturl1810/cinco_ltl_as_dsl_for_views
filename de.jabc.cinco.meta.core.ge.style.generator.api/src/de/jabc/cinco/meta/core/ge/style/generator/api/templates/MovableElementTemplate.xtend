package de.jabc.cinco.meta.core.ge.style.generator.api.templates

import mgl.Node

interface MovableElementTemplate {
	
	def CharSequence canMoveToContainer(Node me)
	def CharSequence moveToContainer(Node me)
	def CharSequence moveToContainerXY(Node me)
	def CharSequence moveToXY(Node me)
}
