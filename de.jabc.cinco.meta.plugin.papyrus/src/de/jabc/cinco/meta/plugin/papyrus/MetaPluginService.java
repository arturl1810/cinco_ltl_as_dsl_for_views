package de.jabc.cinco.meta.plugin.papyrus;

import java.io.IOException;
import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class MetaPluginService implements IMetaPlugin {

	public MetaPluginService() {
		System.out.println("Papyrus meta plugin enabled");
	}

	@Override
	public String execute(Map<String, Object> map) {
		System.out.println("RUNNING SPREADSHEET METAPLUGIN");
		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
		for(String str :map.keySet()){
			context.put(str, map.get(str));
		}
		CreatePapyrusPlugin cssp = new CreatePapyrusPlugin();
		try {
			return cssp.execute(env);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

}
