package de.jabc.cinco.meta.core.ge.style.generator.action

import de.jabc.cinco.meta.core.ge.style.generator.api.main.CincoApiGeneratorMain
import de.jabc.cinco.meta.core.ge.style.generator.main.GraphitiGeneratorMain
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.runtime.xapi.FileExtension
import de.jabc.cinco.meta.runtime.xapi.WorkspaceExtension
import java.io.File
import java.io.FileInputStream
import java.net.URL
import java.util.HashMap
import java.util.Set
import mgl.GraphModel
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.Platform

import static de.jabc.cinco.meta.core.utils.PathValidator.getURLForString

import static extension de.jabc.cinco.meta.core.utils.CincoUtil.getStyles
import static extension de.jabc.cinco.meta.core.utils.MGLUtil.prepareGraphModel
import static extension de.jabc.cinco.meta.core.utils.projects.ProjectCreator.*

class NewGraphitiCodeGenerator extends AbstractHandler {
	
	extension WorkspaceExtension = new WorkspaceExtension
	extension FileExtension = new FileExtension
	
	IProject project = null


	override Object execute(ExecutionEvent event) throws ExecutionException {
		val mglFile = MGLSelectionListener.INSTANCE.currentMGLFile
		if (mglFile === null) 
			throw new RuntimeException("No current mgl file in MGLSelectionListener...")
		
		val cpdFile = MGLSelectionListener.INSTANCE.selectedCPDFile
		if (cpdFile === null) 
			throw new RuntimeException("No current cpd file in MGLSelectionListener...")

		val graphModel = mglFile.getContent(GraphModel)
		if (graphModel === null)
			throw new RuntimeException('''Could not load graphmodel from file: «mglFile»''')
		
		val name_editorProject = '''«graphModel.package».editor.graphiti'''
		
		workspaceRoot.getProject(name_editorProject)?.delete(true, true, null)
		
		project = createDefaultPluginProject(name_editorProject, cpdFile.project.reqBundles, null)
		project.addAdditionalNature(null, "org.eclipse.xtext.ui.shared.xtextNature")
		
		graphModel.prepareGraphModel
		new GraphitiGeneratorMain(graphModel, cpdFile, graphModel.styles)
		=> [
			copyImages(graphModel)
			graphModel.expPackages.forEach[project.exportPackage(it)]
			doGenerate(project)
		]
		new CincoApiGeneratorMain(graphModel).doGenerate(project)
		
		return null
	}

	def private Set<String> getReqBundles(IProject project) {
		(#[  "org.eclipse.emf.transaction",
			 "org.eclipse.graphiti",
			 "org.eclipse.graphiti.mm",
			 "org.eclipse.graphiti.ui",
			 "org.eclipse.core.resources",
			 "org.eclipse.ui",
			 "org.eclipse.ui.ide",
			 "org.eclipse.ui.navigator",
			 "org.eclipse.ui.views.properties.tabbed",
			 "org.eclipse.gef",
			 "org.eclipse.xtext.xbase.lib",
			 "de.jabc.cinco.meta.core.ge.style.model",
			 "de.jabc.cinco.meta.core.ge.style.generator",
			 "de.jabc.cinco.meta.core.referenceregistry",
			 "de.jabc.cinco.meta.core.ui",
			 "de.jabc.cinco.meta.util",
			 "de.jabc.cinco.meta.runtime",
			 "de.jabc.cinco.meta.core.utils",
			 "de.jabc.cinco.meta.core.capi",
			 "de.jabc.cinco.meta.core.wizards",
			 "javax.el",
			 "com.sun.el",
			 "de.jabc.cinco.meta.core.ge.style.generator.runtime"
		  ].map[Platform.getBundle(it)?.symbolicName]
		   .filterNull + #[project.name]
		).toSet
	}

	def private getExpPackages(GraphModel gm) {
		#[new GeneratorUtils().packageName(gm).toString]
	}
	
	def private copyImages(GraphModel gm) {
		val HashMap<String, URL> images = newHashMap
		
		val String iconPath = gm.iconPath
		if (!iconPath.nullOrEmpty) {
			images.put(iconPath, getURLForString(gm, iconPath))
		}
		
		for (it : images.entrySet) {
			val source = new File(value.toURI)
			project.createFile(key, new FileInputStream(source))
		}
	}
}
