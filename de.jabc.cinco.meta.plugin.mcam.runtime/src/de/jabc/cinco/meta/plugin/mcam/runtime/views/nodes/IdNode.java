package de.jabc.cinco.meta.plugin.mcam.runtime.views.nodes;

import de.jabc.cinco.meta.plugin.mcam.runtime.core._CincoId;

public class IdNode extends TreeNode {

	public IdNode(Object data) {
		super(data);
	}

	@Override
	public String getId() {
		if (data instanceof _CincoId)
			return ((_CincoId) data).getId();
		return null;
	}

}
