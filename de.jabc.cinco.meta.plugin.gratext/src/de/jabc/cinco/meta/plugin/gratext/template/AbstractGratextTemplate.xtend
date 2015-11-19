package de.jabc.cinco.meta.plugin.gratext.template

import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.jabc.cinco.meta.plugin.gratext.GratextProjectGenerator
import java.util.ArrayList
import org.eclipse.core.resources.IProject
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.IPath
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenJDKLevel
import org.eclipse.emf.codegen.ecore.genmodel.GenModelFactory
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.codegen.ecore.genmodel.GenRuntimeVersion
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtend.typesystem.emf.EcoreUtil2

class AbstractGratextTemplate {
	
	protected GratextProjectGenerator ctx
	
	def project() { ctx.projectDescriptor }
	
	def model() { ctx.modelDescriptor }
	def graphmodel() { model.instance }
	def modelProject() { modelProjectResource.project }
	def modelProjectResource() { platformResource(graphmodel.eResource.URI) }
	def modelProjectSymbolicName() { if (modelProjectResource != null) modelProjectResource.project.symbolicName else graphmodel.package }
	
	def fileFromTemplate(Class<?> templateClass) { ctx.getFileDescriptor(templateClass) }
	
	def create(GratextProjectGenerator generator) {
		ctx = generator
		init
		template.toString
	}
	
	def void init() {}
	
	def platformResource(URI uri) {
		ResourcesPlugin.workspace.root.findMember(new Path(uri.toPlatformString(true)))
	}
	
	def symbolicName(IProject project) {
		if (project != null) ProjectCreator.getProjectSymbolicName(project)
	}
	
	def debug(String msg) {
		System.out.println("[" + getClass().getSimpleName() + "] " + msg)
	}
	
	def template() ''''''
	
	def createGenModel() {
		val ecorePath = project.instance.getFile(fileFromTemplate(GratextEcoreTemplate).resource.fullPath).projectRelativePath
		val projectID = project.symbolicName
		val projectPath = new Path(project.symbolicName);
		val genModelPath = ecorePath.removeFileExtension().addFileExtension("genmodel");
		val genModelURI = URI.createURI(genModelPath.toString());
		val genModelResource = Resource.Factory.Registry.INSTANCE.getFactory(genModelURI).createResource(genModelURI); 
		val genModel = GenModelFactory.eINSTANCE.createGenModel(); 
		genModelResource.getContents().add(genModel);
        genModel.setModelDirectory("/"+projectPath.append("src-gen").toPortableString());
        
//        val ePackage = ctx.context.get("ePackage") as EPackage
		val ecoreFullPath = fileFromTemplate(GratextEcoreTemplate).resource.fullPath
		debug("Ecore path: " + ecoreFullPath)
        val ePackage = EcoreUtil2.getEPackage(ecoreFullPath.toOSString)
        val ePackageList = new ArrayList<EPackage>
        ePackageList.add(ePackage);
        genModel.initialize(ePackageList);
        val genPackage = genModel.getGenPackages().get(0) as GenPackage
        genModel.modelName = genModelURI.trimFileExtension.lastSegment
        genPackage.prefix = genModelURI.trimFileExtension.lastSegment
        genPackage.basePackage = model.basePackage
        genModel.setRuntimeVersion(GenRuntimeVersion.EMF210);
        genModel.setComplianceLevel(GenJDKLevel.JDK80_LITERAL);
        genModel.setModelPluginID(projectID);
        genModel.setEditPluginID(projectID+".edit");
        genModel.setEditorPluginID(projectID+".editor");
        genModel.setTestsPluginID(projectID+".tests");
        genModel.setCanGenerate(true);
        
		return genModel;
	}
	
//	def fullPath(URI uri) {
//		/** to resolve this we need the workspace root */
//		val myWorkspaceRoot = ResourcesPlugin.getWorkspace().getRoot();
//		/** create an new IPath from the URI (decode blanks etc.) */
//		val path = new Path(uri.toFileString);
//		/** finally resolve the file with the workspace */
//		val file = myWorkspaceRoot.getFile(path);
//		return file.fullPath
//		
////			if (file != null && file.fullPathgetLocation() != null) {
////				/** get java.io.File object */
////				File f = file.getLocation().toFile();
////				return f;
////			}
//	}
	
	def workspaceRoot() {
		ResourcesPlugin.getWorkspace().getRoot().fullPath
	}
	
	def findFile(IPath path) {
		ResourcesPlugin.getWorkspace().getRoot().findFilesForLocation(path).get(0)
	}
	
//	def getFile(Path path) {
//		ResourcesPlugin.getWorkspace().getRoot().getFile(path)
//	}


}