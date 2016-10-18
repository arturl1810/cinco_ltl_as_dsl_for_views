package de.jabc.cinco.meta.plugin.executer.service;

import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.jabc.cinco.meta.plugin.executer.generator.model.CreateExecuterPlugin;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class ESDSLMetaPluginService implements IMetaPlugin {

	public ESDSLMetaPluginService() {
		System.out.println("Execution Semantics Meta Plugin Enabled");
	}

	@Override
	public String execute(Map<String, Object> map) {
		System.out.println("RUNNING EXECUTION SEMANTICS METAPLUGIN");
		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
		for(String str :map.keySet()){
			context.put(str, map.get(str));
		}
		CreateExecuterPlugin cep = new CreateExecuterPlugin();
		try {
			return cep.execute(env);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;
	}

}
