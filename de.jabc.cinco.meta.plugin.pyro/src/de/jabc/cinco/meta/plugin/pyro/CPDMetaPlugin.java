package de.jabc.cinco.meta.plugin.pyro;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.Set;

import org.eclipse.core.resources.IProject;

import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin;
import mgl.GraphModel;
import productDefinition.CincoProduct;

public class CPDMetaPlugin implements ICPDMetaPlugin {

	public CPDMetaPlugin() {
	}


	@Override
	public void execute(Set<GraphModel> mglList, CincoProduct arguments, IProject project) {
		CreatePyroPlugin cpp = new CreatePyroPlugin();
		try {
			cpp.execute(mglList,project);
		} catch (IOException | URISyntaxException e) {
			e.printStackTrace();
		}
		
	}

}
