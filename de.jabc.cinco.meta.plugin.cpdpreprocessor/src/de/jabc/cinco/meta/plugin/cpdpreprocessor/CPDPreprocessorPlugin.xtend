package de.jabc.cinco.meta.plugin.cpdpreprocessor

import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin
import java.util.Set
import mgl.GraphModel
import org.eclipse.core.resources.IProject
import productDefinition.CincoProduct

class CPDPreprocessorPlugin implements ICPDMetaPlugin {
	new() { 
		// TODO Auto-generated constructor stub
	}

	override void execute(Set<GraphModel> mglList, CincoProduct product, IProject project) { 
		// See de.jabc.cinco.meta.core.ui project :(
	}
}