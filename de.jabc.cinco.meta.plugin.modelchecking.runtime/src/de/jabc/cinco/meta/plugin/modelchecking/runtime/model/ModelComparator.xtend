package de.jabc.cinco.meta.plugin.modelchecking.runtime.model

interface ModelComparator<M> {
	abstract def boolean areEqualModels(M m1, M m2)
}