package de.jabc.cinco.meta.plugin.treeviewer;

import java.util.Map;

import de.jabc.cinco.meta.core.mgl.transformation.helper.ServiceException;
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class TreeViewMetaPlugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
		for(String str :map.keySet()){
			context.put(str, map.get(str));
		}
		GenerateTreeView cpv = new GenerateTreeView();
		try {
			return cpv.execute(env);
		} catch (ServiceException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return "error";
		}
		
	}

}
