package de.jabc.cinco.meta.plugin.modelchecking.tmpl.builder

import de.jabc.cinco.meta.plugin.template.FileTemplate
import mgl.Attribute
import mgl.ModelElement
import mgl.UserDefinedType
import de.jabc.cinco.meta.plugin.modelchecking.util.ModelCheckingExtension

class ModelBuilderTmpl extends FileTemplate {

	override getTargetFileName() '''«model.name»ModelBuilder.java'''
	
	extension ModelCheckingExtension = new ModelCheckingExtension
	
	var boolean providerExists 
	
	override init(){
		providerExists = model.providerExists
	}

	override template() '''
		package «package»;
		
		import java.util.ArrayList;
		import java.util.Arrays;
		import java.util.HashSet;
		import java.util.List;
		import java.util.Set;
		import java.util.stream.Collectors;
		
		import org.eclipse.emf.common.util.EList;
		
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.kts.LinkedBasicCheckableNode;
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.model.*;	
		import de.jabc.cinco.meta.plugin.modelchecking.runtime.util.ModelCheckingRuntimeExtension;
		
		«IF providerExists»
		import «model.package + ".modelchecking.ProviderHandler"»;
		«ENDIF»
		import graphmodel.Edge;
		import graphmodel.Node;
		import graphmodel.ModelElement;
		
		public class «model.name»ModelBuilder implements ModelBuilder<«model.fqBeanName»> {
			
			private ModelCheckingRuntimeExtension xapi = new ModelCheckingRuntimeExtension();
			
			private ArrayList<String> includedEdgeTypes;
			private ArrayList<String> selectedIds;
			private boolean withSelection;
			«IF providerExists»
				ProviderHandler providerHandler;
			«ENDIF»
			
			public void init(boolean withSelection){
				selectedIds = xapi.getSelectedElementIds();
				this.withSelection = withSelection && selectedIds.size() != 0;
				includedEdgeTypes = getIncludedEdgeTypes();
				«IF providerExists»
				providerHandler = new ProviderHandler();
				«ENDIF»
			}
			
			@Override
			public void buildModel(«model.fqBeanName» model, CheckableModel<?,?> checkableModel, boolean withSelection){
				init(withSelection);
				if (checkableModel.getClass().toString()
						.equals("class de.jabc.cinco.meta.plugin.modelchecking.runtime.kts.TransitionsystemModel")) {
					ProgramGraph<Configuration> transitionSystem = (new «model.name»Translator()).execute(model);
				
					for (GraphNode<Configuration> n : transitionSystem.getNodes()) {
						checkableModel.addNewNode(n.getContentModelID(), transitionSystem.getStart().equals(n),
								getAtomicPropositions(n));
					}
					for (GraphEdge e : transitionSystem.getEdges()) {
						addEdge(checkableModel, e.getStart(), e.getEnd());
					}
				} else {
				
					Set<Node> supportNodes = new HashSet<>();
					Set<Node> includeNodesWithSupportNodeSuccs = new HashSet<>();
					Set<Node> includeNodesWithSupportNodePreds = new HashSet<>();
					Set<Node> includeNodes = new HashSet<>();
					
					«FOR node : supportNodes SEPARATOR '\n'»
					model.get«node.name»s().stream().filter(node -> toInclude(node))
					.forEach(node -> supportNodes.add(node));
					«ENDFOR»
					
					«FOR node : nodes.filter[!supportNode && model.canContain(it)] SEPARATOR '\n'»
					model.get«node.name»s().stream().filter(node -> toInclude(node))
					.forEach(node -> {
						«IF providerExists»
						if (providerHandler.isSupportNode(node)) {
							supportNodes.add(node);
						}else{
							includeNodes.add(node);
						}
						«ELSE»
						includeNodes.add(node);
						«ENDIF»
					});
					«ENDFOR»
					
					includeNodes.stream().filter(node -> node.getSuccessors().stream()
						.anyMatch(succ -> supportNodes.contains(succ))
					)
					.forEach(node -> includeNodesWithSupportNodeSuccs.add(node));
					
					includeNodes.stream().filter(node -> node.getPredecessors().stream()
						.anyMatch(pred -> supportNodes.contains(pred))
					)
					.forEach(node -> includeNodesWithSupportNodePreds.add(node));
					
					for (Node node : includeNodes) {
						checkableModel.addNewNode(node.getId(), isStartNode(node), getAtomicPropositions(node));
					}			
					
					for (Edge edge : model.getAllEdges()) {
						if (isRelevantEdge(edge)) {
							addEdge(checkableModel, edge.getSourceElement().getId(), edge.getTargetElement().getId(), getEdgeLabels(edge), includeNodes);
						}
					}
			
					«IF providerExists»
					for(Edge edge: providerHandler.getReplacementEdges(model)){
						if (isRelevantEdge(edge)) {
							addEdge(checkableModel, edge.getSourceElement().getId(), edge.getTargetElement().getId(), getEdgeLabels(edge), includeNodes);
						}
					}
					«ENDIF»	
					
					List<List<Node>> replacementPaths = new ArrayList<List<Node>>();
					for (Node node : includeNodesWithSupportNodeSuccs) {
						List<List<Node>> paths = xapi.findPathsToFirst(node, Node.class, n-> includeNodesWithSupportNodePreds.contains(n))
								.stream()
								.filter(path -> path.size() > 1)
								.filter(path -> path.subList(0, path.size()-2)
											.stream()
											.allMatch(supportNode -> supportNodes.contains(supportNode)))
								.collect(Collectors.toList());
						paths.forEach(path -> path.add(0, node));
						replacementPaths.addAll(paths);
					}
					
					for (List<Node>  path : replacementPaths) {
						«IF providerExists»
						Set<String> labels = providerHandler.getReplacementEdgeLabels(path, getEdgeLabelsOfPath(path));
						«ELSE»
						Set<String> labels = getEdgeLabelsOfPath(path);
						«ENDIF»
						addEdge(checkableModel, path.get(0).getId(), path.get(path.size() - 1).getId(), labels, includeNodes);
					}
				}
			}
			
			private <N,E> void addEdge(CheckableModel<N,E> checkableModel, String sourceId, String targetId, Set<String> labels, Set<Node> includeNodes){
				if (isAddableEdge(sourceId, targetId, includeNodes))
				checkableModel.addNewEdge(getNodeById(checkableModel, sourceId), getNodeById(checkableModel, targetId), labels);
			}
			
			«FOR node : nodes SEPARATOR '\n'»
				«templateGetAtomicPropositions(node, providerExists, false)»
			«ENDFOR»
			
			«FOR type : model.userDefinedTypes SEPARATOR '\n'»
				«templateGetAtomicPropositions(type, false, true)»
			«ENDFOR»
			
			private Set<String> getEdgeLabels(Edge edge){
				Set<String> edgeLabels = new HashSet<>();
				
				«FOR e:edges SEPARATOR '\n'»
				if (edge instanceof «e.fqBeanName»){
					edgeLabels = getEdgeLabels((«e.fqBeanName») edge);
				}
				«ENDFOR»
				
				edgeLabels.remove(null);
				return edgeLabels;				
			}
			
			private Set<String> getAtomicPropositions(Node node){
				Set<String> atomicPropositions = new HashSet<>();
				
				«FOR n:nodes SEPARATOR '\n'»
				if (node instanceof «n.fqBeanName»){
					atomicPropositions = getAtomicPropositions((«n.fqBeanName») node);
				}
				«ENDFOR»
				
				atomicPropositions.remove(null);
				return atomicPropositions;
			}
			
			private Set<String> getEdgeLabelsOfPath(List<Node> path){
				Set<String> labels = new HashSet<>();
				for(int i = 0; i<path.size()-1;i++) {
					final int index = i;
					Set<Edge> edges = path.get(index).getOutgoing().stream()
							.filter(edge -> edge.getTargetElement().equals(path.get(index+1)))
							.collect(Collectors.toSet());
					edges.stream().forEach(edge -> labels.addAll(getEdgeLabels(edge)));
				}
				
				return labels;
			}
			
			«FOR edge : edges SEPARATOR '\n'»
				«templateGetEdgeLabels(edge, providerExists, false)»
			«ENDFOR»
			
			«FOR type : model.userDefinedTypes SEPARATOR '\n'»
				«templateGetEdgeLabels(type, false, true)»
			«ENDFOR»			
			
			private ArrayList<String> getIncludedEdgeTypes(){
				ArrayList<String> edgeTypes = new ArrayList<>();
				
				«FOR e:edges»
					edgeTypes.add("«e.name»");
				«ENDFOR»
				
				return edgeTypes;
			}

			private boolean isStartNode(Node node) {
				«FOR node : nodes.filter[startNode] SEPARATOR '\n'»
				if (node instanceof «node.fqBeanName»){
					return true;
				}
				«ENDFOR»				
				return false;
			}
			
			private boolean isRelevantNode(Node node) {
				EList<Edge> incomingEdges = node.getIncoming();
				if(incomingEdges.size() > 0) {
					for (Edge edge : node.getIncoming()) {
						if (isRelevantEdge(edge)) {
							return true;
						}
					}
					return false;
				}
				return true;
			}
			
			private boolean isSelected(ModelElement element){
				return !withSelection || selectedIds.contains(element.getId());
			}
			
			private boolean toInclude(Node node){
				return isSelected(node) && isRelevantNode(node);
			}
			
			private boolean isAddableEdge(String sourceId, String targetId, Set<Node> includeNodes){
				return includeNodes.stream().map(node -> node.getId())
					.collect(Collectors.toSet())
					.containsAll(Arrays.asList(sourceId, targetId));
			}
			
			private boolean isRelevantEdge(Edge edge) {
				return includedEdgeTypes.contains(getType(edge));
			}
			
			private <N,E> N getNodeById(CheckableModel<N,E> checkableModel, String id) {
				return checkableModel.getNodes().stream()
					.filter(node -> checkableModel.getId(node).equals(id))
					.findFirst().orElse(null);
			}
			
			private String getType(ModelElement element) {
				return element.getClass().getSimpleName().substring(1);
			}
			
			// new:
			private <N, E> void addEdge(CheckableModel<N, E> checkableModel, GraphNode<Configuration> source,
						GraphNode<Configuration> target) {
					checkableModel.addNewEdge(getNodeFromModel(checkableModel, source), getNodeFromModel(checkableModel, target),
							new HashSet<>());
			}
			private <N, E> N getNodeFromModel(CheckableModel<N, E> checkableModel, GraphNode<Configuration> graphNode) {
					return checkableModel.getNodes().stream().filter(node -> {
						boolean equalId = checkableModel.getId(node).equals(graphNode.getContentModelID());
						LinkedBasicCheckableNode casted = (LinkedBasicCheckableNode) node;
			
						List<String> allPropsOfGraphNode = graphNode.getAdditionalData().keySet().stream()
								.filter(s -> graphNode.getAdditionalData().get(s)).collect(Collectors.toList());
			
						boolean containsAll1 = casted.getAtomicPropositions().containsAll(allPropsOfGraphNode);
						boolean containsAll2 = allPropsOfGraphNode.containsAll(casted.getAtomicPropositions());
			
						return equalId && containsAll1 && containsAll2;
					}).findFirst().orElse(null);
				}
		}
		
			private Set<String> getAtomicPropositions(GraphNode<Configuration> node) {
				return node.getAdditionalData().keySet().stream().filter(key -> node.getAdditionalData().get(key))
						.map(value -> value.toString()).collect(Collectors.toSet());
			}
	'''


