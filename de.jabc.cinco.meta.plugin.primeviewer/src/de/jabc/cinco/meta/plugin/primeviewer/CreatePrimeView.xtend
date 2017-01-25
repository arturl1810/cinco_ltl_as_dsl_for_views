package de.jabc.cinco.meta.plugin.primeviewer

import de.jabc.cinco.meta.core.BundleRegistry
import de.jabc.cinco.meta.core.utils.BuildProperties
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import java.io.BufferedWriter
import java.io.File
import java.io.FileWriter
import java.util.ArrayList
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Set
import mgl.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IResource
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.emf.ecore.EPackage

import static de.jabc.cinco.meta.plugin.primeviewer.templates.LabelProviderTemplate.doGenerateLabelProviderContent
import static de.jabc.cinco.meta.plugin.primeviewer.templates.ContentProviderTemplate.doGenerateContentProviderContent
import static de.jabc.cinco.meta.plugin.primeviewer.templates.ActivatorTemplate.doGenerateActivatorContent
import static de.jabc.cinco.meta.plugin.primeviewer.templates.PluginXMLTemplate.doGeneratePluginXMLContent
import de.jabc.cinco.meta.core.utils.projects.ContentWriter

class CreatePrimeView {

	extension GeneratorUtils = new GeneratorUtils
	
	new() {
	}

	def IProject createPrimeViewEclipseProject(Map<String, Object> map) {
		// LightweightExecutionContext context = environment.getLocalContext()
		// .getGlobalContext();
		try {
			var GraphModel graphModel = (map.get("graphModel") as GraphModel)
			var List<String> exportedPackages = new ArrayList()
			var List<String> additionalNature = new ArrayList()
			var String projectName = '''«graphModel.getPackage()».primeviewer'''
			var List<IProject> referencedProjects = new ArrayList()
			var List<String> srcFolders = new ArrayList()
			srcFolders.add("src")
			var Set<String> requiredBundles = new HashSet()
			requiredBundles.add("org.eclipse.ui")
			requiredBundles.add("org.eclipse.core.runtime")
			var IResource res = ResourcesPlugin.getWorkspace().getRoot().findMember(
				new Path(graphModel.eResource().getURI().toPlatformString(true)))
			var String symbolicName
			if(res !== null) symbolicName = ProjectCreator.
				getProjectSymbolicName(res.getProject()) else symbolicName = graphModel.getPackage()
			requiredBundles.add(symbolicName)
			requiredBundles.add("org.eclipse.core.resources")
			requiredBundles.add("org.eclipse.ui.navigator")
			requiredBundles.add("org.eclipse.emf.common")
			requiredBundles.add("org.eclipse.emf.ecore")
			var IProgressMonitor progressMonitor = new NullProgressMonitor()
			var IProject tvProject = ProjectCreator.createProject(projectName, srcFolders, referencedProjects,
				requiredBundles, exportedPackages, additionalNature, progressMonitor, false)
			// context.put("projectPath", tvProject.getLocation().makeAbsolute()
			// .toPortableString());
			var File maniFile = tvProject.getLocation().append("META-INF/MANIFEST.MF").toFile()
			var BufferedWriter bufwr = new BufferedWriter(new FileWriter(maniFile, true))
			bufwr.append('''Bundle-Activator: «projectName».Activator
''')
			bufwr.append("Bundle-ActivationPolicy: lazy\n")
			bufwr.flush()
			bufwr.close()
			var IFile bpf = (tvProject.findMember("build.properties") as IFile)
			var BuildProperties buildProperties = BuildProperties.loadBuildProperties(bpf)
			buildProperties.appendBinIncludes("plugin.xml")
			buildProperties.store(bpf, progressMonitor)
			BundleRegistry.INSTANCE.addBundle(projectName, false)
			return tvProject
		} catch (Exception e) {
			// context.put("exception", e);
			return null
		}

	}

	def String execute(Map<String, Object> map) {
		val IProject proj = this.createPrimeViewEclipseProject(map)
		val GraphModel gm = (map.get("graphModel") as GraphModel)
		var EPackage ePack = (map.get("ePackage") as EPackage)
		if (proj !== null) {
			try {
				var primeNodes = gm.nodes.filter[isPrime]
				
				var primeViewElements = primeNodes.filter[
					!(primeReference.annotations.filter[name.equals("pvFileExtension")].empty)
				]
				
				primeViewElements.forEach[ 
					doGenerateLabelProviderContent(it, proj)
					doGenerateContentProviderContent(it, proj)
				]
				
				doGenerateActivatorContent(gm, proj)
				doGeneratePluginXMLContent(primeViewElements, proj)
				
				proj.refreshLocal(IResource.DEPTH_INFINITE, new NullProgressMonitor())
				return "default"
			} catch (CoreException e) {
			
			}
		} else {
			return "error"
		}
		return ""
	} 
	
}
