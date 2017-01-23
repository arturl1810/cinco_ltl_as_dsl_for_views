package de.jabc.cinco.meta.core.mgl.generator

import com.google.inject.Inject
import de.jabc.cinco.meta.core.mgl.MGLEPackageRegistry
import de.jabc.cinco.meta.core.mgl.transformation.MGL2Ecore
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.utils.URIHandler
import de.jabc.cinco.meta.core.utils.WorkspaceUtil
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import de.metaframe.jabc.framework.execution.DefaultLightweightExecutionEnvironment
import de.metaframe.jabc.framework.execution.context.DefaultLightweightExecutionContext
import de.metaframe.jabc.framework.execution.context.LightweightExecutionContext
import graphmodel.GraphmodelPackage
import java.io.ByteArrayOutputStream
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.HashSet
import java.util.Set
import mgl.ContainingElement
import mgl.GraphModel
import mgl.GraphicalElementContainment
import mgl.GraphicalModelElement
import mgl.IncomingEdgeElementConnection
import mgl.MglFactory
import mgl.Node
import mgl.NodeContainer
import mgl.OutgoingEdgeElementConnection
import mgl.impl.OutgoingEdgeElementConnectionImpl
import org.eclipse.core.internal.runtime.InternalPlatform
import org.eclipse.core.resources.IFile
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.EReference
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.xmi.XMIResource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.pde.core.project.IBundleProjectService
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.util.StringInputStream
import transem.utility.helper.Tuple

import static extension de.jabc.cinco.meta.core.utils.eapi.FileEAPI.*
import java.util.Map
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin

class MGLGenerator implements IGenerator {
	@Inject extension IQualifiedNameProvider
	

	override doGenerate(Resource input, IFileSystemAccess fsa) {
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
		
		var mglEPackages = MGLEPackageRegistry.INSTANCE.getMGLEPackages()
		prepareGraphModel(model)
		context.put("graphModel",model)
//		context.put("mcGraphModel",mcGraphModel)
		context.put("abstractGraphModel",interfaceGraphModel)
		context.put("genmodelMap",genModelMap)
		context.put("mglEPackages",mglEPackages);
		
		// These modeld should be added automatically in the final version
		
		
		context.put("registeredGeneratorPlugins",PluginRegistry::instance.pluginGenerators)
		context.put("registeredPackageMap",ecoreMap)
		
		var uri = URI::createFileURI(model.name.toString.toFirstUpper+".ecore")
		var xmiResource = new XMIResourceFactoryImpl().createResource(uri) as XMIResourceImpl
		context.put("resource",xmiResource)
		var environment = new DefaultLightweightExecutionEnvironment(context)
		context.put("ExecutionEnvironment",environment)
		var gdl2ecore = new MGL2Ecore
		//var String x= gdl2ecore.execute(environment);
		var x = "default"
		val altGen = new MGLAlternateGenerator()
		var ePackage = altGen.generateEcoreModel(model)
		generateFactory(altGen, model, access)
		saveEcoreModel(ePackage,model)
		if(x.equals("default")){
			
			// var ePackage = context.get("ePackage") as EPackage
			var ecorePath = "/model/"+model.fullyQualifiedName.toString("/")+".ecore".toFirstUpper
			val map = new HashMap
			map.put("graphModel", model)
			map.put("ePackage", ePackage)
			map.put("modelElements", altGen.modelElementsClasses)
			
			var projectPath = new Path(projectName)
			val genModel = GenModelCreator::createGenModel(new Path(ecorePath),ePackage,projectName, projectID, projectPath)
			genModel.computeMissingUsedGenPackages
			if(model.package!=null && model.package.length>0){
				for(genPackage: genModel.genPackages){
					genPackage.basePackage = model.package
				}
			}
			
			var usedEcoreModels = new HashSet<EPackage>
			
			
			val otherEcoreModels = context.get("usedEcoreModels") as Set<EPackage>
			if(otherEcoreModels!=null)
				usedEcoreModels += otherEcoreModels
			
			if(!usedEcoreModels.nullOrEmpty){ 
				for(key:usedEcoreModels){
					var res = new XMIResourceImpl(URI::createURI(genModelMap.get(key))) 
					res.load(null)
					for(genPackage:res.allContents.toIterable.filter(typeof(GenPackage))){
						
						genModel.usedGenPackages += genPackage	
					}
						
				}
			}
			
			var referencedMGLEPackages = context.get("referencedMGLEPackages") as Set<EPackage>
			if(referencedMGLEPackages== null)
				referencedMGLEPackages = new HashSet<EPackage>
				
			for(referencedMGLEPackage: referencedMGLEPackages){

				var genModelPath = referencedMGLEPackage.eResource.URI.trimFileExtension.toString+".genmodel"
				
		
				//System.err.println("************\n genmodel File: "+genModelPath +"\n*************")
				
					var genmodelUri = URI::createURI(genModelPath,true)
				//	println("loading GenModel: "+genmodelUri)
					var res = Resource.Factory.Registry.INSTANCE.getFactory(genmodelUri).createResource(genmodelUri); 
					res.load(null)
					for(referencedGenModel:res.contents.filter(typeof(GenModel))){
						
						//println("Adding genModel: "+ referencedGenModel)
						for(referencedGenPackage: referencedGenModel.genPackages){
							var dx = (genModel.usedGenPackages += referencedGenPackage)
							//println("Adding genPackage:"+ referencedGenPackage)
							//println("... "+ dx)
							//println(genModel.usedGenPackages)
						}	
					}
				
				
			}
			
			
			
			MGLEPackageRegistry.INSTANCE.addMGLEPackage(ePackage)
			saveGenModel(genModel, model)
			
		 	callMetaPlugins(model, map)
			
			
		}else if(x.equals("error")){
			var exception = context.get("exception") as Exception
			exception.printStackTrace
			throw exception
		}else{
			
		}
		
	}
	
