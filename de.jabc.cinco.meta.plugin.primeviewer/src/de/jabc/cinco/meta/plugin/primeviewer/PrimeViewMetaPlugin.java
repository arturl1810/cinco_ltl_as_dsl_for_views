package de.jabc.cinco.meta.plugin.primeviewer;

import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;

public class PrimeViewMetaPlugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
//		LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
//		LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
//		for(String str :map.keySet()){
//			context.put(str, map.get(str));
//		}
		CreatePrimeView cpv = new CreatePrimeView();
//		try {
			return cpv.execute(map);
//		} catch (ServiceException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//			return "error";
//		}
		
	}

}
