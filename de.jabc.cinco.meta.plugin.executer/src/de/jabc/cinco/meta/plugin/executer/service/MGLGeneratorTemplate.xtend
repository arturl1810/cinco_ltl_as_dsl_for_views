package de.jabc.cinco.meta.plugin.executer.service

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import mgl.Annotatable
import mgl.GraphModel

class MGLGenerator {
	
	def getProjectName(ExecutableGraphmodel ex)
	{
		return '''Executable«ex.name»'''
	}
	
	def create(ExecutableGraphmodel graphmodel)
	'''
	@postCreate("«graphmodel.package».executable.hooks.CreateGraphModelHook")
	@style("model/«graphmodel.projectName».style")
	graphModel «graphmodel.projectName» {
		package «graphmodel.package».executable
		nsURI "«graphmodel.nsUri»/executable"
		diagramExtension "«graphmodel.extension»Exe"
		
		containableElements (
			MetaStates[1,1],
			MetaTransitions[1,1]
		)
		
		//Meta Elements
		
		@style(metaElement,"MetaStates")
		@disable(create,delete)
		container MetaStates {
			containableElements (
				Initializing[0,*]
				Default[1,*]
				Terminating[0,*]
			)
		}
		
		@style(metaElement,"MetaTransitions")
		@disable(create,delete)
		container MetaTransitions {
			containableElements (
				MetaTransition[1,*]
			)
		}
		
		// Meta States
		abstract container StateContainer {
			containableElements(
				«FOR node:graphmodel.nodes»
				«node.modelElement.name»[0,*]
				«ENDFOR»
				PlaceholderContainer[0,1]
				SourceConnector[0,1]
				TargetConnector[0,1]
			)
		}
		
		@style(stateContainer,"Initializing")
		container Initializing extends StateContainer{}
		
		@style(stateContainer,"Default")
		container Default extends StateContainer{}
		
		@style(stateContainer,"Terminating")
		container Terminating extends StateContainer{}
		
		//Meta Transitions
		
		@style(stateContainer,"Passing")
		container MetaTransition {
			containableElements(
				SourceConnector[0,1]
				TargetConnector[0,1]
			)
		}
		
		@style(connector,"Source")
		node SourceConnector {
			outgoing(*[1,*])
		}
		
		@style(connector,"Target")
		node TargetConnector {
			incoming(*[1,*])
		}
		
		//Placeholders 
		
		@style(placeholderContainer)
		container PlaceholderContainer extends ExecutableContainer {}
		
		@style(placeholderEdge)
		edge PlaceholderEdge extends ExecutableEdge {}
		
		//Nodes
		
		abstract node ExecutableNode {
			attr EBoolean as executable := false
		}
		«FOR node:graphmodel.exclusivelyNodes»
		«{
			var n = node.modelElement
			'''
			«n.style»
			node «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableNode«ENDIF» {
				
				incoming (
					«FOR edge:node.outgoing»
					«edge.modelElement.name»[0,*]
					«ENDFOR»
					PlaceholderEdge[0,1]
				)
				outgoing (
					«FOR edge:node.incoming»
					«edge.modelElement.name»[0,*]
					«ENDFOR»
					PlaceholderEdge[0,1]
				)
			}
			'''	
		}»
		«ENDFOR»
		
		//Container
		
		abstract container ExecutableContainer {
			attr EBoolean as executable := false
		}
		«FOR node:graphmodel.containers»
		«{
			var n = node.modelElement
			'''
			«n.style»
			container «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableContainer«ENDIF» {
				
				incoming (
					«FOR edge:node.outgoing»
					«edge.modelElement.name»[0,*]
					«ENDFOR»
					PlaceholderEdge[0,1]
				)
				outgoing (
					«FOR edge:node.incoming»
					«edge.modelElement.name»[0,*]
					«ENDFOR»
					PlaceholderEdge[0,1]
				)
				
				containableElements(
					«FOR cn:node.containableNodes»
					«cn.modelElement.name»[0,*]
					«ENDFOR»
					PlaceholderContainer[0,1]
				)
			}
			'''	
		}»
		«ENDFOR»
		
		//Edges
		
		abstract edge ExecutableEdge {
			attr EBoolean as executable := false
		}
		
		«FOR node:graphmodel.edges»
		«{
			var n = node.modelElement
			'''
			«n.style»
			edge «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableEdge«ENDIF» {}
			'''	
		}»
		«ENDFOR»
	}
	'''
	
	def String getStyle(Annotatable annotatable)
	{
		val anno = annotatable.annotations.filter[n|n.name.equals("style")].get(0);	
		return '''@style(«anno.name»,«anno.value.map[n|n.statify].join('''"''','''"''',''',''')[n|n]»)''';
	}
	
	def String getStatify(String string) {
		if(string.contains("${"))return "";
		return string;
	}
	
	
	def String getPackage(ExecutableGraphmodel graphmodel)
	{
		return (graphmodel.modelElement as GraphModel).package;
	}
	
	def String getExtension(ExecutableGraphmodel graphmodel)
	{
		return (graphmodel.modelElement as GraphModel).fileExtension;
	}
	
	def String getNsUri(ExecutableGraphmodel graphmodel)
	{
		return (graphmodel.modelElement as GraphModel).nsURI;
	}
	
	def String getName(ExecutableGraphmodel graphmodel)
	{
		return (graphmodel.modelElement as GraphModel).name;
	}
	
}