	protected def void generateFactory(MGLAlternateGenerator altGen, GraphModel model, IFileSystemAccess access) {
		val factoryContent = altGen.createFactory(model) 
		val path = "/src-gen/" + model.package.replaceAll("\\.","/")+"/factory"
		val name = model.name+"Factory.xtend"
		val project = ProjectCreator.getProject(model.eResource)
		
		val fullPath = path+"/"+name
		val file = project.getFile(fullPath)
		if(!file.exists){
			 WorkspaceUtil.createResource(file,null)	
		}
		file.setContents(new StringInputStream(factoryContent.toString),true,true,null)
	}
	
	def saveEcoreModel(EPackage ePackage,GraphModel model) {
		EPackage.Registry.INSTANCE.put(ePackage.nsURI,ePackage)
		var outPath = ProjectCreator.getProject(model.eResource).fullPath.append("/src-gen/model/"+model.fullyQualifiedName+".ecore")	
		var uri = URI::createPlatformResourceURI(outPath.toString)
		
		var ePackageResource = Resource.Factory.Registry.INSTANCE.getFactory(uri).createResource(uri)
		ePackageResource.contents.add(ePackage)		
			var optionMap = new HashMap<String,Object>
			optionMap.put(XMIResource.OPTION_URI_HANDLER,new URIHandler(ePackage))
		ePackageResource.save(optionMap)	
			
			
						
			
	}
	
	def saveGenModel(GenModel genModel, GraphModel model){
		var outPath = ProjectCreator.getProject(model.eResource).fullPath.append("/src-gen/model/"+model.fullyQualifiedName+".genmodel")	
		var uri = URI::createURI(outPath.toString)
		var genModelResource = Resource.Factory.Registry.INSTANCE.getFactory(uri).createResource(uri)
		genModelResource.contents.add(genModel)
		genModelResource.save(null)
	}
	
