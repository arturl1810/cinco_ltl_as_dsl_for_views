package de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker;

import java.util.Set;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.ModelComparator;

public interface ModelChecker<M extends CheckableModel<N,E>, N, E> {

	Set<N> getSatisfyingNodes(M model, String expression) throws Exception;
	
	String getName();
	
	M createCheckableModel();
	
	ModelComparator<M> getComparator();	
}
