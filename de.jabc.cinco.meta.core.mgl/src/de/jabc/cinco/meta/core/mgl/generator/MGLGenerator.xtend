package de.jabc.cinco.meta.core.mgl.generator

import com.google.inject.Inject
import de.jabc.cinco.meta.core.mgl.transformation.MGL2Ecore
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.utils.URIHandler
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.Set
import mgl.ContainingElement
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.GraphicalModelElement
import mgl.MglFactory
import mgl.Node
import mgl.NodeContainer
import org.eclipse.core.internal.runtime.InternalPlatform
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.XMIResource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.pde.core.project.IBundleProjectService
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

class MGLGenerator implements IGenerator {
	@Inject extension IQualifiedNameProvider
	
	ArrayList<Pair<EReference,String>> toReference

	override doGenerate(Resource input, IFileSystemAccess fsa) {
		toReference = new ArrayList
		var resourceUri = input.URI
		var filePath = input.URI.toPlatformString(true)
		var iFile = ResourcesPlugin.workspace.root.getFile(new Path(filePath))
		var projectName = iFile.project.name

		var bc = InternalPlatform::getDefault().getBundleContext();
		var ref = bc.getServiceReference(IBundleProjectService.name);
		var service = bc.getService(ref) as IBundleProjectService
		var bpd = service.getDescription(iFile.project);
		var projectID = bpd.symbolicName
		bc.ungetService(ref);

		for(graphModel : input.allContents.toIterable.filter(typeof(GraphModel))){
			
			doGenerateEcoreByTransformation(projectName,projectID,graphModel,fsa,resourceUri)
		}
	}
	
	def doGenerateEcoreByTransformation(String projectName, String projectID, GraphModel model, IFileSystemAccess access,URI resourceURI) {
		var interfaceGraphModel = PluginRegistry::getInstance().getRegisteredEcoreModels().get("abstractGraphModel");
//		var mcGraphModel = PluginRegistry::getInstance().getRegisteredEcoreModels().get("mc");
//		var generatable = PluginRegistry::getInstance().getRegisteredEcoreModels().get("generatable")
		var LightweightExecutionContext context = new DefaultLightweightExecutionContext(null)
		var ecoreMap = PluginRegistry::getInstance().getRegisteredEcoreModels() 
		var genModelMap = PluginRegistry::getInstance().getGenModelMap() //new HashMap<EPackage,String>
		prepareGraphModel(model)
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
		if(x.equals("default")){
			
			var ePackage = context.get("ePackage") as EPackage
			EPackage.Registry.INSTANCE.put(ePackage.nsURI,ePackage)
			var bops = new ByteArrayOutputStream()
			xmiResource.contents.add(ePackage)
			var optionMap = new HashMap<String,Object>
			optionMap.put(XMIResource.OPTION_URI_HANDLER,new URIHandler(ePackage))
			
			
			
						
			xmiResource.save(bops,optionMap)
			
			var output = bops.toString(xmiResource.getEncoding)
			var ecorePath = "/model/"+model.fullyQualifiedName.toString("/")+".ecore".toFirstUpper
			access.generateFile(ecorePath,output)
			var projectPath = new Path(projectName)
			var genModel = GenModelCreator::createGenModel(new Path(ecorePath),ePackage,projectName, projectID, projectPath)
			if(model.package!=null && model.package.length>0){
				for(genPackage: genModel.genPackages){
					genPackage.basePackage = model.package
				}
			
			}
			var usedEcoreModels = context.get("usedEcoreModels") as Set
			for(key:usedEcoreModels){
				var res = new XMIResourceImpl(URI::createURI(genModelMap.get(key))) 
				res.load(null)
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
			var exception = context.get("exception") as Exception
			exception.printStackTrace
			throw exception
		}else{
			
		}
		
	}
	
	def GraphModel prepareGraphModel(GraphModel graphModel){
		var connectableElements = new BasicEList<GraphicalModelElement>()
		//inheritContainable(graphModel.nodes.filter(NodeContainer))
		connectableElements.addAll(graphModel.nodes)
		//connectableElements.addAll(graphModel.nodeContainers)
		for(elem:connectableElements){
			for(connect:elem.incomingEdgeConnections){
				if(connect.connectingEdges.nullOrEmpty){
					connect.connectingEdges += graphModel.edges
				}
			}
			for(connect:elem.outgoingEdgeConnections){
				if(connect.connectingEdges.nullOrEmpty){
					connect.connectingEdges += graphModel.edges
				}
			}
		}
		if(graphModel.containableElements.nullOrEmpty){
			addNodes(graphModel,0,-1,graphModel.nodes);
		}else{
			findWildcard(graphModel,graphModel)
		}
		
		for(nc:graphModel.nodes.filter(NodeContainer)){
			if(nc.containableElements.nullOrEmpty){
			addNodes(nc,0,-1,graphModel.nodes);
		}else{
			findWildcard(nc,graphModel)
		}
		}
		
		return graphModel
		
		
	}
	
	def findWildcard(ContainingElement ce,GraphModel graphModel) {
		for(gec:ce.containableElements){
			if(gec.types.nullOrEmpty&&gec.upperBound!=0){
				addNodes(ce,0,-1,graphModel.nodes);
				return
			}
		}
	}
	
	
	
	def addNodes(ContainingElement ce,int lower, int upper, Node...nodes){
		var gec = MglFactory.eINSTANCE.createGraphicalElementContainment;
		gec.setLowerBound(lower);
		gec.setUpperBound(upper);
		gec.getTypes().addAll(Arrays.asList(nodes));
		ce.getContainableElements().add(gec);
		
	}
	
//	def inheritContainable(Iterable<NodeContainer> containers) {
//		for(container: containers){
//			var superType = (container.extends as NodeContainer)
//			while(superType!=null){
//				container.containableElements.addAll(superType.containableElements.map[ce| EcoreUtil2.copy(ce)])
//				
//				superType = (superType.extends as NodeContainer)	
//			}
//		}
//	}
	
}