	def GraphModel prepareGraphModel(GraphModel graphModel){
		var connectableElements = new BasicEList<GraphicalModelElement>()
		//inheritContainable(graphModel.nodes.filter(NodeContainer))
		connectableElements.addAll(graphModel.nodes)
		
		inheritAllConnectionConstraints(graphModel)
		
		//connectableElements.addAll(graphModel.nodeContainers)
		if(graphModel.edges.size!=0){
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
		}else{
			for(elem:connectableElements){
				elem.incomingEdgeConnections.clear
				elem.outgoingEdgeConnections.clear
			}
		}
		
		if(graphModel.containableElements.nullOrEmpty){
			addNodes(graphModel,0,-1,graphModel.nodes);
		}else{
			findWildcard(graphModel,graphModel)
		}
		
		for(nc:graphModel.nodes.filter(NodeContainer)){
			if(nc.containableElements.nullOrEmpty && nc.extends==null ){
			//addNodes(nc,0,-1,graphModel.nodes);
		}else{
			findWildcard(nc,graphModel)
		}
		}
		
		return graphModel
		
		
	}
	
	def inheritAllConnectionConstraints(GraphModel graphModel) {
		var inoutMap = new HashMap<Node,Tuple<ArrayList<IncomingEdgeElementConnection>,ArrayList<OutgoingEdgeElementConnection>>>;
		
		for(n: graphModel.nodes){
			val t = inheritConnectionConstraints(n)
			inoutMap.put(n,t);
		}
		for(n: inoutMap.keySet){
			val inout = inoutMap.get(n)
			n.incomingEdgeConnections.addAll(inout.left)
			n.outgoingEdgeConnections.addAll(inout.right)
		}
	}
	
	def inheritConnectionConstraints(Node node){
		var currentNode = node.extends
		var outgoingEdgeConnections = new ArrayList<OutgoingEdgeElementConnection>
		var incomingEdgeConnections = new ArrayList<IncomingEdgeElementConnection>
		while(currentNode!=null && currentNode!=node){
			var in = new ArrayList
			var out = new ArrayList  
			for(iec: currentNode.incomingEdgeConnections){
				var iecCopy = MglFactory.eINSTANCE.createIncomingEdgeElementConnection
				
				iecCopy.connectingEdges.addAll(iec.connectingEdges)
				iecCopy.upperBound = iec.upperBound
				iecCopy.lowerBound = iec.lowerBound
				//node.incomingEdgeConnections.add(iecCopy)
				in.add(iecCopy)
			}
			incomingEdgeConnections.addAll(in)
			for(oec: currentNode.outgoingEdgeConnections){
				var oecCopy = MglFactory.eINSTANCE.createOutgoingEdgeElementConnection
				//oecCopy.connectedElement = MglFactory.eINSTANCE.create(oec.connectedElement.eClass) as GraphicalModelElement
				oecCopy.connectingEdges.addAll(oec.connectingEdges)
				oecCopy.upperBound = oec.upperBound
				oecCopy.lowerBound = oec.lowerBound
				//node.outgoingEdgeConnections.add(oecCopy)
				out.add(oecCopy)
			}
			outgoingEdgeConnections.addAll(out)
			currentNode = currentNode.extends
		}
		return new Tuple<ArrayList<IncomingEdgeElementConnection>,ArrayList<OutgoingEdgeElementConnection>>(incomingEdgeConnections,outgoingEdgeConnections)
	}
	
	def findWildcard(ContainingElement ce,GraphModel graphModel) {
		for(gec:ce.containableElements){
			if(gec.types.nullOrEmpty){
				addNodes(ce,gec.lowerBound,gec.upperBound,graphModel.nodes);
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
	
	/**
	 * Collects the Metaplugins registered at the current {@link GraphModel} and executes them
	 * 
	 * @param mgl: The file representing the currently processed {@link GraphModel}
	 * @param metaPluginParams: See {@link de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin#execute IMetaPlugin}
	 */
	def callMetaPlugins(GraphModel gm, Map<String, Object> metaPluginParams) {
		val generators = PluginRegistry.instance.pluginGenerators
		val annotNames = gm.annotations.map[name]
		val registeredMetaPlugins = generators.filter[name, mp | annotNames.contains(name)]
		
		registeredMetaPlugins.forEach[name, mp | mp.execute(metaPluginParams)]
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
