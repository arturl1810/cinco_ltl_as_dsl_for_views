package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import info.scce.mcam.framework.processes.CheckResult;

public class CheckResultNode extends TreeNode {

	public CheckResultNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof CheckResult<?, ?>) {
			CheckResult<?, ?> result = (CheckResult<?, ?>) data;
			return result.getUUID().toString();
		}
		return uuid.toString();
	}
	
	
}
