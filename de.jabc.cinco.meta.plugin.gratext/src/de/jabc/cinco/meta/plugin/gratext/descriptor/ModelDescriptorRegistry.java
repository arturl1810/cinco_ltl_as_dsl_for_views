package de.jabc.cinco.meta.plugin.gratext.descriptor;

import de.jabc.cinco.meta.core.utils.registry.KeygenRegistry;
import mgl.GraphModel;

public class ModelDescriptorRegistry {
	
	public static KeygenRegistry<GraphModel, GraphModelDescriptor> INSTANCE = 
			new KeygenRegistry<GraphModel, GraphModelDescriptor>(desc -> desc.instance());
	
}
