package de.jabc.cinco.meta.plugin.pyro.util

class Generatable {
	protected extension Escaper = new Escaper
	protected extension MGLExtension = new MGLExtension
	protected extension DyWAExtension = new DyWAExtension
	
	protected GeneratorCompound gc
	
	new(GeneratorCompound gc){
		this.gc = gc
	}
}