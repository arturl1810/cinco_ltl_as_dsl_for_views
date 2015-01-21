/*
 * generated by Xtext
 */
package de.jabc.cinco.meta.productdefinition.generator

import ProductDefinition.CincoProduct
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.ArrayList
import mgl.GraphModel
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.pde.internal.core.iproduct.IProductFeature
import org.eclipse.pde.internal.core.iproduct.IWindowImages
import org.eclipse.pde.internal.core.product.AboutInfo
import org.eclipse.pde.internal.core.product.ProductFeature
import org.eclipse.pde.internal.core.product.SplashInfo
import org.eclipse.pde.internal.core.product.WindowImages
import org.eclipse.pde.internal.core.product.WorkspaceProductModel
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class CPDGenerator implements IGenerator {
	
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		
		
		for(productDefinition: resource.contents.filter(CincoProduct)){
			var usedFeatures = getUsedFeatures(productDefinition)
			var id = productDefinition.id
			var srcFolders = new ArrayList<String>
			var referencedProjects = new ArrayList<IProject>
			var exportedPackages  = new ArrayList<String>
			//var requiredBundles = new HashSet<String>
			var additionalNatures  = new ArrayList<String>
			additionalNatures += "org.eclipse.pde.PluginNature" 
			var progressMonitor = new NullProgressMonitor()
			
			var project = ProjectCreator.createProject(id,srcFolders,referencedProjects,null,exportedPackages,additionalNatures,progressMonitor,false) as IProject
				
			
			
			
			// Creating Cinco Product file 
			var productFile = ProjectCreator.createFile(productDefinition.name+".product",project,"",progressMonitor)
			var productModel = new WorkspaceProductModel(productFile,true)
			productModel.load
			
			// Setting Name etc.
			var product = productModel.product
			product.name = productDefinition.name
			product.id = productDefinition.id
			
			// adding features
			var features =new ArrayList<IProductFeature>
			var feat = null as IProductFeature
			for(mgl:productDefinition.mgls){
				println(mgl)
				val root = ResourcesPlugin.workspace.root
				val path = resource.URI.toPlatformString(true)
				println(path)
				val findMember = root.findMember(path)
				println(findMember)
				var cpdProject = findMember.project
				
				
				var fileURI = URI.createURI(cpdProject.findMember(mgl).fullPath.toPortableString)
				var res = Resource.Factory.Registry.INSTANCE.getFactory(fileURI, "mgl").createResource(fileURI)
				res.load(null)
				var mglModel = res.contents.get(0) as GraphModel
				feat = new ProductFeature(productModel)
				feat.id = mglModel.package+".feature"
				features.add(feat)
			}
			
			// adding other features
//			 feat = new ProductFeature(productModel)
//				feat.id = "de.jabc.cinco.meta.feature"
//				features.add(feat)
				for(featureId: usedFeatures){
					feat = new ProductFeature(productModel)
					feat.id = featureId
					features.add(feat)
				}

			
			
			product.addFeatures(features)
			product.useFeatures = true
			
			
			//Copy Image Files to product folder
			var file = project.location.toFile
			var iconPath = project.location.append("icons/")
			if(!iconPath.toFile.exists)
				iconPath.toFile.mkdirs
			 var imgFile = null as File
			println(file)
			var windowImages = new WindowImages(productModel)
			if(!productDefinition.image16.nullOrEmpty && !productDefinition.image16.equals('""')){
				var s = productDefinition.image16 as String
				s = s.replaceAll('\"','')
				imgFile = new File(s)
				var targetPath = iconPath.append(imgFile.name)
				var targetFile = targetPath.toFile
				copyFile(imgFile,targetFile)
				println(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute)
				windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,0)
			}
			if(!productDefinition.image32.nullOrEmpty){
				var s = productDefinition.image32 as String
				s = s.replaceAll('\"','')
				imgFile = new File(s)
				var targetPath = iconPath.append(imgFile.name)
				var targetFile = targetPath.toFile
				copyFile(imgFile,targetFile)
				println(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute)
				windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,1)
			}
			
			if(!productDefinition.image48.nullOrEmpty){
				var s = productDefinition.image48 as String
				s = s.replaceAll('\"','')
				imgFile = new File(s)
				var targetPath = iconPath.append(imgFile.name)
				var targetFile = targetPath.toFile
				copyFile(imgFile,targetFile)
				println(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute)
				windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,2)
			}
			if(!productDefinition.image64.nullOrEmpty){
				var s = productDefinition.image64 as String
				s = s.replaceAll('\"','')
				imgFile = new File(s)
				var targetPath = iconPath.append(imgFile.name)
				var targetFile = targetPath.toFile
				copyFile(imgFile,targetFile)
				println(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute)
				windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,3)
			}
			if(!productDefinition.image128.nullOrEmpty){
				var s = productDefinition.image128 as String
				s = s.replaceAll('\"','')
				imgFile = new File(s)
				var targetPath = iconPath.append(imgFile.name)
				var targetFile = targetPath.toFile
				copyFile(imgFile,targetFile)
				println(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute)
				windowImages.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString,4)
			}
			if(!productDefinition.splashPlugin.nullOrEmpty&&!productDefinition.splashPlugin.equals("\"\"")){
				var s = productDefinition.splashPlugin.replaceAll("\"","")
				product.setSplashInfo(new SplashInfo(productModel))
				product.splashInfo.setLocation(s,true)
				

			}
			
			if(productDefinition.about!=null){
				
				var aboutInfo = new AboutInfo(productModel)
				
				if(!productDefinition.about.imagePath.nullOrEmpty && !productDefinition.about.imagePath.equals("\"\"")){
				
					var imageFile = new File(productDefinition.about.imagePath.replaceAll("\"",""))
					var targetPath = project.location.makeAbsolute.append("icons").append(imageFile.name)
					var targetFile = targetPath.toFile
					copyFile(imageFile,targetFile)
					aboutInfo.setImagePath(targetPath.makeRelativeTo(project.workspace.root.location).makeAbsolute.toString)
					
				}
				
				var text = productDefinition.about.aboutText
				aboutInfo.setText(text)
				product.setAboutInfo(aboutInfo)
			}
			
			product.setWindowImages(windowImages)
			
			var pluginXML = generatePluginXML(project,productDefinition,windowImages)
			ProjectCreator.createFile("plugin.xml",project,pluginXML.toString,progressMonitor)
			product.productId = productDefinition.id+".product"
			product.application = "org.eclipse.ui.ide.workbench"
			
			
			product.version = productDefinition.version
			productModel.save
			project.refreshLocal(IProject.DEPTH_INFINITE,progressMonitor)
			
		}
	}
	
	def getUsedFeatures(CincoProduct productModel) {
		val String[] x = #["org.eclipse.sdk",
"org.eclipse.equinox.p2.core.feature",
"org.eclipse.e4.rcp",
"org.eclipse.platform",
"org.eclipse.help",
"org.eclipse.help.source",
"org.eclipse.emf.ecore",
"org.eclipse.rcp.source",
"org.eclipse.pde.source",
"org.eclipse.equinox.p2.rcp.feature",
"org.eclipse.equinox.p2.user.ui",
"org.eclipse.cvs",
"org.eclipse.equinox.p2.rcp.feature.source",
"org.eclipse.jdt.source",
"org.eclipse.jdt",
"org.eclipse.rcp",
"org.eclipse.e4.rcp.source",
"org.eclipse.equinox.p2.user.ui.source",
"org.eclipse.emf.common",
"org.eclipse.platform.source",
"org.eclipse.equinox.p2.core.feature.source",
"org.eclipse.pde",
"org.eclipse.equinox.p2.extras.feature",
"org.eclipse.xtext.sdk","org.eclipse.emf.sdk",
"org.eclipse.xtend.sdk","org.eclipse.emf.mapping",
"org.eclipse.emf.codegen.ecore.ui","org.eclipse.emf.codegen.ui.source",
"org.eclipse.xtext.ui.source","org.eclipse.equinox.p2.extras.feature.source",
"org.eclipse.emf.mapping.ui.source","org.eclipse.xtext.xtext.ui.source",
"org.eclipse.xtext.xbase.lib",
"org.eclipse.emf.doc",
"org.eclipse.emf.ecore.edit.source",
"org.eclipse.emf.common.ui.source",
"org.eclipse.emf.codegen.ui",
"org.eclipse.emf.mapping.ecore.editor.source",
"org.eclipse.emf.ecore.editor.source",
"org.eclipse.emf.edit.source",
"org.eclipse.emf.source",
"org.eclipse.emf",
"org.eclipse.emf.converter.source",
"org.eclipse.emf.edit",
"org.eclipse.emf.converter",
"org.eclipse.emf.mapping.ecore.source",
"org.eclipse.xtext.examples.source",
"org.eclipse.emf.databinding.source",
"org.eclipse.emf.mapping.source",
"org.eclipse.xtext.xbase.source",
"org.eclipse.cvs.source",
"org.eclipse.emf.doc.source",
"org.eclipse.emf.databinding.edit",
"org.eclipse.xtext.examples",
"org.eclipse.emf.common.ui",
"org.eclipse.emf.ecore.edit",
"org.eclipse.emf.mapping.ecore.editor",
"org.eclipse.emf.ecore.editor",
"org.eclipse.emf.codegen.ecore.source",
"org.eclipse.emf.databinding.edit.source",
"org.eclipse.emf.codegen.source",
"org.eclipse.emf.codegen.ecore",
"org.eclipse.emf.databinding",
"org.eclipse.xtext.xbase.lib.source",
"org.eclipse.xtext.ui",
"org.eclipse.xtext.docs",
"org.eclipse.xtext.xbase",
"org.eclipse.emf.edit.ui",
"org.eclipse.xtext.runtime.source",
"org.eclipse.emf.codegen.ecore.ui.source",
"org.eclipse.emf.mapping.ecore",
"org.eclipse.xtext.xtext.ui",
"org.eclipse.emf.mapping.ui",
"org.eclipse.emf.edit.ui.source",
"org.eclipse.xtext.runtime",
"org.eclipse.emf.codegen",
"org.eclipse.graphiti.feature",
"org.eclipse.graphiti.feature.tools",
"org.eclipse.graphiti.sdk.feature",
"org.eclipse.egit",
"org.eclipse.graphiti.feature.examples",
"org.eclipse.jgit",
"org.eclipse.graphiti.feature.tools.source",
"org.eclipse.graphiti.source.feature",
"org.eclipse.graphiti.feature.examples.source",
"org.eclipse.emf.ecoretools",
"org.eclipse.emf.validation.ocl",
"org.eclipse.xsd",
"org.eclipse.xsd.edit",
"org.eclipse.gef",
"org.eclipse.mylyn_feature",
"org.eclipse.mylyn.context_feature",
"org.eclipse.mylyn.ide_feature",
"org.eclipse.mylyn.java_feature",
"org.eclipse.mylyn.bugzilla_feature",
"org.eclipse.mylyn.commons.notifications",
"org.eclipse.draw2d",
"org.eclipse.mylyn.commons",
"org.eclipse.mylyn.commons.repositories",
"org.eclipse.mylyn.tasks.ide",
"org.eclipse.mylyn.monitor",
"org.eclipse.mylyn.discovery",
"org.eclipse.mylyn.team_feature",
"org.eclipse.mylyn.commons.identity",
"org.eclipse.emf.transaction"]
		var d = new ArrayList<String>(x)
		for(feature:productModel.features)
		d+=feature
		
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
               value="«wi.getImagePath(0)»,«wi.getImagePath(1)»,«wi.getImagePath(2)»,«wi.getImagePath(3)»,«wi.getImagePath(4)»">
         </property>
         <property
               name="appName"
               value="test">
         </property>
      </product>
   </extension>

</plugin>
	'''
	
	def void copyFile(File source, File target){
		var sourceChannel = new FileInputStream(source).channel
		var targetChannel = new FileOutputStream(target).channel
		targetChannel.transferFrom(sourceChannel,0,sourceChannel.size)
	}
}