	def templateGetAtomicPropositions(ModelElement element, boolean provider, boolean forType)'''
		private Set<String> getAtomicPropositions(«element.fqBeanName» element«IF forType», Set<String> visitedIds«ENDIF»){
			Set<String> atomicPropositions = new HashSet<>();			
			«IF provider»
				
				Set<String> providerAPs = providerHandler.doSwitch(element);
				if (providerAPs != null){
					atomicPropositions.addAll(providerAPs);
				}
			«ENDIF»			
			«FOR attr : element.getAPAttributes»
				
				«templateGetPrimitveAttribut(attr, "atomicPropositions")»
			«ENDFOR»			
			«IF !forType && element.userDefinedTypeAttributes.size > 0»
				
				Set<String> visitedIds = new HashSet<>();
			«ENDIF»			
			«FOR attr : element.userDefinedTypeAttributes»
				
				«templateGetUserDefinedTypeAttribute(attr, "atomicPropositions")»
			«ENDFOR»
			
			return atomicPropositions;
		}
	'''
	
	def templateGetEdgeLabels(ModelElement element, boolean provider, boolean forType)'''
		private Set<String> getEdgeLabels(«element.fqBeanName» element«IF forType», Set<String> visitedIds«ENDIF»){
			Set<String> edgeLabels = new HashSet<>();			
			«IF provider»
				
				Set<String> providerLabels = providerHandler.doSwitch(element);
				if (providerLabels != null){
					edgeLabels.addAll(providerLabels);
				}
			«ENDIF»						
			«FOR attr : element.edgeLabelAttributes»
				
				«templateGetPrimitveAttribut(attr, "edgeLabels")»
			«ENDFOR»			
			«IF !forType && element.userDefinedTypeAttributes.size > 0»
				
				Set<String> visitedIds = new HashSet<>();
			«ENDIF»			
			«FOR attr : element.userDefinedTypeAttributes»
				
				«templateGetUserDefinedTypeAttribute(attr, "edgeLabels")»
			«ENDFOR»
			
			return edgeLabels;
		}
	'''

