package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;
import info.scce.mcam.framework.processes.CheckResult;

public class CheckResultNode extends TreeNode {

	public CheckResultNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof CheckResult<?, ?>) {
			CheckResult<?, ?> result = (CheckResult<?, ?>) data;
			if (result.getId() instanceof _CincoId)
				return ((_CincoId) result.getId()).getId() + "_"
						+ result.getMessage();
		}
		return null;
	}

}
