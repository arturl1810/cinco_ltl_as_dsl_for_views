package de.jabc.cinco.meta.plugin.executer.generator.model

import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableGraphmodel
import de.jabc.cinco.meta.plugin.executer.compounds.ExecutableNode
import mgl.Annotation
import mgl.Edge
import mgl.Import
import mgl.ModelElement
import mgl.NodeContainer
import mgl.ReferencedModelElement
import mgl.ReferencedType
import org.eclipse.emf.common.util.EList
import de.jabc.cinco.meta.plugin.executer.generator.tracer.MainTemplate

import static extension de.jabc.cinco.meta.core.utils.MGLUtil.*

class MGLGenerator extends MainTemplate{
	
	
	
	new(ExecutableGraphmodel graphmodel) {
		super(graphmodel)
	}
	
	override create(ExecutableGraphmodel graphmodel)
	'''
	«FOR i:graphmodel.graphModel.imports.filter[isMGL]»
	«IF i.stealth»stealth «ENDIF»import «i.importURI»ES«IF !i.name.nullOrEmpty» as «i.name»«ENDIF»;
	«ENDFOR»
«««	@postCreate("«graphmodel.package».CreateGraphModelHook")
	@primeviewer
	@style("model/«graphmodel.projectName».style")
	graphModel «graphmodel.projectName» {
		package «graphmodel.package»
		nsURI "«graphmodel.nsUri»"
		diagramExtension "«graphmodel.extension»"
		
		containableElements (
			MetaLevel[1,*]
		)
		
		//Meta Level
		
		@style(metaElement,"${label}")
		container MetaLevel {
			attr EString as label
			containableElements (
				Initializing[1,*],
				Default[0,*],
				Terminating[1,*],
				MetaTransition[1,*]
			)
		}
		
		@style(metaElement,"${level.label}")
		node ReferencedMetaLevel {
			@pvLabel("label")
			@pvFileExtension(".«graphmodel.extension»")
			prime this::MetaLevel as level
		}
		
		// Meta Pattern
		abstract container Pattern {
			attr EString as label
			attr EBoolean as executable := false
			containableElements(
				ExecutableNode[0,*],
				ExecutableContainer[0,*],
				PlaceholderContainer[0,1],
				SourceConnector[0,*],
				TargetConnector[0,*]
			)
		}
		
		@style(stateContainer,"Initializing")
		container Initializing extends Pattern{}
		
		@style(stateContainer,"Default")
		container Default extends Pattern{}
		
		@style(stateContainer,"Terminating")
		container Terminating extends Pattern{}
		
		//Meta Transitions
		
		@style(stateContainer,"Transition")
		container MetaTransition extends Pattern {}
		
		enum BorderElement {
			NONE START END START_AND_END
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
			attr BorderElement as border
		}
		
		«FOR node:graphmodel.exclusivelyNodes»
		«{
			var n = node.modelElement
			'''
			«n.style»
			node «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableNode«ENDIF» {
				
				«node.inAndOut»
			}
			«IF n.isPrime»
			«n.style»
			node «n.name»OuterLevelState extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableNode«ENDIF» {
				
				@pvLabel("label")
				@pvFileExtension(".«graphmodel.extension»")
				prime this::MetaLevel as level
				
				
				«node.inAndOut»
				
			}
			«ENDIF»
			'''	
		}»
		«ENDFOR»
		
		//Container
		
		abstract container ExecutableContainer {
			attr BorderElement as border
		}
		
		
		«FOR node:graphmodel.containers»
		«{
			var n = node.modelElement as NodeContainer
			'''
			«n.style»
			container «n.name» extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableContainer«ENDIF» {
				
				«node.inAndOut»
				
				containableElements(
					«FOR cn:node.containableNodes SEPARATOR ","»
					«cn.modelElement.name»[0,*]
					«ENDFOR»
				)
			}
			
			«n.style»
			container «n.name»InnerLevelState extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableContainer«ENDIF» {
				
				«node.inAndOut»
				
				containableElements(
					ReferencedMetaLevel[1,1]
				)
			}
			«IF n.isPrime»
			container «n.name»OuterLevelState extends «IF node.parent != null»«node.parent.modelElement.name»«ELSE»ExecutableContainer«ENDIF» {
				
				@pvLabel("label")
				@pvFileExtension(".«graphmodel.extension»")
				prime this::MetaLevel as level
								
				«node.inAndOut»
				
				containableElements(*[0,0])
			}
			«ENDIF»
			'''	
		}»
		«ENDFOR»
		
		//Edges
		enum Compare {
			EQ L LEQ G GEQ
		}
		
		@style(defaultEdge,"")
		edge ExecutableEdge {
			
			attr BorderElement as border
			
			attr Compare as compare
			// -1 represents the start *
			attr EInt as cardinality
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
	
	def String getType(ReferencedType type){
		var s = "";
		if(!type.importURI.nullOrEmpty){
			s+=type.importURI;
		}
		if(type.imprt != null){
			if (!type.imprt.name.nullOrEmpty){
				s+=type.imprt.name;
			}
		}
		if(s.nullOrEmpty){
			s+="this";
		}
		var t = "";
		if(type instanceof ReferencedModelElement){
			t = type.type.name;
		}
		return s+"::"+t+" as "+type.name
	}
	
	
	
	def boolean getIsPrime(NodeContainer nodeContainer)
	{
		return nodeContainer.retrievePrimeReference != null;	
	}
	
	def boolean getIsMGL(Import i) {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def String getExtension(ExecutableGraphmodel graphmodel)
	{
		return graphmodel.graphModel.fileExtension+"es";
	}
	
	
	
	
	
	def String getPvAnnotation(EList<Annotation> list,String anno,String suffix){
		var arg = list.filter[it.name.equals(anno)].get(0).value.get(0);
		return '''@«anno»("«arg»«suffix»")'''
	}
	
	def String getStyle(ModelElement annotatable)
	{
		if(annotatable.isIsAbstract){
			return annotatable.getAbstractStyle
		}
		val anno = annotatable.annotations.filter[n|n.name.equals("style")].get(0);	
		return '''@style(«anno.value.get(0)»«IF anno.value.size>1»,«anno.value.drop(1).map[n|n.statify].join('''"''',''',''','''"''')[n|n]»«ENDIF»)''';
	}
	
	def String getAbstractStyle(ModelElement annotatable) {
		var style = ""
		if(annotatable instanceof Edge) {
			style = "defaultEdge"
		}else {
			style = "defaultNode"
		}
		return '''@style(«style»,"«annotatable.name»")'''
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
	
	override fileName() {
		return super.graphmodel.graphModel.name+"ES.mgl"
	}
	
	
	
	
}