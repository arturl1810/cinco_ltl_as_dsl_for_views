package de.jabc.cinco.meta.core.mgl.generator

import com.google.inject.Inject
import de.jabc.cinco.meta.core.mgl.MGLEPackageRegistry
import de.jabc.cinco.meta.core.pluginregistry.IMetaPlugin
import de.jabc.cinco.meta.core.pluginregistry.PluginRegistry
import de.jabc.cinco.meta.core.utils.GeneratorHelper
import de.jabc.cinco.meta.core.utils.URIHandler
import de.jabc.cinco.meta.core.utils.projects.ProjectCreator
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap
import java.util.HashSet
import java.util.Map
import mgl.ContainingElement
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.IncomingEdgeElementConnection
import mgl.MglFactory
import mgl.Node
import mgl.NodeContainer
import mgl.OutgoingEdgeElementConnection
import org.eclipse.core.internal.runtime.InternalPlatform
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.Path
import org.eclipse.emf.codegen.ecore.genmodel.GenModel
import org.eclipse.emf.codegen.ecore.genmodel.GenPackage
import org.eclipse.emf.common.util.BasicEList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EPackage
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.xmi.XMIResource
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.pde.core.project.IBundleProjectService
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.util.StringInputStream
import transem.utility.helper.Tuple
import org.eclipse.core.runtime.IPath
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension
import de.jabc.cinco.meta.core.utils.projects.ContentWriter

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

		(input.contents.head as GraphModel)?.doGenerateEcoreByTransformation(projectName, projectID, fsa, resourceUri,MGLEPackageRegistry.INSTANCE.MGLEPackages)
	}

	private def doGenerateEcoreByTransformation(GraphModel model, String projectName, String projectID,
		IFileSystemAccess access, URI resourceURI, Iterable<EPackage> mglEPackages) {

		var genModelMap = PluginRegistry::getInstance().getGenModelMap()

		prepareGraphModel(model)

		val altGen = new MGLAlternateGenerator()
		var ePackage = altGen.generateEcoreModel(model,mglEPackages).head
		generateFactory(altGen, model, access)
		generateAdapter(altGen, model, access)
		saveEcoreModel(ePackage, model)

		var ecorePath = "/model/" + model.fullyQualifiedName.toString("/") + ".ecore".toFirstUpper
		val map = new HashMap
		map.put("graphModel", model)
		map.put("ePackage", ePackage)
		map.put("modelElements", altGen.modelElementsClasses)

		var projectPath = new Path(projectName)
		val genModel = model.generateGenModel(ecorePath,ePackage,projectName, projectID, projectPath)

		var usedEcoreModels = new HashSet<EPackage>

		if (!usedEcoreModels.nullOrEmpty) {
			for (key : usedEcoreModels) {
				var res = new XMIResourceImpl(URI::createURI(genModelMap.get(key)))
				res.load(null)
				for (genPackage : res.allContents.toIterable.filter(typeof(GenPackage))) {

					genModel.usedGenPackages += genPackage
				}

			}
		}

		MGLEPackageRegistry.INSTANCE.addMGLEPackage(ePackage)
		saveGenModel(genModel, model)
		GeneratorHelper.generateGenModelCode(genModel)
		callMetaPlugins(model, map)
		
		

	}

	protected def void generateFactory(MGLAlternateGenerator altGen, GraphModel model, IFileSystemAccess access) {
		val factoryContent = altGen.createFactory(model)
		val path = "/src-gen/" + model.package.replaceAll("\\.", "/") + "/factory"
		val name = model.name + "Factory.xtend"
		val project = ProjectCreator.getProject(model.eResource)
		val packageName=model.package
		ProjectCreator.exportPackage(project,packageName+".factory")
		val fullPath = path + "/" + name
		val file = project.getFile(fullPath)
		if (!file.exists) {
			new WorkspaceExtension().create(file)
		}
		file.setContents(new StringInputStream(factoryContent.toString), true, true, null)
	}
	
	protected def void generateAdapter(MGLAlternateGenerator altGen, GraphModel model, IFileSystemAccess access) {
		val project = ProjectCreator.getProject(model.eResource)
		val packageName = model.package + ".adapter"
		var adapterContent = altGen.createAdapter(model)
		var fileName = model.name + "EContentAdapter.xtend"
		ContentWriter::writeFile(project,"src-gen",packageName,fileName,adapterContent.toString)
		for (n : model.nodes + model.edges) {
			fileName = n.name + "EContentAdapter.xtend"
			adapterContent = altGen.createAdapter(n)
			ContentWriter::writeFile(project,"src-gen",packageName,fileName,adapterContent.toString)
		}
	}

	def saveEcoreModel(EPackage ePackage, GraphModel model) {

		EPackage.Registry.INSTANCE.put(ePackage.nsURI, ePackage)
		var outPath = ProjectCreator.getProject(model.eResource).fullPath.append(
			"/src-gen/model/" + model.fullyQualifiedName + ".ecore")
		var uri = URI::createURI(outPath.toString)
		var ePackageResource = model.eResource.resourceSet.createResource(uri)
		ePackageResource.contents += ePackage
		var optionMap = new HashMap<String, Object>
		optionMap.put(XMIResource.OPTION_URI_HANDLER, new URIHandler(ePackage))
		ePackageResource.save(optionMap)

	}

	def saveGenModel(GenModel genModel, GraphModel model) {
		var outPath = ProjectCreator.getProject(model.eResource).fullPath.append(
			"/src-gen/model/" + model.fullyQualifiedName + ".genmodel")
		var uri = URI::createURI(outPath.toString)
		var genModelResource = model.eResource.resourceSet.createResource(uri)
		genModelResource.contents.add(genModel)
		genModelResource.save(null)
	}

	def GraphModel prepareGraphModel(GraphModel graphModel) {
		var connectableElements = new BasicEList<GraphicalModelElement>()
		connectableElements.addAll(graphModel.nodes)

		inheritAllConnectionConstraints(graphModel)

		if (graphModel.edges.size != 0) {
			for (elem : connectableElements) {
				for (connect : elem.incomingEdgeConnections) {
					if (connect.connectingEdges.nullOrEmpty) {
						connect.connectingEdges += graphModel.edges
					}
				}
				for (connect : elem.outgoingEdgeConnections) {
					if (connect.connectingEdges.nullOrEmpty) {
						connect.connectingEdges += graphModel.edges
					}
				}
			}
		} else {
			for (elem : connectableElements) {
				elem.incomingEdgeConnections.clear
				elem.outgoingEdgeConnections.clear
			}
		}

		if (graphModel.containableElements.nullOrEmpty) {
			addNodes(graphModel, 0, -1, graphModel.nodes);
		} else {
			findWildcard(graphModel, graphModel)
		}

		for (nc : graphModel.nodes.filter(NodeContainer)) {
			if (nc.containableElements.nullOrEmpty && nc.extends == null) {
			} else {
				findWildcard(nc, graphModel)
			}
		}

		return graphModel

	}

	def inheritAllConnectionConstraints(
		GraphModel graphModel) {
		var inoutMap = new HashMap<Node, Tuple<ArrayList<IncomingEdgeElementConnection>, ArrayList<OutgoingEdgeElementConnection>>>;

		for (n : graphModel.nodes) {
			val t = inheritConnectionConstraints(n)
			inoutMap.put(n, t);
		}
		for (n : inoutMap.keySet) {
			val inout = inoutMap.get(n)
			n.incomingEdgeConnections.addAll(inout.left)
			n.outgoingEdgeConnections.addAll(inout.right)
		}
	}

	def inheritConnectionConstraints(Node node) {
		var currentNode = node.extends
		var outgoingEdgeConnections = new ArrayList<OutgoingEdgeElementConnection>
		var incomingEdgeConnections = new ArrayList<IncomingEdgeElementConnection>
		while (currentNode != null && currentNode != node) {
			var in = new ArrayList
			var out = new ArrayList
			for (iec : currentNode.incomingEdgeConnections) {
				var iecCopy = MglFactory.eINSTANCE.createIncomingEdgeElementConnection

				iecCopy.connectingEdges.addAll(iec.connectingEdges)
				iecCopy.upperBound = iec.upperBound
				iecCopy.lowerBound = iec.lowerBound
				in.add(iecCopy)
			}
			incomingEdgeConnections.addAll(in)
			for (oec : currentNode.outgoingEdgeConnections) {
				var oecCopy = MglFactory.eINSTANCE.createOutgoingEdgeElementConnection
				oecCopy.connectingEdges.addAll(oec.connectingEdges)
				oecCopy.upperBound = oec.upperBound
				oecCopy.lowerBound = oec.lowerBound
				out.add(oecCopy)
			}
			outgoingEdgeConnections.addAll(out)
			currentNode = currentNode.extends
		}
		return new Tuple<ArrayList<IncomingEdgeElementConnection>, ArrayList<OutgoingEdgeElementConnection>>(
			incomingEdgeConnections, outgoingEdgeConnections)
	}

	def findWildcard(ContainingElement ce, GraphModel graphModel) {
		for (gec : ce.containableElements) {
			if (gec.types.nullOrEmpty) {
				addNodes(ce, gec.lowerBound, gec.upperBound, graphModel.nodes);
				return
			}
		}
	}

	def addNodes(ContainingElement ce, int lower, int upper, Node... nodes) {
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
	 * @param metaPluginParams: See {@link IMetaPlugin#execute IMetaPlugin}
	 */
	def callMetaPlugins(GraphModel gm, Map<String, Object> metaPluginParams) {
		val generators = PluginRegistry.instance.pluginGenerators
		val annotNames = gm.annotations.map[name]
		val registeredMetaPlugins = generators.filter[name, mp|annotNames.contains(name)]

		registeredMetaPlugins.forEach[name, mp|mp.execute(metaPluginParams)]
	}
	
	
	def generateGenModel(GraphModel model, String ecorePath, EPackage ePackage, String projectName, String projectID, IPath projectPath){
		val genModel = GenModelCreator::createGenModel(new Path(ecorePath), ePackage, projectName, projectID,
			projectPath)
		val genResource = model.eResource.resourceSet.createResource(
			URI.createURI("platform:/resource/de.jabc.cinco.meta.core.mgl.model/model/GraphModel.genmodel"))
		genResource.load(null)
		val graphModelGenModel = (genResource.contents.get(0) as GenModel)

		genModel.usedGenPackages += graphModelGenModel.genPackages

		if (model.package != null && model.package.length > 0) {
			for (genPackage : genModel.genPackages) {
				genPackage.basePackage = model.package
			}
		}
		return genModel
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
