package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import info.scce.mcam.framework.processes.CheckProcess;

public class CheckProcessNode extends TreeNode {

	public CheckProcessNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof CheckProcess) {
			CheckProcess<?, ?> cp = (CheckProcess<?, ?>) data;
			return cp.getModel().getFilePath() + "_" + cp.getModel().getModelName();
		}
		return null;
	}

}
