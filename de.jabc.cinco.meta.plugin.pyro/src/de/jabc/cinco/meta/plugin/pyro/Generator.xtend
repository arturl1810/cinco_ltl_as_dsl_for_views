package de.jabc.cinco.meta.plugin.pyro

import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import java.io.File
import java.net.URI
import java.net.URL
import java.util.Set
import mgl.GraphModel
import org.apache.commons.io.FileUtils
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.Platform
import org.osgi.framework.Bundle
import productDefinition.CincoProduct

class Generator {
	def generate(Set<GraphModel> graphModels,CincoProduct cpd, String base,IProject iProject)
	{
		val gc = new GeneratorCompound(cpd.name,graphModels);
		//copy frond end statics
		{
			//generate front end
			val path = base + "/app-presentation/target/generated-sources/app"
			copyResources("frontend/app/lib",path)
			copyResources("frontend/app/web",path)
			val frontEndGen = new de.jabc.cinco.meta.plugin.pyro.frontend.Generator(path)
			frontEndGen.generate(gc,iProject)
			//generate modeling canvas
			val modelingGen = new de.jabc.cinco.meta.plugin.pyro.canvas.Generator(path)
			modelingGen.generator(gc,iProject)
		}
	}
	
	/**
	 * Copies all files recursively from a given bundle to a given target path.
	 * @param bundleId
	 * @param target
	 */
	private def copyResources(String source,String target) {
		val Bundle b = Platform.getBundle("de.jabc.cinco.meta.plugin.pyro");
		val URL directoryURL = b.getEntry(source);
		try {
			// solution based on http://stackoverflow.com/a/23953081
			val URL fileURL = FileLocator.toFileURL(directoryURL);
			val URI resolvedURI = new URI(fileURL.getProtocol(), fileURL.getPath(), null);
		    val File directory = new File(resolvedURI);
			FileUtils.copyDirectoryToDirectory(directory, new File(target));

		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
}