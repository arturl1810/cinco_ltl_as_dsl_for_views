package de.jabc.cinco.meta.plugin.ocl;

import java.io.IOException;
import java.util.Map;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.ecore.EPackage;

import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin;
import mgl.GraphModel;

public class OCLMetaPlugin implements IMetaPlugin {

	@Override
	public String execute(Map<String, Object> map) {
		
		GraphModel graphModel = (GraphModel) map.get("graphModel");
		EPackage ePack = (EPackage) map.get("ePackage");
		
		try {
			new AddOCLConstraints(graphModel, ePack).addOCLConstraints();
			OCLPluginProjectCreater.createPlugin(graphModel);
		} catch (IOException | CoreException e) {
			e.printStackTrace();
			return null;
		}
		
//		 Add_OCL_Constraint cpv = new Add_OCL_Constraint();
		return "default";
		
	}
	
	

}
