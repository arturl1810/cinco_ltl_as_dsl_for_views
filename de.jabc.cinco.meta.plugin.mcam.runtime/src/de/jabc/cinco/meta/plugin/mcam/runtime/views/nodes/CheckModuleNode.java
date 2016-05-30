package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import info.scce.mcam.framework.modules.CheckModule;

public class CheckModuleNode extends TreeNode {

	public CheckModuleNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof CheckModule<?, ?>) {
			CheckModule<?, ?> module = (CheckModule<?, ?>) data;
			return module.getClass().getSimpleName();
		}
		return uuid.toString();
	}

}
