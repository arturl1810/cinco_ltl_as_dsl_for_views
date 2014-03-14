package de.jabc.cinco.meta.core.ge.style.fragment;

import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;

public class GraphitiGenerator implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
		return "default";
	}
}