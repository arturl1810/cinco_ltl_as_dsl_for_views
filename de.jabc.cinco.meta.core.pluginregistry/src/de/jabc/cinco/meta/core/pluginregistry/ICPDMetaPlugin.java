package de.jabc.cinco.meta.core.pluginregistry;

import java.util.List;
import java.util.Set;

import mgl.GraphModel;
import productDefinition.CincoProduct;

public interface ICPDMetaPlugin {
	/**
	 * Executes the metaPlugin
	 * @param mglList - list of MGL GraphModels 
	 */
	public void execute(Set<GraphModel> mglList,CincoProduct arguments);
}
