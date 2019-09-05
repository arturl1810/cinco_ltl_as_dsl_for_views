package de.jabc.cinco.meta.plugin.modelchecking.runtime.core;

import java.util.Set;

import org.eclipse.graphiti.util.IColorConstant;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.formulas.FormulaHandler;
import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.CheckableModel;
import graphmodel.GraphModel;
import graphmodel.Node;

public interface ModelCheckingAdapter {

	boolean canHandle(GraphModel model);

	void buildCheckableModel(GraphModel model, CheckableModel<?, ?> checkableModel, boolean withSelection);
	
	default FormulaHandler<?, ?> getFormulaHandler() {
		return null;
	}

	default Class<?> getFormulasTypeClass() {
		return null;
	}

	IColorConstant getHighlightColor();

	boolean fulfills(GraphModel model, CheckableModel<?, ?> checkableModel, Set<Node> satisfyingNodes);
}
