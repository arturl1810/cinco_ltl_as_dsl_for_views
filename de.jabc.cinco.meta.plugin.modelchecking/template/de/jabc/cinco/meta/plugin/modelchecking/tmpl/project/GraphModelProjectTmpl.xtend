package de.jabc.cinco.meta.plugin.modelchecking.tmpl.project

import de.jabc.cinco.meta.plugin.template.ProjectTemplate
import de.jabc.cinco.meta.plugin.dsl.ProjectDescription
import de.jabc.cinco.meta.plugin.dsl.FolderDescription
import de.jabc.cinco.meta.plugin.dsl.PackageDescription
import de.jabc.cinco.meta.plugin.dsl.FileDescription
import de.jabc.cinco.meta.plugin.dsl.ProjectType
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.IFile
import java.util.jar.Manifest
import java.io.FileOutputStream
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.provider.ModelCheckingProviderTmpl
import de.jabc.cinco.meta.plugin.modelchecking.tmpl.provider.ProviderHandlerTmpl

class GraphModelProjectTmpl extends ProjectTemplate{

	
	override projectDescription() {
		val project = new ProjectDescription(this)
		project.type = ProjectType.JAVA
		project.deleteIfExistent = false
		
		
		val folder = new FolderDescription(project, "src-gen")
		folder.deleteIfExistent = false
		project.add(folder)
		
		val package = new PackageDescription(
			model.package + ".modelchecking"
		)
		folder.packages.add(package)
		
		package.add(new FileDescription(ModelCheckingProviderTmpl))
		package.add(new FileDescription(ProviderHandlerTmpl))
		
		writePackagesToManifest
		
		return project
	}
	
	override projectSuffix() {
		''''''
	}
	
	override getProjectName(){
		model.projectName
	}
	
	
	
	def writePackagesToManifest(){
		val IProject project = workspace.root.getProject(model.projectName)
		if (project === null)
		{
			println("Error: no project found")
		}
		
		var IFile iManiFile = project.getFolder("META-INF").getFile("MANIFEST.MF")
		var Manifest manifest = new Manifest(iManiFile.contents)
		var exportPackages = model.package + ".modelchecking"
		var importPackages = "de.jabc.cinco.meta.plugin.modelchecking.runtime"
		
		manifest.mainAttributes.putValue(
			"Export-Package",
			cleanManifestAttribute(
				manifest.mainAttributes.getValue("Export-Package"), exportPackages
			) + exportPackages
		)
		
		manifest.mainAttributes.putValue(
			"Require-Bundle",
			cleanManifestAttribute(
				manifest.mainAttributes.getValue("Require-Bundle"), importPackages
			) + importPackages			
		)
		manifest.write(new FileOutputStream(iManiFile.location.toFile))
	}
	
	def cleanManifestAttribute(String values, String packagePrefix){
		var output = ""
		if (values === null)
		return output
		
		var entries = values.split(",");
		for (entry : entries){
			if (!(entry === null 
			|| entry.length == 0
			|| entry.startsWith(packagePrefix))){
				output += entry + ","			
			}				
		}
		return output
	}
	
}