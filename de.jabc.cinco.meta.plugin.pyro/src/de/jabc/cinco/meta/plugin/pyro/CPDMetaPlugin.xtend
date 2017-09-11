package de.jabc.cinco.meta.plugin.pyro

import java.io.IOException
import java.net.URISyntaxException
import java.util.Set
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.core.pluginregistry.ICPDMetaPlugin
import mgl.GraphModel
import productDefinition.CincoProduct

class CPDMetaPlugin implements ICPDMetaPlugin {
	new() {
		println("[Pyro] Awaiting your command")
	}

	override void execute(Set<GraphModel> mglList, CincoProduct arguments, IProject project) {
		var CreatePyroPlugin cpp = new CreatePyroPlugin()
		val pyroAnnotation = arguments.annotations.findFirst[name.equals("pyro")]
		if(pyroAnnotation==null){
			throw new IllegalStateException("[Pyro] pyro annotation is not provided")
		}
		val values = pyroAnnotation.value
		if(values.empty){
			throw new IllegalStateException("[Pyro] pyro target path is missing")
		}
		try {
			println("[Pyro] Aye Sir, starting generation!")
			cpp.execute(mglList, project,arguments,values.get(0))
			println("[Pyro] Sir. Generation completet successfully, Sir!")
		} catch (IOException e) {
			e.printStackTrace()
		} catch (URISyntaxException e) {
			e.printStackTrace()
		}

	}
}
