package de.jabc.cinco.meta.core.pluginregistry;

import java.util.Map;

public interface IMetaPlugin {
	/**
	 * Executes the metaPlugin
	 * @param map - map contains Objects under specific keys
	 * 		- graphModel: The MGL Model describing the Editor
	 * 		- modelElements: a Map containing The Generated EClass Objects with their names as keys
	 * 		- ePackage: Contains the generated EPackage of the graphModel  
	 * @return a String that notifies the caller of the success of the execution. Possible options: 'default','error'
	 */
	public String execute(Map<String,Object> map);
		
	
}
