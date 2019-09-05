package de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker;

import java.util.Set;
import java.util.stream.Collectors;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.ModelComparator;

public interface ModelChecker<M extends CheckableModel<N,E>, N, E> {

	Set<N> getSatisfyingNodes(M model, String expression) throws Exception;
	
	String getName();
	
	M createCheckableModel();
	
	ModelComparator<M> getComparator();
	
	default Set<String> getSatisfyingNodeIds(M model, String expression) throws Exception {
		return getSatisfyingNodes(model, expression).stream()
				.map((N n) -> model.getId(n))
				.collect(Collectors.toSet());
	}
	
}
