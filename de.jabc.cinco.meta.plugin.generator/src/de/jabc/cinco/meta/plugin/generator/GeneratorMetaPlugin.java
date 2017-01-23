package de.jabc.cinco.meta.plugin.generator;

import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;

public class GeneratorMetaPlugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
//		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
//		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
//		for(String str :map.keySet()){
//			context.put(str, map.get(str));
//		}
		CreateCodeGeneratorPlugin cpv = new CreateCodeGeneratorPlugin();
//		try {
			String result = cpv.execute(map);
			if(result.equals("error")){
//				map.put("exception", context.get("exception"));
			}
			
			return result;
//		} catch (ServiceException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//			return "error";
//		}
		
	}
	
}
