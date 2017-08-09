package de.jabc.cinco.meta.plugin.pyro

import java.io.IOException
import java.net.URISyntaxException
import java.util.Set
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension
import mgl.GraphModel
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import productDefinition.CincoProduct

class CreatePyroPlugin {
	protected extension WorkspaceExtension = new WorkspaceExtension()
	public static final String PYRO = "pyro"
	public static final String PRIME = "primeviewer"
	public static final String PRIME_LABEL = "pvLabel"
	package IFolder dywaAppfolder

	def void execute(Set<GraphModel> graphModels, IProject project,CincoProduct cp,String basePath) throws IOException, URISyntaxException {
		//create archetype
		dywaAppfolder = createFolder(project, "dywa-app")
		
		//generate
		val gen = new Generator
		gen.generate(graphModels,cp,basePath,project)
		
	}
}
