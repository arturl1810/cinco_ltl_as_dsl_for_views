package de.jabc.cinco.meta.plugin.spreadsheet;

import java.util.Map;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;

public class SpreadSheetMetaPLugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
				System.out.println("RUNNING SPREADSHEET METAPLUGIN");
//				LightweightExecutionContext context = new DefaultLightweightExecutionContext(null);
//				LightweightExecutionEnvironment env = new DefaultLightweightExecutionEnvironment(context);
//				for(String str :map.keySet()){
//					context.put(str, map.get(str));
//				}
				CreateSpreadSheetPlugin cssp = new CreateSpreadSheetPlugin();
//				try {
					return cssp.execute(map);
//				} catch (ServiceException e) {
//					e.printStackTrace();
//					return "error";
//				}
	}

}
