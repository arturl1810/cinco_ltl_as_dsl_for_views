package de.jabc.cinco.meta.plugin.papyrus.templates
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint
import java.util.HashMap
import java.util.Map.Entry
import mgl.GraphModel
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge
import de.jabc.cinco.meta.plugin.papyrus.model.EmbeddingConstraint
import mgl.GraphicalModelElement
import mgl.Type
import org.jgraph.graph.ConnectionSet.Connection

class EditorConstraintTemplate implements Templateable{

	
	def creatNodeGroup(Entry<String, ArrayList<StyledNode>> entry) 
	'''
		{
			group:'«entry.key.toFirstUpper»',
			nodes:[
			«FOR StyledNode node : entry.value SEPARATOR ','» 
			'«node.modelElement.name.toFirstUpper»'
			«ENDFOR»
			]
		}
	'''
	
	def createEmbaddingConstraints(EmbeddingConstraint embeddingConstraint)
	'''
		«FOR GraphicalModelElement gme : embeddingConstraint.validNode»
		if(embeddingName == '«gme.name.toFirstUpper»' && containerName == '«embeddingConstraint.container.name.toFirstUpper»'){
			«IF embeddingConstraint.highBound >= 1»
			var count = 0;
			for(var i=0;i<embeddedElements.length;i++) {
				if(embeddedElements[i].attributes.cinco_name === '«gme.name.toFirstUpper»') {
					count++;
				}
			}
			if(count < «embeddingConstraint.highBound»){
				return true;
			}
			«ELSE»
			return true;
			«ENDIF»
		}
		«ENDFOR»
		
	'''
	
	def createConnectingConstraints(ConnectionConstraint connection)
	'''
		if(sourceNodeType == '«connection.sourceNode.modelElement.name.toFirstUpper»' && targetNodeType == '«connection.targetNode.modelElement.name.toFirstUpper»'){
			«IF connection.sourceCardinalityHigh >= 1»
			var countSource = 0;
			for(var i = 0;i<sourceLinks.length;i++) {
				if(sourceLinks[i].attributes.cinco_name === '«connection.connectingEdge.modelElement.name.toFirstUpper»'){
					countSource++;
				}
			}
			«ENDIF»
			«IF connection.targetCardinalityHigh >= 1»
			var countTarget = 0;
			for(var i = 0;i<targetLinks.length;i++) {
				if(targetLinks[i].attributes.cinco_name === '«connection.connectingEdge.modelElement.name.toFirstUpper»'){
					countTarget++;
				}
			}
			«ENDIF»
			«IF connection.sourceCardinalityHigh < 1 && connection.targetCardinalityHigh < 1»
			return true;
			«ELSEIF connection.sourceCardinalityHigh >= 1 && connection.targetCardinalityHigh < 1»
			if(countSource < «connection.sourceCardinalityHigh» ){
				return true;
			}
			«ELSEIF connection.sourceCardinalityHigh < 1 && connection.targetCardinalityHigh >= 1»
			if(countTarget < «connection.targetCardinalityHigh» ){
				return true;
			}
			«ELSE»
			if(countSource < «connection.sourceCardinalityHigh» && countTarget < «connection.targetCardinalityHigh» ){
				return true;
			}
			«ENDIF»
		}
	'''
	
	def createEdgeCreation(ConnectionConstraint connection)
	'''
		if(sourceNodeType == '«connection.sourceNode.modelElement.name.toFirstUpper»' && targetNodeType == '«connection.targetNode.modelElement.name.toFirstUpper»'){
			var link = new joint.shapes.devs.«connection.connectingEdge.modelElement.name.toFirstUpper»({
			    source: sourceSelector, target: targetSelector
			});
			links.push({edge: link, name: '«connection.connectingEdge.modelElement.name.toFirstUpper»'});
		}
	'''
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints,ArrayList<Type> enums)
	'''
		/**
		 * Validates two Nodes, whether they can be embedded
		 * @param childView
		 * @param parentView
		 * @returns {boolean}
		 */
		function validateElementEmbadding(childView, parentView)
		{
			var embeddingName = childView.model.attributes.cinco_name;
			var containerName = parentView.model.attributes.cinco_name;
			var containerElement = graph.getCell(parentView.model.id);
			var embeddedElements = containerElement.getEmbeddedCells();
		    «FOR EmbeddingConstraint ec : embeddingConstraints»
		    «createEmbaddingConstraints(ec)»
		    «ENDFOR»
		    return false;
		}
		
		/**
		 * Validates two Nodes, whether they can be connected
		 * @returns {boolean}
		 * @param sourceNode
		 * @param targetNode
		 */
		function validateElementConnection(sourceNode,targetNode)
		{
			var sourceNodeType = sourceNode.options.model.attributes.cinco_name;
			var targetNodeType = targetNode.options.model.attributes.cinco_name;
			var sourceNodeElement = graph.getCell(sourceNode.model.id);
			var targetNodeElement = graph.getCell(targetNode.model.id);
			var sourceOpt ={outbound: true};
			var targetOpt = {inbound:true};
			var sourceLinks = graph.getConnectedLinks(sourceNodeElement,sourceOpt);
			var targetLinks = graph.getConnectedLinks(targetNodeElement,targetOpt);
		    «FOR ConnectionConstraint connection : validConnections»
	        «createConnectingConstraints(connection)»
			«ENDFOR»
		    return false;
		}
		
		/**
		 * Returns all approved edges to connect the given two node-types
		 * @param sourceNodeType
		 * @param sourceSelector
		 * @param targetNodeType
		 * @param targetSelector
		 * @returns {Array}
		 */
		function getConnectingEdge(sourceNodeType,sourceSelector,targetNodeType,targetSelector,edgeType)
		{
		    var links = [];
		
		    if(edgeType != null) {
		
		        var link = new joint.shapes.devs[edgeType+'']({
		            source: sourceSelector, target: targetSelector
		        });
		        links.push({edge: link, name: edgeType});
		        return links;
		    }
		    //Determine which connection should be created
		    «FOR ConnectionConstraint connection : validConnections»
			«createEdgeCreation(connection)»
			«ENDFOR»
		
		    return links;
		}
		
		/**
		 *
		 * @returns {string[]}
		 */
		function getAllNodeTypes()
		{
			return [
			«FOR group : groupedNodes.entrySet SEPARATOR ','»
	        «creatNodeGroup(group)»
			«ENDFOR»
		    ];
		}
		
		function styleElements(onInitiate) {
		/*	_.each(grap.getElements(), function(element){
				var cinco_name = element.attributes.cinco_name;
				if(cinco_name === 'Activity') {
					element.attr({'.body': {'rx':8, }})
				}
			});*/
		}
		
		/**
		 *
		 * @returns {{edge: Array, node: string[], container: Array, graphmodel: Array}}
		 */
		function getCustomeActions()
		{
		    return{
		        //TODO
		    };
		}
		
		graphName = '«graphModel.name.toFirstUpper»';
	'''
	
}