package de.jabc.cinco.meta.core.ge.style.generator.action

import de.jabc.cinco.meta.core.ge.style.generator.api.main.CincoApiGeneratorMain
import de.jabc.cinco.meta.core.ge.style.generator.main.GraphitiGeneratorMain
import de.jabc.cinco.meta.core.ui.listener.MGLSelectionListener
import de.jabc.cinco.meta.core.utils.CincoUtil
import de.jabc.cinco.meta.core.utils.MGLUtil
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.util.xapi.FileExtension
import java.io.File
import java.io.FileInputStream
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.net.URISyntaxException
import java.net.URL
import java.util.ArrayList
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map.Entry
import java.util.Set
import java.util.stream.Collectors
import mgl.GraphModel
import org.eclipse.core.commands.AbstractHandler
import org.eclipse.core.commands.ExecutionEvent
import org.eclipse.core.commands.ExecutionException
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IFolder
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.core.runtime.FileLocator
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.core.runtime.Platform
import org.osgi.framework.Bundle
import productDefinition.CincoProduct

import static de.jabc.cinco.meta.core.utils.MGLUtil.*

class NewGraphitiCodeGenerator extends AbstractHandler {
	
	
	IProject project = null
	Set<String> unprocessedMGLS = new HashSet<String>()


	override Object execute(ExecutionEvent event) throws ExecutionException {
		val IFile file = MGLSelectionListener.INSTANCE.getCurrentMGLFile()
		var IFile cpdFile = MGLSelectionListener.INSTANCE.getSelectedCPDFile()
		
		if(file === null) 
			throw new RuntimeException("No current mgl file in MGLSelectionListener...");
		if(cpdFile === null) 
			throw new RuntimeException("No current cpd file in MGLSelectionListener...");
		
		val cpd = CincoUtil::getCPD(cpdFile) as CincoProduct
		
		
		var NullProgressMonitor monitor = new NullProgressMonitor()
		var String name_editorProject = file.getProject().getName().concat(".editor.graphiti")
		var GraphModel graphModel = new FileExtension().getContent(file, GraphModel)
		if(graphModel === null) throw new RuntimeException('''Could not load graphmodel from file: «file»''');
		
		graphModel = prepareGraphModel(graphModel)
		
		var p = ResourcesPlugin.workspace.root.getProject(name_editorProject)
		
		if (p != null && !p.exists) {
			project = ProjectCreator.createDefaultPluginProject(name_editorProject,addReqBundles(cpdFile.getProject(), monitor), new ArrayList)
			ProjectCreator.addAdditionalNature(project, monitor, "org.eclipse.xtext.ui.shared.xtextNature")
			new GraphitiGeneratorMain(graphModel, cpdFile, CincoUtil.getStyles(graphModel)).addPerspectiveContent()
		} else project = p
		
		if (unprocessedMGLS.nullOrEmpty) {
			unprocessedMGLS.addAll(cpd.mgls.filter[!isDontGenerate].map[mglPath])
			project.getFolder("src-gen").delete(true, null)
		}
		
		copyImages(graphModel, project)
		addExpPackages(graphModel).forEach[ProjectCreator.exportPackage(project, it)]
		var GraphitiGeneratorMain editorGenerator = new GraphitiGeneratorMain(graphModel, cpdFile,CincoUtil.getStyles(graphModel))
		editorGenerator.doGenerate(project)
		
		var CincoApiGeneratorMain apiGenerator = new CincoApiGeneratorMain(graphModel)
		apiGenerator.doGenerate(project)
//		println(file.projectRelativePath)
		unprocessedMGLS.remove(file.projectRelativePath.toString)
		
		return null
	}

	def private Set<String> addReqBundles(IProject project, IProgressMonitor monitor) {
		var Set<Bundle> bundles = new HashSet<Bundle>()
		bundles.add(Platform.getBundle("org.eclipse.emf.transaction"))
		bundles.add(Platform.getBundle("org.eclipse.graphiti"))
		bundles.add(Platform.getBundle("org.eclipse.graphiti.mm"))
		bundles.add(Platform.getBundle("org.eclipse.graphiti.ui"))
		bundles.add(Platform.getBundle("org.eclipse.core.resources"))
		bundles.add(Platform.getBundle("org.eclipse.ui"))
		bundles.add(Platform.getBundle("org.eclipse.ui.ide"))
		bundles.add(Platform.getBundle("org.eclipse.ui.navigator"))
		bundles.add(Platform.getBundle("org.eclipse.ui.views.properties.tabbed"))
		bundles.add(Platform.getBundle("org.eclipse.gef"))
		bundles.add(Platform.getBundle("org.eclipse.xtext.xbase.lib"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.model"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.referenceregistry"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ui"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.util"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.runtime"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.utils"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.capi"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.wizards"))
		bundles.add(Platform.getBundle("javax.el"))
		bundles.add(Platform.getBundle("com.sun.el"))
		bundles.add(Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator.runtime"))
		var Set<String> retval = bundles.stream().filter([b|b !== null]).map([b|b.getSymbolicName()]).collect(
			Collectors.toSet())
		retval.add(project.getName())
		return retval
	}

	def private List<String> addExpPackages(GraphModel gm) {
		var ArrayList<String> packs = new ArrayList<String>()
		packs.add(new GeneratorUtils().packageName(gm).toString())
		return packs
	}

	def private void copyImages(GraphModel graphModel, IProject project) {
		var HashMap<String, URL> allImages = MGLUtil.getAllImages(graphModel)
		var File f
		try {
			var IFolder iconsFolder = project.getFolder("icons")
			var IFolder resGen = project.getFolder(new Path("resources-gen"))
			var IFolder icoGen = project.getFolder(new Path("resources-gen/icons"))
			if(!iconsFolder.exists()) iconsFolder.create(true, true, null)
			if(!resGen.exists()) resGen.create(true, true, null)
			if(!icoGen.exists()) icoGen.create(true, true, null)
			var Bundle b = Platform.getBundle("de.jabc.cinco.meta.core.ge.style.generator.runtime")
			var InputStream fileis = null
			try {
				fileis = FileLocator.openStream(b, new Path("/icons/_Connection.gif"), false)
				var File trgFile = project.getFolder("resources-gen/icons").getFile("_Connection.gif").getLocation().
					toFile()
				trgFile.createNewFile()
				var OutputStream os = new FileOutputStream(trgFile)
				var int bt
				while ((bt = fileis.read()) !== -1) {
					os.write(bt)
				}
				fileis.close()
				os.flush()
				os.close()
				CincoUtil.refreshFiles(null, project.getFolder("resources-gen/icons").getFile("_Connection.gif"))
			} catch (IOException e) {
				e.printStackTrace()
			}

			for (Entry<String, URL> e : allImages.entrySet()) {
				var IFile imgFile = project.getFile(e.getKey())
				f = new File(e.getValue().toURI())
				if (!imgFile.exists()) {
					var FileInputStream fis = new FileInputStream(f)
					val targetImageFile = imgFile.location.toFile
					if (!targetImageFile.parentFile.exists) {
						targetImageFile.parentFile.mkdirs
						CincoUtil.refreshFolders(null, iconsFolder)
					}
					imgFile.create(fis, true, null)
					fis.close()
				}
			}
		} catch (URISyntaxException e1) {
			e1.printStackTrace()
		} catch (CoreException e1) {
			e1.printStackTrace()
		} catch (FileNotFoundException e1) {
			e1.printStackTrace()
		} catch (IOException e1) {
			e1.printStackTrace()
		}

	}
}
