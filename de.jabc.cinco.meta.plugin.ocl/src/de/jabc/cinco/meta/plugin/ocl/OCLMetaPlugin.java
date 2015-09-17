package de.jabc.cinco.meta.plugin.ocl;

import java.io.IOException;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.LightweightExecutionEnvironment;
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext;
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext;

public class OCLMetaPlugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
		for(String str :map.keySet()){
			context.put(str, map.get(str));
		}
		String ecoreSource = "http://www.eclipse.org/emf/2002/Ecore";
		context.put("ecoreSource",ecoreSource);
		String oclSource = "http://www.eclipse.org/emf/2002/Ecore/OCL";
		context.put("oclSource", oclSource);
		
		try {
			OCLPluginProjectCreater.createPlugin(context);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
			return null;
		}
		
		 Add_OCL_Constraint cpv = new Add_OCL_Constraint();
		return cpv.execute(env);
		
	}
	
	

}
