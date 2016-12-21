package de.jabc.cinco.meta.plugin.gratext;

import java.util.Set;

import org.eclipse.core.resources.IProject;

import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin;
import mgl.GraphModel;
import productDefinition.CincoProduct;

public class CPDMetaPlugin implements ICPDMetaPlugin {

	public CPDMetaPlugin() {}

	@Override
	public void execute(Set<GraphModel> mglList, CincoProduct product, IProject project) {
		// just a placeholder
	}

}
