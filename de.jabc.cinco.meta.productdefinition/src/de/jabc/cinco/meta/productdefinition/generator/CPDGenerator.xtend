/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.productdefinition.generator

import ProductDefinition.CincoProduct
import ProductDefinition.Color
import de.jabc.cinco.meta.core.BundleRegistry
import de.jabc.cinco.meta.core.utils.BuildProperties
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.ArrayList
import mgl.GraphModel
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.core.runtime.Path
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.pde.internal.core.iproduct.IProduct
import org.eclipse.pde.internal.core.iproduct.IProductFeature
import org.eclipse.pde.internal.core.iproduct.IWindowImages
import org.eclipse.pde.internal.core.product.ArgumentsInfo
import org.eclipse.pde.internal.core.product.AboutInfo
import org.eclipse.pde.internal.core.product.LauncherInfo
import org.eclipse.pde.internal.core.product.ProductFeature
import org.eclipse.pde.internal.core.product.ProductModel
import org.eclipse.pde.internal.core.product.SplashInfo
import org.eclipse.pde.internal.core.product.WindowImages
import org.eclipse.pde.internal.core.product.WorkspaceProductModel
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.util.StringInputStream
import java.util.Scanner

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class CPDGenerator implements IGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {

		for (productDefinition : resource.contents.filter(CincoProduct)) {
			var mglProject = ProjectCreator.getProject(resource)
			var usedFeatures = getUsedFeatures(productDefinition)
			var id = productDefinition.id
			if(id.nullOrEmpty)
				id=mglProject.name.concat(".product")
			var srcFolders = new ArrayList<String>
			var referencedProjects = new ArrayList<IProject>
			var exportedPackages = new ArrayList<String>

			//var requiredBundles = new HashSet<String>
			var additionalNatures = new ArrayList<String>
			additionalNatures += "org.eclipse.pde.PluginNature"
			var progressMonitor = new NullProgressMonitor()

			var project = ProjectCreator.createProject(id, srcFolders, referencedProjects, null, exportedPackages,
				additionalNatures, progressMonitor, false) as IProject

			// Creating Cinco Product file 
			var productFile = ProjectCreator.createFile(productDefinition.name + ".product", project, "", progressMonitor)
			var productModel = new WorkspaceProductModel(productFile, true)
			productModel.load

			// Setting Name etc.
			var product = productModel.product
			product.name = productDefinition.name
			product.id = id + ".id"
			product.launcherInfo = new LauncherInfo(productModel)
			product.launcherInfo.launcherName = productDefinition.name.toLowerCase

			// adding features
			var features = new ArrayList<IProductFeature>
			var feat = null as IProductFeature
//			for (mgl : productDefinition.mgls) {
//				val root = ResourcesPlugin.workspace.root
//				val path = resource.URI.toPlatformString(true)
//				val findMember = root.findMember(path)
//				var cpdProject = findMember.project
//
//				var fileURI = URI.createURI(cpdProject.findMember(mgl).fullPath.toPortableString)
//				var res = Resource.Factory.Registry.INSTANCE.getFactory(fileURI, "mgl").createResource(fileURI)
//				res.load(null)
//				var mglModel = res.contents.get(0) as GraphModel
//				feat = new ProductFeature(productModel)
//				feat.id = mglModel.package + ".feature"
//				features.add(feat)
//				BundleRegistry.INSTANCE.addBundle(id, false)
//			}
			
			feat = new ProductFeature(productModel)
				feat.id = ProjectCreator.getProjectSymbolicName(mglProject) + ".feature"
				features.add(feat)
				BundleRegistry.INSTANCE.addBundle(id, false)

			// adding other features
			//			 feat = new ProductFeature(productModel)
			//				feat.id = "de.jabc.cinco.meta.feature"
			//				features.add(feat)
			for (featureId : usedFeatures) {
				feat = new ProductFeature(productModel)
				feat.id = featureId
				features.add(feat)
			}

			product.addFeatures(features)
			product.useFeatures = true

			//Copy Image Files to product folder
			//var iconPath = project.location.append("icons/")
			

			var imgFile = null as File
			var windowImages = new WindowImages(productModel)
			val bpFile = mglProject.findMember("build.properties")as IFile
			var bp = BuildProperties.loadBuildProperties(bpFile)
			var srcFolder = mglProject.findMember("src/");
			if(srcFolder!=null && srcFolder.exists())
				bp.appendSource("src/");

			val productBPFile = project.findMember("build.properties") as IFile
			var productBP = BuildProperties.loadBuildProperties(productBPFile)
			productBP.appendBinIncludes("plugin.xml")
			productBP.deleteEntry("source..")
			
			var perspectiveId = "org.eclipse.ui.resourcePerspective"
			ProjectCreator.createFile("plugin_customization.ini",project,PluginCustomization::customizeProject(perspectiveId),progressMonitor);
			productBP.appendBinIncludes("plugin_customization.ini");
			
			productBP.store(productBPFile, progressMonitor)
			
			// setting window images
			setWindowImage(productDefinition.image16, 0, mglProject, windowImages, progressMonitor, bp)
			setWindowImage(productDefinition.image32, 1, mglProject, windowImages, progressMonitor, bp)
			setWindowImage(productDefinition.image48, 2, mglProject, windowImages, progressMonitor, bp)
			setWindowImage(productDefinition.image64, 3, mglProject, windowImages, progressMonitor, bp)
			setWindowImage(productDefinition.image128, 4, mglProject, windowImages, progressMonitor, bp)
			// setting window item			
			if (!productDefinition.linuxIcon.nullOrEmpty) {
					var s = productDefinition.linuxIcon as String
					s = stripOffQuotes(s)
					if(mglProject.getFile(s).exists){
						var iconFile = mglProject.getFile(s)
						product.launcherInfo.setUseWinIcoFile(false)
						product.launcherInfo.setIconPath(LauncherInfo.LINUX_ICON, iconFile.fullPath.toString)
						bp.appendBinIncludes(iconFile.parent.fullPath.toString);
						bp.store(bpFile, progressMonitor)
								
					}else{
						imgFile = new File(s)
						var targetPath = new Path(project.location.makeAbsolute.toOSString) as IPath
						var targetFile = targetPath.append("icon.xpm").toFile
						copyFile(imgFile, targetFile)
						product.launcherInfo.setUseWinIcoFile(false)
						product.launcherInfo.setIconPath(LauncherInfo.LINUX_ICON, project.fullPath.append("icon.xpm").toString)
						productBP.appendBinIncludes(imgFile.name);
						productBP.store(productBPFile, progressMonitor)
					}

			}
			generateSplashScreen(productDefinition, mglProject, product, bp, productModel, progressMonitor)
			bp.store(bpFile, progressMonitor)
			// adding about info
			if (productDefinition.about != null) {

				var aboutInfo = new AboutInfo(productModel)

				if (!productDefinition.about.imagePath.nullOrEmpty && !productDefinition.about.imagePath.equals("\"\"")) {

					var imageFile = new File(stripOffQuotes(productDefinition.about.imagePath))
					var iconPath = mglProject.location.append("icons/branding")
					if (!iconPath.toFile.exists)
						iconPath.toFile.mkdirs
					var targetPath = iconPath.append(imageFile.name)
					var targetFile = targetPath.toFile
					copyFile(imageFile, targetFile)
					aboutInfo.setImagePath(
						targetPath.makeRelativeTo(mglProject.workspace.root.location).makeAbsolute.toString)

				}

				var text = productDefinition.about.aboutText
				aboutInfo.setText(text)
				product.setAboutInfo(aboutInfo)
			}
			
			if(productDefinition.defaultPerspective!=null){
				var defaultPerspective = String.format("-perspective %s",productDefinition.defaultPerspective);
				 
				var programOptions = new ArgumentsInfo(productModel);
				programOptions.setProgramArguments(defaultPerspective,0);
				println("jAPÖÖAÖAPAP")
				product.launcherArguments = programOptions;
				
			}

			product.setWindowImages(windowImages)
			var pluginXML = generatePluginXML(project, productDefinition, windowImages)
			ProjectCreator.createFile("plugin.xml", project, pluginXML.toString, progressMonitor)
			product.productId = id + ".product"
			product.application = "org.eclipse.ui.ide.workbench"
			var v = productDefinition.version
			if(v.nullOrEmpty)
				v="1.0.0.qualifier"
			product.version = v
			productModel.save
			
			for(plugin: productDefinition.plugins){
				BundleRegistry.INSTANCE.addBundle(stripOffQuotes(plugin),false)
			}
			
			
			
			project.refreshLocal(IProject.DEPTH_INFINITE, progressMonitor)
			mglProject.refreshLocal(IProject.DEPTH_INFINITE, progressMonitor)

		}
	}

	def generateSplashScreen(CincoProduct productDefinition, IProject mglProject, IProduct product, BuildProperties bp,
		ProductModel productModel, IProgressMonitor monitor) {
		val splashScreen = productDefinition.splashScreen
		if (splashScreen != null && !splashScreen.path.equals("\"\"")) {
			var s = stripOffQuotes(productDefinition.splashScreen.path)
			product.setSplashInfo(new SplashInfo(productModel))
			val splashInfo = product.splashInfo
			splashInfo.setLocation((mglProject.name), true)
			if (splashScreen.addProgressBar) {
				splashInfo.addProgressBar(true, true)
				val geo = #[splashScreen.pbXOffset, splashScreen.pbYOffset, splashScreen.pbWidth, splashScreen.pbHeight]
				splashInfo.setProgressGeometry(geo, true)
			}
			if (splashScreen.addProgressMessage) {
				splashInfo.addProgressMessage(true, true)
				val geo = #[splashScreen.pmXOffset, splashScreen.pmYOffset, splashScreen.pmWidth, splashScreen.pmHeight]
				splashInfo.setMessageGeometry(geo, true)
				if (splashScreen.textColor != null) {
					var color = colorString(splashScreen.textColor)
					splashInfo.setForegroundColor(color, true)
				}
			}
			var splashFile = mglProject.getFile(s)
			var imgFile = null as File
			if(splashFile.exists){
				imgFile = splashFile.location.toFile
			}else{
				imgFile = new File(s)
			}
			
			var targetPath = new Path(mglProject.location.makeAbsolute.toOSString) as IPath

			var targetFile = targetPath.append("splash.bmp").toFile
			copyFile(imgFile, targetFile)

			bp.appendBinIncludes("splash.bmp")

		}
		
	}

	def colorString(Color color) {

		var r = color.r
		var g = color.g
		var b = color.b
		var rString = Integer.toHexString(r).toUpperCase
		if (rString.length == 1)
			rString = "0" + rString
		var gString = Integer.toHexString(g).toUpperCase
		if (gString.length == 1)
			gString = "0" + gString
		var bString = Integer.toHexString(b).toUpperCase
		if (bString.length == 1)
			bString = "0" + bString
		return rString + gString + bString
	}

	def setWindowImage(String image, int index, IProject project, IWindowImages windowImages,
		IProgressMonitor progressMonitor, BuildProperties bp) {
		var targetPathString = ""
		if (!image.nullOrEmpty) {
			var s = image as String
				s = stripOffQuotes(s)
				if(new File(s).exists){
					var iconPath = project.location.append("icons/branding")
					if (!iconPath.toFile.exists)
						iconPath.toFile.mkdirs
					
					var imgFile = new File(s)
					var targetPath = iconPath.append(imgFile.name)
					targetPathString = targetPath.makeRelativeTo(project.workspace.root.location).toPortableString
					var targetFile = targetPath.toFile
					copyFile(imgFile, targetFile)
		
					windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,
						index)
					bp.store(bp.getFile(), progressMonitor)
				}else{
					var imageFile = project.getFile(stripOffQuotes(image))
					if(imageFile.exists){
						targetPathString = imageFile.fullPath.toPortableString
						windowImages.setImagePath(targetPathString,index)
						bp.appendBinIncludes(imageFile.parent.fullPath.removeFirstSegments(1).toPortableString.concat("/"))
						bp.store(bp.file,progressMonitor)
					}
				}
				
		}
			return targetPathString
		
	}

	def getUsedFeatures(CincoProduct productModel) {
		val String[] x = #["org.eclipse.sdk", "org.eclipse.equinox.p2.core.feature", "org.eclipse.e4.rcp",
			"org.eclipse.platform", "org.eclipse.help", "org.eclipse.help.source", "org.eclipse.emf.ecore",
			"org.eclipse.rcp.source", "org.eclipse.pde.source", "org.eclipse.equinox.p2.rcp.feature",
			"org.eclipse.equinox.p2.user.ui", "org.eclipse.cvs", "org.eclipse.equinox.p2.rcp.feature.source",
			"org.eclipse.jdt.source", "org.eclipse.jdt", "org.eclipse.rcp", "org.eclipse.e4.rcp.source",
			"org.eclipse.equinox.p2.user.ui.source", "org.eclipse.emf.common", "org.eclipse.platform.source",
			"org.eclipse.equinox.p2.core.feature.source", "org.eclipse.pde", "org.eclipse.equinox.p2.extras.feature",
			"org.eclipse.xtext.sdk", "org.eclipse.emf.sdk", "org.eclipse.xtend.sdk", "org.eclipse.emf.mapping",
			"org.eclipse.emf.codegen.ecore.ui", "org.eclipse.emf.codegen.ui.source", "org.eclipse.xtext.ui.source",
			"org.eclipse.equinox.p2.extras.feature.source", "org.eclipse.emf.mapping.ui.source",
			"org.eclipse.xtext.xtext.ui.source", "org.eclipse.xtext.xbase.lib", "org.eclipse.emf.doc",
			"org.eclipse.emf.ecore.edit.source", "org.eclipse.emf.common.ui.source", "org.eclipse.emf.codegen.ui",
			"org.eclipse.emf.mapping.ecore.editor.source", "org.eclipse.emf.ecore.editor.source",
			"org.eclipse.emf.edit.source", "org.eclipse.emf.source", "org.eclipse.emf",
			"org.eclipse.emf.converter.source", "org.eclipse.emf.edit", "org.eclipse.emf.converter",
			"org.eclipse.emf.mapping.ecore.source", "org.eclipse.xtext.examples.source",
			"org.eclipse.emf.databinding.source", "org.eclipse.emf.mapping.source", "org.eclipse.xtext.xbase.source",
			"org.eclipse.cvs.source", "org.eclipse.emf.doc.source", "org.eclipse.emf.databinding.edit",
			"org.eclipse.xtext.examples", "org.eclipse.emf.common.ui", "org.eclipse.emf.ecore.edit",
			"org.eclipse.emf.mapping.ecore.editor", "org.eclipse.emf.ecore.editor",
			"org.eclipse.emf.codegen.ecore.source", "org.eclipse.emf.databinding.edit.source",
			"org.eclipse.emf.codegen.source", "org.eclipse.emf.codegen.ecore", "org.eclipse.emf.databinding",
			"org.eclipse.xtext.xbase.lib.source", "org.eclipse.xtext.ui", "org.eclipse.xtext.docs",
			"org.eclipse.xtext.xbase", "org.eclipse.emf.edit.ui", "org.eclipse.xtext.runtime.source",
			"org.eclipse.emf.codegen.ecore.ui.source", "org.eclipse.emf.mapping.ecore", "org.eclipse.xtext.xtext.ui",
			"org.eclipse.emf.mapping.ui", "org.eclipse.emf.edit.ui.source", "org.eclipse.xtext.runtime",
			"org.eclipse.emf.codegen", "org.eclipse.graphiti.feature", "org.eclipse.graphiti.feature.tools",
			"org.eclipse.graphiti.sdk.feature", "org.eclipse.egit", "org.eclipse.graphiti.feature.examples",
			"org.eclipse.jgit", "org.eclipse.graphiti.feature.tools.source", "org.eclipse.graphiti.source.feature",
			"org.eclipse.graphiti.feature.examples.source", "org.eclipse.emf.ecoretools",
			"org.eclipse.emf.validation.ocl", "org.eclipse.xsd", "org.eclipse.xsd.edit", "org.eclipse.gef",
			"org.eclipse.mylyn_feature", "org.eclipse.mylyn.context_feature", "org.eclipse.mylyn.ide_feature",
			"org.eclipse.mylyn.java_feature", "org.eclipse.mylyn.bugzilla_feature",
			"org.eclipse.mylyn.commons.notifications", "org.eclipse.draw2d", "org.eclipse.mylyn.commons",
			"org.eclipse.mylyn.commons.repositories", "org.eclipse.mylyn.tasks.ide", "org.eclipse.mylyn.monitor",
			"org.eclipse.mylyn.discovery", "org.eclipse.mylyn.team_feature", "org.eclipse.mylyn.commons.identity",
			"org.eclipse.emf.transaction"]
		var d = new ArrayList<String>(x)
		for (feature : productModel.features)
			d += stripOffQuotes(feature)

		return d
	}

	def generatePluginXML(IProject project, CincoProduct cpd, IWindowImages wi) '''
<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>

   <extension
         id="product"
         point="org.eclipse.core.runtime.products">
      <product
            application="org.eclipse.ui.ide.workbench"
            name="«cpd.name»">
         <property
               name="windowImages"
               value="«wi.getImagePath(0)»,«wi.getImagePath(1)»,«wi.getImagePath(2)»,«wi.getImagePath(3)»,«wi.
		getImagePath(4)»">
         </property>
         <property
               name="appName"
               value="test">
         </property>
		 <property
			name="preferenceCustomization"
			value="plugin_customization.ini">
		</property>
      </product>
   </extension>

</plugin>
	'''

	def void copyFile(File source, File target) {
		var sourceChannel = new FileInputStream(source).channel
		var targetChannel = new FileOutputStream(target).channel
		targetChannel.transferFrom(sourceChannel, 0, sourceChannel.size)
	}

	def modifiyMGLPluginXML(IProject mglProject, IProgressMonitor monitor, String pbValues, String pmValues,
		String color, String windowImages) {
		var pluginXML = mglProject.getFile("plugin.xml")
		var inStream = null as StringInputStream
		if (!pluginXML.exists) {
			inStream = new StringInputStream(fullContents(pbValues, pmValues, color, windowImages).toString)
			pluginXML.create(inStream, true, monitor)
		} else {
			var contents = new Scanner(pluginXML.getContents, "UTF-8").useDelimiter("\\A").next
			contents = contents.replace("</plugin>",
				getExtension(pbValues, pmValues, color, windowImages) + "\n</plugin>")
			inStream = new StringInputStream(contents)
			pluginXML.setContents(inStream, true, true, monitor)

		}
	}

	def getExtension(String pbValues, String pmValues, String color, String windowImages) '''
		<extension
			id="product"
			point="org.eclipse.core.runtime.products">
				<product
					application="org.eclipse.ui.ide.workbench"
					name="Cinco">
					<property
						name="windowImages"
						value="«windowImages»">
					</property>
					<property
						name="aboutImage"
						value="about.png">
					</property>
					<property
					name="startupForegroundColor"
					value="«color»">
				</property>
				<property
					name="startupProgressRect"
					value="«pbValues»">
				</property>
				<property
					name="startupMessageRect"
					value="«pmValues»">
				</property>
				<property
						name="preferenceCustomization"
						value="plugin_customization.ini">
				</property>
				<property
					name="appName"
					value="Cinco">
				</property>
			</product>
		</extension>
	'''
	
	def stripOffQuotes(String string){
		return string.replaceAll("\"","").replaceAll("'","")
	}
	
	
	
	def fullContents(String pbValues, String pmValues, String color, String windowImages) '''
<?xml version="1.0" encoding="UTF-8"?>
<?eclipse version="3.4"?>
<plugin>
«getExtension(pbValues, pmValues, color, windowImages)»
</plugin>	
'''
}
