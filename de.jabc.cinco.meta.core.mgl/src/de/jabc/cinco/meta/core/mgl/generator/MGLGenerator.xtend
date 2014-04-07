package de.jabc.cinco.meta.core.mgl.generator

import com.google.inject.Inject
import de.jabc.cinco.meta.core.mgl.transformation.MGL2Ecore
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext
import mgl.GraphModel
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.Set
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.xbase.lib.Pair
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import org.eclipse.core.resources.ResourcesPlugin

class MGLGenerator implements IGenerator {
	@Inject extension IQualifiedNameProvider
	
	ArrayList<Pair<EReference,String>> toReference

	override doGenerate(Resource input, IFileSystemAccess fsa) {
		toReference = new ArrayList
		var resourceUri = input.URI
		var filePath = input.URI.toPlatformString(true)
		var iFile = ResourcesPlugin.workspace.root.getFile(new Path(filePath))
		var projectName = iFile.project.name
		for(graphModel : input.allContents.toIterable.filter(typeof(GraphModel))){
			
			doGenerateEcoreByTransformation(projectName,graphModel,fsa,resourceUri)	
		}
	}
	
	def doGenerateEcoreByTransformation(String projectName, GraphModel model, IFileSystemAccess access,URI resourceURI) {
		var interfaceGraphModel = PluginRegistry::getInstance().getRegisteredEcoreModels().get("abstractGraphModel");
//		var mcGraphModel = PluginRegistry::getInstance().getRegisteredEcoreModels().get("mc");
//		var generatable = PluginRegistry::getInstance().getRegisteredEcoreModels().get("generatable")
//		println(generatable==null)
		var LightweightExecutionContext context = new DefaultLightweightExecutionContext(null)
		var ecoreMap = PluginRegistry::getInstance().getRegisteredEcoreModels() 
		var genModelMap = PluginRegistry::getInstance().getGenModelMap() //new HashMap<EPackage,String>
		context.put("graphModel",model)
//		context.put("mcGraphModel",mcGraphModel)
		context.put("abstractGraphModel",interfaceGraphModel)
		context.put("genmodelMap",genModelMap)
		
		// These modeld should be added automatically in the final version
		
		
		context.put("registeredGeneratorPlugins",PluginRegistry::instance.pluginGenerators)
		context.put("registeredPackageMap",ecoreMap)
		
		var uri = URI::createFileURI(model.name.toString.toFirstUpper+".ecore")
		var xmiResource = new XMIResourceFactoryImpl().createResource(uri) as XMIResourceImpl
		context.put("resource",xmiResource)
		var environment = new DefaultLightweightExecutionEnvironment(context)
		context.put("ExecutionEnvironment",environment)
		var gdl2ecore = new MGL2Ecore
		var String x= gdl2ecore.execute(environment);
		println(x)
		if(x.equals("default")){
			
			var ePackage = context.get("ePackage") as EPackage
			
			var bops = new ByteArrayOutputStream()
			xmiResource.contents.add(ePackage)
			xmiResource.save(bops,null)
			var output = bops.toString(xmiResource.getEncoding)
			var ecorePath = "/model/"+model.fullyQualifiedName.toString("/")+".ecore".toFirstUpper
			access.generateFile(ecorePath,output)
			var projectPath = new Path(projectName)
			var genModel = GenModelCreator::createGenModel(new Path(ecorePath),ePackage,projectName,projectPath)
			if(model.package!=null && model.package.length>0){
				for(genPackage: genModel.genPackages){
					genPackage.basePackage = model.package
				}
			
			}
			var usedEcoreModels = context.get("usedEcoreModels") as Set
			for(key:usedEcoreModels){
				var res = new XMIResourceImpl(URI::createURI(genModelMap.get(key))) 
				res.load(null)
				println(key + " "+genModelMap.get(key))
				for(genPackage:res.allContents.toIterable.filter(typeof(GenPackage))){
					
					genModel.usedGenPackages += genPackage	
				}
					
			}
			
			bops = new ByteArrayOutputStream()
			uri = URI::createFileURI(model.name.toString.toFirstUpper+".genmodel")
			xmiResource = new XMIResourceFactoryImpl().createResource(uri) as XMIResourceImpl
			xmiResource.contents.add(genModel)
			xmiResource.save(bops,null)
			output = bops.toString(xmiResource.encoding)
			var genModelPath = "/model/"+model.fullyQualifiedName.toString("/")+".genmodel".toFirstUpper
			access.generateFile(genModelPath,output)
			
		 
			
			
		}else if(x.equals("error")){
			println(context)
			var exception = context.get("exception") as Exception
			exception.printStackTrace
			throw exception
		}else{
			
		}
		
	}
	
	
}
