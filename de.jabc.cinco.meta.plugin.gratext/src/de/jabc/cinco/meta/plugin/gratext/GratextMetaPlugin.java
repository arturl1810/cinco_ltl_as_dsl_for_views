package de.jabc.cinco.meta.plugin.gratext;

import java.util.Map;

import de.jabc.cinco.meta.core.BundleRegistry;
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;

public class GratextMetaPlugin implements IMetaPlugin {
	
	public static final String RESULT_DEFAULT = "default";
	public static final String RESULT_ERROR = "error";
	
	@Override
	public String execute(Map<String, Object> ctx) {
		try {
			BundleRegistry.INSTANCE.addBundle("de.jabc.cinco.meta.plugin.gratext", true);
			new GratextProjectGenerator().execute(ctx);
			return RESULT_DEFAULT;
		} catch(Exception e) {
			e.printStackTrace();
			return RESULT_ERROR;
		}
	}
}
