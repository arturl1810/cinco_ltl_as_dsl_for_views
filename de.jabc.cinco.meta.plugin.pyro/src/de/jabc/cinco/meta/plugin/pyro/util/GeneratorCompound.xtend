package de.jabc.cinco.meta.plugin.pyro.util

import java.util.Set
import mgl.GraphModel

class GeneratorCompound {
	public final String projectName;
	public final Set<GraphModel> graphMopdels
	
	new(String projectName,Set<GraphModel> graphMopdels) {
		this.projectName = projectName
		this.graphMopdels = graphMopdels
	}
}