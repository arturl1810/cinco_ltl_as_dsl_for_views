package de.jabc.cinco.meta.plugin.modelchecking.runtime.modelchecker;

import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.BasicCheckableModel;

public abstract class SimpleModelChecker extends AbstractBasicModelChecker<BasicCheckableModel> {

	@Override
	public BasicCheckableModel createCheckableModel() {
		return new BasicCheckableModel();
	}

}
