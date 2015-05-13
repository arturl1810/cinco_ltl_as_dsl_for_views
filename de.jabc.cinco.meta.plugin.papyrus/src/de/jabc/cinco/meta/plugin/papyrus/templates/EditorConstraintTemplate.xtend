package de.jabc.cinco.meta.plugin.papyrus.templates
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.papyrus.model.StyledNode
import de.jabc.cinco.meta.plugin.papyrus.model.ConnectionConstraint
import java.util.HashMap
import java.util.Map.Entry
import mgl.GraphModel
import de.jabc.cinco.meta.plugin.papyrus.model.StyledEdge

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
	
	def createEmbaddingConstraints()
	'''
		return true;
	'''
	
	def createConnectingConstraints(ConnectionConstraint connection)
	'''
		if(sourceNodeType == '«connection.sourceNode.modelElement.name.toFirstUpper»' && targetNodeType == '«connection.targetNode.modelElement.name.toFirstUpper»'){
			//TODO Cardinalities
		    return true;
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
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections)
	'''
		/**
		 * Validates two Nodes, whether they can be embedded
		 * @param childView
		 * @param parentView
		 * @returns {boolean}
		 */
		function validateElementEmbadding(childView, parentView)
		{
		    return true;
		}
		
		/**
		 * Validates two Nodes, whether they can be connected
		 * @param sourceType
		 * @param targetType
		 * @returns {boolean}
		 */
		function validateElementConnection(sourceNodeType,targetNodeType)
		{
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