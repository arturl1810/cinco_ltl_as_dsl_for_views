package de.jabc.cinco.meta.plugin.generator.runtime.registry;

import graphmodel.GraphModel;
import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;


public class GeneratorDiscription<T extends GraphModel> {
	
	private IGenerator<T> generator =null;
	private	String outlet = null;
	
	public GeneratorDiscription(){}
	
	public GeneratorDiscription(IGenerator<T> generator, String outlet){
		this.setGenerator(generator);
		this.setOutlet(outlet);
	}

	public IGenerator<T> getGenerator() {
		return generator;
	}

	public void setGenerator(IGenerator<T> generator) {
		this.generator = generator;
	}

	public String getOutlet() {
		return outlet;
	}

	public void setOutlet(String outlet) {
		this.outlet = outlet;
	}

}
