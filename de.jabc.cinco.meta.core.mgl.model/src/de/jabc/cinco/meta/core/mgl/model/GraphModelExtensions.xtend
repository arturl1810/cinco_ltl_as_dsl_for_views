package de.jabc.cinco.meta.core.mgl.model

import graphmodel.IdentifiableElement

class GraphModelExtensions {
	static def ==(IdentifiableElement it, IdentifiableElement that) { id == that.id }
	
	static def !=(IdentifiableElement it, IdentifiableElement that) { id != that.id }
}