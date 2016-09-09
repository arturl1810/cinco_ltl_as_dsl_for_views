package de.jabc.cinco.meta.plugin.gratext.util;

import mgl.GraphModel;
import de.jabc.cinco.meta.plugin.gratext.descriptor.GraphModelDescriptor;

public class ModelDescriptorRegistry {
	
	public static KeygenRegistry<GraphModel, GraphModelDescriptor> INSTANCE = 
			new KeygenRegistry<GraphModel, GraphModelDescriptor>(desc -> desc.instance());
	
}
