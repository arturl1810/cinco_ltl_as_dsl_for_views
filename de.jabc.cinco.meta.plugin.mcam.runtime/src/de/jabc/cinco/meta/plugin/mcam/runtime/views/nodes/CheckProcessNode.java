package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import info.scce.mcam.framework.processes.CheckProcess;

public class CheckProcessNode extends TreeNode {

	public CheckProcessNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof CheckProcess<?, ?>) {
			CheckProcess<?, ?> process = (CheckProcess<?, ?>) data;
			return process.getModel().getFilePath() + "/" + process.getModel().getModelName();
		}
		return uuid.toString();
	}

	
}
