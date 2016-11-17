package de.jabc.cinco.meta.plugin.executer.service

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel


import mgl.Annotatable

import mgl.GraphicalModelElement
import mgl.Edge
import mgl.Node
import mgl.ModelElement
import org.eclipse.emf.common.util.EList
import mgl.Annotation
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode
import mgl.ReferencedType
import mgl.Import

class MGLGenerator {
	
	
	
	def create(ExecutableGraphmodel graphmodel)
	'''
	«FOR i:graphmodel.graphModel.imports.filter[isMGL]»
	«IF i.stealth»stealth «ENDIF»import «i.importURI»ES«IF !i.name.nullOrEmpty» as «i.name»«ENDIF»;
	«ENDFOR»
	@postCreate("«graphmodel.package».CreateGraphModelHook")
	@primeviewer
	@style("model/«graphmodel.projectName».style")
	graphModel «graphmodel.projectName» {
		package «graphmodel.package»
		nsURI "«graphmodel.nsUri»"
		diagramExtension "«graphmodel.extension»es"
		
		containableElements (
			MetaStates[1,1],
			MetaTransitions[1,1]
		)
		
		//Meta Elements
		
		@style(metaElement,"MetaStates")
		@disable(create,delete)
		container MetaStates {
			containableElements (
				Initializing[0,*],
				Default[1,*],
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
		abstract container Pattern {
			attr EString as label
			attr EBoolean as executable := false
			containableElements(
				ExecutableNode[0,*],
				PlaceholderContainer[0,1],
				SourceConnector[0,1],
				TargetConnector[0,1]
			)
		}
		
		abstract node ReferencedPattern {
			attr Compare as compare
			// -1 represents the start *
			attr EInt as border
		}
		
		@style(stateContainer,"${stateContainer.label}")
		node ReferencedInitializing extends ReferencedPattern {
			prime this::Initializing as stateContainer
		}
		
		@style(stateContainer,"Initializing")
		container Initializing extends Pattern{}
		
		@style(stateContainer,"${stateContainer.label}")
		node ReferencedDefault extends ReferencedPattern {
			prime this::Default as stateContainer
			
		}
		
		@style(stateContainer,"Default")
		container Default extends Pattern{}
		
		@style(stateContainer,"${stateContainer.label}")
		node ReferencedTerminating extends ReferencedPattern {
			prime this::Terminating as stateContainer
		}
		
		@style(stateContainer,"Terminating")
		container Terminating extends Pattern{}
		
		//Meta Transitions
		
		@style(stateContainer,"Transition")
		container MetaTransition extends Pattern {

		}
		
		@style(stateContainer,"${stateContainer.label}")
		node ReferencedMetaTransition extends ReferencedPattern {
			prime this::MetaTransition as metaTransition
		}
		
		@style(connector,"Source")
		node SourceConnector {
			outgoingEdges(*[1,1])
		}
		
		@style(connector,"Target")
		node TargetConnector {
			incomingEdges(*[1,1])
		}
		
		//Placeholders 
		
		@style(placeholderContainer)
		container PlaceholderContainer extends ExecutableContainer {}
		
		@style(placeholderEdge)
		edge PlaceholderEdge extends ExecutableEdge {}
		
		//Nodes
		
		abstract node ExecutableNode {
			attr EBoolean as start := false
		}
		«FOR node:graphmodel.exclusivelyNodes»
		«{
			var n = node.modelElement
			'''
			«n.style»
			node «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableNode«ENDIF» {
				«IF n.isPrime»
				«n.primeReference.annotations.getPvAnnotation("pvLabel","")»
				«n.primeReference.annotations.getPvAnnotation("pvFileExtension","es")»
				prime «n.primeReference.type»
				attr EBoolean as hasInnerLevelState := false
				«ENDIF»
				«node.inAndOut»
			}
			'''	
		}»
		«ENDFOR»
		
		//Container
		
		abstract container ExecutableContainer {
			attr EBoolean as start := false
			attr EBoolean as hasInterlevelState := false
		}
		«FOR node:graphmodel.containers»
		«{
			var n = node.modelElement
			'''
			«n.style»
			container «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableContainer«ENDIF» {
				
				«node.inAndOut»
				
				containableElements(
					«FOR cn:node.containableNodes»
					«cn.modelElement.name»[0,*],
					«ENDFOR»
					PlaceholderContainer[0,1]
				)
			}
			'''	
		}»
		«ENDFOR»
		
		//Edges
		enum Compare {
			EQ L LEQ G GEQ
		}
		
		abstract edge ExecutableEdge {
			attr EBoolean as start := false
			attr Compare as compare
			// -1 represents the start *
			attr EInt as border
		}
		
		«FOR edge:graphmodel.edges»
		«{
			var e = edge.modelElement
			'''
			«e.style»
			edge «e.name» extends «IF edge.parent != null»«edge.parent.modelElement.name»«ELSE»ExecutableEdge«ENDIF» {}
			'''	
		}»
		«ENDFOR»
	}
	'''
	
	def void getType(ReferencedType type){
		
	}
	
	def boolean getIsPrime(Node node)
	{
		return false;	
	}
	
	def boolean getIsMGL(Import i) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def String getExtension(ExecutableGraphmodel graphmodel)
	{
		
	}
	
	
	def void getProjectName(ExecutableGraphmodel graphmodel){
		
	}
	
	def void getPackage(ExecutableGraphmodel graphmodel){
		
	}
	
	def void getNsUri(ExecutableGraphmodel graphmodel){
		
	}
	
	
	def String getPvAnnotation(EList<Annotation> list,String anno,String suffix){
		var arg = list.filter[it.name.equals(anno)].get(0).value.get(0);
		return '''@«anno»("«arg»«suffix»")'''
	}
	
	def String getStyle(ModelElement annotatable)
	{
		if(annotatable.isIsAbstract){
			var style = ""
			switch(annotatable){
				case Edge:style="defaultEdge"
				default:style="defaultNode"
			}
			return '''@style(«style»,"«annotatable.name»")'''
		}
		val anno = annotatable.annotations.filter[n|n.name.equals("style")].get(0);	
		return '''@style(«anno.value.get(0)»«IF anno.value.size>1»,«anno.value.drop(1).map[n|n.statify].join('''"''',''',''','''"''')[n|n]»«ENDIF»)''';
	}
	
	def String getStatify(String string) {
		if(string.contains("${"))return "";
		return string;
	}
	
	def String inAndOut(ExecutableNode node)
	'''
	incomingEdges (
	«FOR edge:node.incoming.groupBy[entry|entry.modelElement.name].entrySet»
		«edge.key»[0,*],
	«ENDFOR»
		PlaceholderEdge[0,1]
	)
	outgoingEdges (
	«FOR edge:node.outgoing.groupBy[entry|entry.modelElement.name].entrySet»
		«edge.key»[0,*],
	«ENDFOR»
	PlaceholderEdge[0,1]
	)
	'''
	
	
	
	
}