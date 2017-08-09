package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.graphs.graphmodel

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.ModelElement

class GraphmodelTree extends Generatable {

	new(GeneratorCompound gc) {
		super(gc)
	}

	def fileNameGraphmodelTree(String graphModelName) '''«graphModelName.escapeDart»_tree.dart'''

	def elementProperties(ModelElement gme, GraphModel g) '''
		class «gme.name.fuEscapeDart»TreeNode extends TreeNode {
			
			  «gme.name.fuEscapeDart» delegate;
			
			  String name;
			
			  «gme.name.fuEscapeDart»TreeNode(«gme.name.fuEscapeDart» element,{String this.name,TreeNode parent})
			  {
			    if(name==null){
			      name = "«gme.name.fuEscapeDart»";
			    }
			    if(parent!=null){
			      super.parent = parent;
			    }
			    delegate = element;
			    «FOR attr : gme.attributes.filter[!isPrimitive(g)]»
			    	//complex «IF attr.isList»list «ENDIF»attributes
			    	if(element.«attr.name.escapeDart»!=null) {
			    	  children.add(new «attr.type.fuEscapeDart»TreeNode(element.«attr.name.escapeDart»,name: "«attr.name.escapeDart»",parent: this));
			    	}
			    «ENDFOR»
			  }
			
			  «FOR attr : gme.attributes.filter[!isPrimitive(g)]»
			  	bool canRemove«attr.name.escapeDart»() {
			  		«IF attr.isList»
			  			return delegate.«attr.name.escapeDart».size > «attr.lowerBound»
			  		«ELSE»
			  			return true;
			  		«ENDIF»
			  		
			  	}
			«ENDFOR»
			@override
			TreeNode createChildren(String child) {
			  //for all complex not list attributes
			  «FOR attr : gme.attributes.filter[!isPrimitive(g)].filter[!isList]»
			  	if(child == "«attr.type.fuEscapeDart»")
			  	{
			  	  print("«gme.name.fuEscapeDart» create children ${child}");
			  	  //create pyro element
			  	  «attr.type.fuEscapeDart» element = new «attr.type.fuEscapeDart»();
			  	  //create tree node
			  	  «attr.type.fuEscapeDart»TreeNode node = new «attr.type.fuEscapeDart»TreeNode(element,name:"«attr.name.escapeDart»",parent: this);
			  	  // update business model;
			  	  this.delegate.«attr.name.escapeDart» = element;
			  	  //add to tree
			  	  children.add(node);
			  	  return node;
			  	}
			  «ENDFOR»
			  return null;
			  }
			
			  @override
			  List<String> getPossibleChildren() {
			    List<String> possibleElements = new List<String>();
			    //for all complex not list attributes
			    //check upper bound for single value
			    «FOR attr : gme.attributes.filter[!isPrimitive(g)]»
			    	«IF attr.isList»
			    		if(delegate.«attr.name.escapeDart».size < «attr.upperBound»){
			    	«ELSE»
			    		if(delegate.«attr.name.escapeDart»==null){
			    	«ENDIF»
			    	//add type name
			    	possibleElements.add("«attr.type.fuEscapeDart»");
			    	}
			    «ENDFOR»
			    return possibleElements;
			  }
			  
				@override
				bool isChildRemovable(TreeNode node)
				{
					switch(node.name){
			«FOR attr : gme.attributes.filter[!isPrimitive(g)].filter[isList]»
					case: '«attr.name.escapeDart»':return this.delegate.«attr.name.escapeDart».size > «attr.lowerBound»;
		    «ENDFOR»
					}
				   return true;
				}
			
			  @override
			  bool isSelectable() {
			    return true;
			  }
			
			  @override
			  bool isRemovable() {
			    return canRemove();
			  }
			  @override
			  void removeAttribute(String name) {
			    //for each complex not list attribute
			    «FOR attr : gme.attributes.filter[!isPrimitive(g)].filter[!list]»
			    	if(name == '«attr.name.escapeDart»') {
			    	  delegate.«attr.name.escapeDart» = null;
			    	}
			    «ENDFOR»
			  }
			}
	'''

	def contentGraphmodelTree(GraphModel g) '''
		import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart';
		import 'package:«gc.projectName.escapeDart»/model/core.dart';
		import 'package:«gc.projectName.escapeDart»/model/tree_view.dart';
		
		class «g.name.fuEscapeDart»TreeBuilder
		{
		
		  Tree getTree(IdentifiableElement element)
		  {
		    Tree tree = new Tree();
		    //for every complex attribute
		    //for every type
		    if(element!=null) {
		    	
		    	 //instanceofs
		    	 if(element is «g.name.fuEscapeDart»){
		    	     tree.root = new «g.name.fuEscapeDart»TreeNode(element);
		    	   }
		    	   «FOR elem : g.elements»
if(element is «elem.name.fuEscapeDart»){
tree.root = new «elem.name.fuEscapeDart»TreeNode(element);
}
		    	 «ENDFOR»
		    }
		    return tree;
		  }
		
		}
		
		/// node, edge, container, graphmodel type
		«g.elementProperties(g)»
		
		«g.elementsAndTypes.map[elementProperties(g)].join("\n")»
		
	'''
}
