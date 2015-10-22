package de.jabc.cinco.meta.plugin.generator.runtime.registry;

import graphmodel.GraphModel;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import de.jabc.cinco.meta.plugin.generator.runtime.IGenerator;

public class GraphModelGeneratorRegistry<T extends GraphModel> {
	HashMap<String,List<GeneratorDiscription<T>>> generators;
	
	public static GraphModelGeneratorRegistry<GraphModel> INSTANCE = new GraphModelGeneratorRegistry<GraphModel>();
	
	private GraphModelGeneratorRegistry(){
		this.generators = new HashMap<String, List<GeneratorDiscription<T>>>();
	}
	
	public void addGenerator(String graphModelClassName, IGenerator<T> generator, String outlet){
		List<GeneratorDiscription<T>> _generators = this.generators.get(graphModelClassName);
		if(_generators==null){
			_generators = new ArrayList<GeneratorDiscription<T>>();
		}
		
		_generators.add(new GeneratorDiscription<T>(generator, outlet));
		
		this.generators.put(graphModelClassName,_generators);
	}
	
	public GeneratorDiscription<T> getGeneratorAt(String graphModelClassName,int i){
		return this.generators.get(graphModelClassName).get(i);
	}
	
	public List<GeneratorDiscription<T>> getAllGenerators(String graphModelClassName){
		return this.generators.get(graphModelClassName);
	}
}