	def templateGetPrimitveAttribut(Attribute attr, String fieldName)'''	
		«IF attr.list»
			for(Object prop : element.«getGetter(attr.name)»){
				if (prop != null){
					«fieldName».add(prop.toString());
				}
			}				
		«ELSE»
			if (element.«getGetter(attr.name)» != null){
				«fieldName».add(element.«getGetter(attr.name)».toString());
			}
		«ENDIF»		
	'''
	
	def templateGetUserDefinedTypeAttribute(Attribute attr, String fieldName)'''	
		«IF attr.list»
			for («(attr.type as UserDefinedType).fqBeanName» n : element.«attr.name.getter»){
				if (visitedIds.add(n.getId())) {
					«fieldName».addAll(get«fieldName.toFirstUpper»(n, visitedIds));
				}
			}
		«ELSE»
			if (element.«attr.name.getter» != null && visitedIds.add(element.«attr.name.getter».getId())) {
				«fieldName».addAll(get«fieldName.toFirstUpper»(element.«attr.name.getter», visitedIds));
			}
		«ENDIF»		
	'''

	def getNodes() {
		model.nodes.filter[!hasValidExcludeOption && !isIsAbstract].toList
	}
	
	def getSupportNodes(){
		model.nodes.filter[supportNode].toList
	}
	
	def getEdges(){
		model.edges.filter[!hasValidExcludeOption && !isIsAbstract].toList
	}
	
	def boolean hasValidExcludeOption(ModelElement element){
		if (element !== null){
			if (element.hasOption("include")) return false			
			if (element.hasOption("exclude")) return true
			
			return element.superType.hasValidExcludeOption
		}
		return model.hasOption("mcDefault", "exclude")		
	}
		
	def getAPAttributes(ModelElement element){
		element.getAttributesWithAnnotation("mcAtomicProposition")
	}
	
	def getEdgeLabelAttributes(ModelElement element){
		element.getAttributesWithAnnotation("mcEdgeLabel")
	}
	
	def getGetter(String attr){
		"get" + attr.substring(0,1).toUpperCase + attr.substring(1)+"()"
	}
}
