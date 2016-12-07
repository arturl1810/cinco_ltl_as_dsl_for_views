package de.jabc.cinco.meta.plugin.executer.generator.tracer

import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel

class CardinalityCheckerTemplate extends MainTemplate {
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override fileName() {
		return "CardinalityChecker.java"
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	package «graphmodel.tracerPackage».match.simulation;
	
	import «graphmodel.CApiPackage».CExecutableEdge;
	
	public class CardinalityChecker {
		
		public static boolean checkCardinality(CExecutableEdge transition,int size)
		{
			if(transition.getCardinality() < 0)return true;
			
			switch(transition.getCompare())
			{
				case EQ: return size == transition.getCardinality();
				case G: return size > transition.getCardinality();
				case GEQ: return size >= transition.getCardinality();
				case L: return size < transition.getCardinality();
				case LEQ: return size <= transition.getCardinality();
			}
			return false;
		}
	}
	
	'''
	
}