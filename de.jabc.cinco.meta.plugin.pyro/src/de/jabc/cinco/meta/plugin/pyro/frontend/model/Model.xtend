package de.jabc.cinco.meta.plugin.pyro.frontend.model

import de.jabc.cinco.meta.plugin.pyro.canvas.Shapes
import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import java.util.Collections
import mgl.ContainingElement
import mgl.Edge
import mgl.Enumeration
import mgl.GraphModel
import mgl.GraphicalModelElement
import mgl.ModelElement
import mgl.Node
import mgl.NodeContainer
import mgl.UserDefinedType
import style.NodeStyle
import style.Styles
import mgl.ReferencedModelElement

class Model extends Generatable {

	new(GeneratorCompound gc) {
		super(gc)
	}

	

	def fileNameDispatcher() '''dispatcher.dart'''

	def contentDispatcher() '''
		import 'core.dart';
		«FOR g:gc.graphMopdels»
		import '«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
		«ENDFOR»
		class GraphModelDispatcher {
			
			static IdentifiableElement dispatchElement(dynamic jsog){
				«FOR g:gc.graphMopdels»
					«FOR e:g.elements + #[g]»
						    if(jsog["dywaRuntimeType"]=='info.scce.pyro.«g.name.lowEscapeDart».rest.«e.name.escapeDart»'){
						    	return «g.name.lowEscapeDart».«e.name.escapeDart».fromJSOG(jsog,new Map());
						    }
				  	«ENDFOR»
				«ENDFOR»
				throw new Exception("Unkown element ${jsog['dywaRuntimeType']}");
			}
		
		  static GraphModel dispatch(Map cache,dynamic jsog){
		  	«FOR g:gc.graphMopdels»
		    if(jsog["__type"]=='«g.name.escapeDart»Impl'||jsog["__type"]=='«g.name.lowEscapeDart».«g.name.escapeDart»'){
		      return «g.name.lowEscapeDart».«g.name.escapeDart».fromJSOG(jsog,cache);
		    }
		    «ENDFOR»
		    throw new Exception("Unkown graphmodel type ${jsog["__type"]}");
		  }
		  
	  	«FOR g:gc.graphMopdels»
	  	  static ModelElementContainer dispatch«g.name.escapeDart»ModelElementContainer(Map cache,dynamic jsog){
	  	  	«FOR e:g.elements.filter(NodeContainer) + #[g]»
		    if(jsog["__type"]=='«g.name.lowEscapeDart».«e.name.escapeDart»'){
  		      return «g.name.lowEscapeDart».«e.name.escapeDart».fromJSOG(jsog,cache);
  		    }
  		    «ENDFOR»
  		    throw new Exception("Unkown modelelement type ${jsog["__type"]}");
	  	  }
	  	
		  static ModelElement dispatch«g.name.escapeDart»ModelElement(Map cache,dynamic jsog){
		  	«FOR e:g.elements»
		    if(jsog["__type"]=='«g.name.lowEscapeDart».«e.name.escapeDart»'){
  		      return «g.name.lowEscapeDart».«e.name.escapeDart».fromJSOG(jsog,cache);
  		    }
  		    «ENDFOR»
  		    throw new Exception("Unkown modelelement type ${jsog["__type"]}");
  		  }
	    «ENDFOR»
		}
	'''

	def fileNameGraphModel(String graphModelName) '''«graphModelName.lowEscapeDart».dart'''

	def pyroElementConstr(ModelElement element, GraphModel g,Styles styles) '''
		if (cache == null) {
		   cache = new Map();
		}
			
		// default constructor
		if (jsog == null) {
		  this.dywaId = -1;
		  this.dywaVersion = -1;
		  this.dywaName = null;
		  «IF element instanceof Edge»
		  this.bendingPoints = new List();
		  «ENDIF»
		  «IF element instanceof ContainingElement»
		  this.modelElements = new List();
		  «ENDIF»
		  «IF element instanceof Node»
		  «{
		  	 val nodeStyle = new Shapes(gc,g).styling(element,styles) as NodeStyle
		  	 val size = nodeStyle.mainShape.size
		  	 '''
		  	 «IF size!=null»
		  	 width = «size.width»;
		  	 height = «size.height»;
		  	 «ENDIF»
		  	 '''
		  }»
	  	  this.incoming = new List();
	  	  this.outgoing = new List();
	  	  this.x = 0;
	  	  this.y = 0;
  		  «ENDIF»
  		  «IF element instanceof GraphModel»
«««  		  this.commandGraph = new «g.name.fuEscapeDart»CommandGraph(this);
  		  this.width = 1000;
  		  this.height = 600;
  		  this.scale = 1.0;
  		  this.router = null;
  		  this.connector = 'normal';
  		  this.filename = '';
  		  «ENDIF»
		  // properties
			«FOR attr : element.attributes»
				«attr.name.escapeDart» =
				«IF attr.list»
					new List();
				«ELSE»
					«attr.init(g)»;
				«ENDIF»
			«ENDFOR»
		}
		// from jsog
		else {
		      String jsogId = jsog['@id'];
		      cache[jsogId] = this;
		
		      this.dywaId = jsog['dywaId'];
		      this.dywaVersion = jsog['dywaVersion'];
		      this.dywaName = jsog['dywaName'];
		      «IF element instanceof GraphicalModelElement»
		      if(jsog.containsKey('container')){
		      	if(jsog['container']!=null){
			      	if(jsog['container'].containsKey('@ref')){
			      		this.container = cache[jsog['container']['@ref']];
			      	} else {
			      		this.container = GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElementContainer(cache,jsog['container']);
			      	}
		      	}
		      }
		      «ENDIF»
		      «IF element instanceof Edge»
		      this.bendingPoints = new List();
		      if(jsog.containsKey('bendingPoints')){
		      	if(jsog['bendingPoints']!=null){
		      		this.bendingPoints = jsog['bendingPoints'].map((n)=>new BendingPoint(jsog:n));
		      	}
		      }
		      if(jsog.containsKey('sourceElement')){
		      	if(jsog['sourceElement']!=null){
	  		      	if(jsog['sourceElement'].containsKey('@ref')){
	  		      		this.source = cache[jsog['sourceElement']['@ref']];
	  		      	} else {
	  		      		this.source = GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,jsog['sourceElement']);
	  		      	}
  		      	}
  		      }
  		      if(jsog.containsKey('targetElement')){
  		      	if(jsog['targetElement']!=null){
			      	if(jsog['targetElement'].containsKey('@ref')){
			      		this.target = cache[jsog['targetElement']['@ref']];
			      	} else {
			      		this.target = GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,jsog['targetElement']);
			      	}
		        }	
		      }
		      «ENDIF»
		      «IF element instanceof GraphModel»
«««		      this.commandGraph = new «g.name.fuEscapeDart»CommandGraph(this,jsog:jsog['commandGraph']);
    		  this.width = jsog['width'];
    		  this.height = jsog['height'];
    		  this.scale = jsog['scale'];
    		  this.router = jsog['router'];
    		  this.connector = jsog['connector'];
    		  this.filename = jsog['filename'];
    		  «ENDIF»
			«IF element instanceof ContainingElement»
			this.modelElements = new List();
			if (jsog.containsKey("modelElements")) {
				if(jsog["modelElements"]!=null){
					for(var v in jsog["modelElements"]){
						if(v.containsKey("@ref")){
							this.modelElements.add(cache[v['@ref']]);
						} else {
						  this.modelElements.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
						}
					}
				}
			}
			«ENDIF»
			«IF element instanceof Node»
			width = jsog["width"];
			height = jsog["height"];
			x = jsog["x"];
			y = jsog["y"];
			angle = jsog["angle"];
			«IF element.isPrime»
			if(jsog.containsKey("«element.primeReference.name.escapeDart»")){
				if(jsog["«element.primeReference.name.escapeDart»"]!=null){
					if(jsog["«element.primeReference.name.escapeDart»"].containsKey("@ref")){
						this.«element.primeReference.name.escapeDart» = cache[jsog["«element.primeReference.name.escapeDart»"]["@ref"]];
					} else {
						this.«element.primeReference.name.escapeDart» =
						«IF (element.primeReference as ReferencedModelElement).type instanceof GraphModel»
						GraphModelDispatcher.dispatch(cache,jsog["«element.primeReference.name.escapeDart»"]);
						«ELSE»
						GraphModelDispatcher.dispatch«(element.primeReference as ReferencedModelElement).type.graphModel.name.escapeDart»ModelElement(cache,jsog["«element.primeReference.name.escapeDart»"]);
						«ENDIF»
					}
				}
			}
			«ENDIF»
			this.incoming = new List();
			if (jsog.containsKey("incoming")) {
				if(jsog["incoming"]!=null){
					for(var v in jsog["incoming"]){
						if(v.containsKey("@ref")){
							this.incoming.add(cache[v['@ref']]);
						} else {
						  this.incoming.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
						}
					}
				}
			}
			this.outgoing = new List();
			if (jsog.containsKey("outgoing")) {
				if(jsog["outgoing"]!=null) {
					for(var v in jsog["outgoing"]){
						if(v.containsKey("@ref")){
							this.outgoing.add(cache[v['@ref']]);
						} else {
						  this.outgoing.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
						}
					}
				}
			}
	  		«ENDIF»
		      // properties
		      «FOR attr : element.attributes»
			if (jsog.containsKey("«attr.name.escapeDart»")) {
				«IF attr.list»
				this.«attr.name.escapeDart» = new List();
				for(var jsogObj in jsog["«attr.name.escapeDart»"]) {
				«ELSE»
				var jsogObj = jsog["«attr.name.escapeDart»"];
				«ENDIF»
				 if (jsogObj != null) {
			«IF attr.isPrimitive(g)»
					«attr.primitiveDartType(g)» value«attr.name.escapeDart»;
					if (jsogObj != null) {
						«IF attr.type.getEnum(g)!=null»
						value«attr.name.escapeDart» = «attr.type.fuEscapeDart»Parser.fromJSOG(jsogObj);
						«ELSE»
					    value«attr.name.escapeDart» = jsogObj«attr.deserialize(g)»;
					    «ENDIF»
					}
					this.«attr.name.escapeDart» = value«attr.name.escapeDart»;
			«ELSE»
				«attr.complexDartType.fuEscapeDart» value«attr.name.escapeDart»;
				String jsogId;
				if (jsogObj.containsKey('@ref')) {
				  jsogId = jsogObj['@ref'];
				}
				else {
				  jsogId = jsogObj['@id'];
				}
				if (cache.containsKey(jsogId)) {
				  value«attr.name.escapeDart» = cache[jsogId];
				}
				else {
				  if (jsogObj != null) {
				  «FOR subType:attr.name.subTypes(g)»
				  	if (jsogObj['__type'] ==
				  	"«g.name.lowEscapeDart».«subType.name.fuEscapeDart»") {
				  	    value«attr.name.escapeDart» =
				  	    new «subType.name.fuEscapeDart»(cache: cache, jsog: jsogObj);
				  	}
				  «ENDFOR»
				  }
				}
				«IF attr.list»
				this.«attr.name.escapeDart».add()value«attr.name.escapeDart»;
				«ELSE»
				this.«attr.name.escapeDart» = value«attr.name.escapeDart»;
				«ENDIF»
			«ENDIF»
			}
			}
			«IF attr.list»}«ENDIF»
			«ENDFOR»
		}
		
	'''

	def pyroElementFromJSOG(ModelElement element, GraphModel g) '''
		Map toJSOG(Map cache) {
		    Map map = new Map();
		    if(cache.containsKey(dywaId)){
		      map['@ref']=cache[dywaId];
		      return map;
		    }
		    else{
		   	  cache[dywaId]=(cache.length+1).toString();
		      map['@id']=cache[dywaId];
		      map['dywaRuntimeType']="info.scce.pyro.«g.name.lowEscapeJava».rest.«element.name.fuEscapeJava»";
		      map['dywaId']=dywaId;
		      map['dywaVersion']=dywaVersion;
		      map['dywaName']=dywaName;
		      «IF element instanceof GraphModel»
      		 map['width'] = this.width;
      		 map['height'] = this.height;
      		 map['scale'] = this.scale;
      		 map['router'] = this.router;
      		 map['connector'] = this.connector;
      		 map['filename'] = this.filename;
      		  «ENDIF»
		      cache[dywaId]=map;
		      «FOR attr : element.attributes»
		      	map['«attr.name.escapeDart»']=«attr.name.escapeDart»==null?null:
		      	 «IF attr.isList»
		      	 	«attr.name.escapeDart».map((n)=>«attr.serialize(g,'''n''')»)
		      	 «ELSE»
		      	 	«attr.serialize(g,'''«attr.name.escapeDart»''')»
		      	 «ENDIF»;
		      «ENDFOR»
		    }
		
		    return map;
		}
		
		@override
		String $type()=>"«g.name.lowEscapeDart».«element.name.fuEscapeDart»";
		
		static «element.name» fromJSOG(Map jsog,Map cache)
		{
			return new «element.name»(jsog: jsog,cache: cache);
		}
		
		@override
		void merge(«element.name» elem,{bool structureOnly:false,Map<int,PyroElement> cache}) {
			if(cache==null){
			   cache = new Map();
			}
			cache[this.dywaId]=this;
			dywaVersion = elem.dywaVersion;
			«IF element instanceof GraphModel»
			  filename = elem.filename;
			  scale = elem.scale;
			  connector = elem.connector;
			  router = elem.router;
			  height = elem.height;
			  width = elem.width;
			«ENDIF»
			«IF element instanceof ContainingElement»
			  if(!structureOnly) {
			       //remove missing
			       modelElements.removeWhere((m)=>elem.modelElements.where((e)=>m.dywaId==e.dywaId).isEmpty);
			      //merge known
			       for(var m in modelElements){
			       	 if(!cache.containsKey(m.dywaId)){
			       	    m.merge(elem.modelElements.firstWhere((e)=>m.dywaId==e.dywaId),cache:cache);
			       	 }
			       }
			       //add new
			       modelElements.addAll(elem.modelElements.where((e)=>modelElements.where((m)=>m.dywaId==e.dywaId).isEmpty).toList());
			   	}
			«ENDIF»
			«IF element instanceof GraphicalModelElement»
			if(!structureOnly){
				if(container != null){
			      if(cache.containsKey(container.dywaId)){
			        container = cache[container.dywaId];
			      } else {
			        container.merge(elem.container,cache: cache,structureOnly: structureOnly);
			      }
			     } else {
			     	container = elem.container;
			     }
			}
			«ENDIF»
			«IF element instanceof Node»
				height = elem.height;
				width = elem.width;
				angle = elem.angle;
				if(!structureOnly) {
					//remove missing
				 	    incoming.removeWhere((m)=>elem.incoming.where((e)=>m.dywaId==e.dywaId).isEmpty);
				 	    //merge known
				 	    for(var m in incoming){
				 	    	if(!cache.containsKey(m.dywaId)){
				 	    		m.merge(elem.incoming.firstWhere((e)=>m.dywaId==e.dywaId),cache:cache);
				 	    	}
				 	    }
				 	    //add new
				 	    incoming.addAll(elem.incoming.where((e)=>incoming.where((m)=>m.dywaId==e.dywaId).isEmpty).toList());
				 	    //remove missing
				 	    outgoing.removeWhere((m)=>elem.outgoing.where((e)=>m.dywaId==e.dywaId).isEmpty);
				 	    //merge known
				 	    for(var m in outgoing){
				 	    	if(!cache.containsKey(m.dywaId)){
				 	    		m.merge(elem.outgoing.firstWhere((e)=>m.dywaId==e.dywaId),cache:cache);
				 	    	}
				 	    }
				 	    //add new
				 	    outgoing.addAll(elem.outgoing.where((e)=>outgoing.where((m)=>m.dywaId==e.dywaId).isEmpty).toList());
				}
				«IF element.prime»
				if(«element.primeReference.name.escapeDart» != null){
					if(cache.containsKey(«element.primeReference.name.escapeDart».dywaId)){
					    «element.primeReference.name.escapeDart» = cache[«element.primeReference.name.escapeDart».dywaId];
					} else {
					    «element.primeReference.name.escapeDart».merge(elem.«element.primeReference.name.escapeDart»,cache: cache,structureOnly: structureOnly);
					}
				} else {
					«element.primeReference.name.escapeDart» = elem.«element.primeReference.name.escapeDart»;
				}
				«ENDIF»
			«ENDIF»
			«IF element instanceof Edge»
			if(!structureOnly) {
				bendingPoints = elem.bendingPoints;
				if(target!=null){
					if(!cache.containsKey(target.dywaId)){
						target.merge(elem.target,cache:cache);
					}
				} else {
					target = elem.target;
				}
				if(source != null){
					if(!cache.containsKey(source.dywaId)){
						source.merge(elem.source,cache:cache);
					}
				} else {
					source = elem.source;
				}
			}
			«ENDIF»
			«FOR attr : element.attributes»
				«IF !attr.list && g.elementsAndTypes.map[name].exists[equals(attr.type)]»
				if(«attr.name.escapeDart»!=null&&elem.«attr.name.escapeDart»!=null){
					if(!cache.containsKey(«attr.name.escapeDart».dywaId)){
						«attr.name.escapeDart».merge(elem.«attr.name.escapeDart»,cache:cache,structureOnly:structureOnly);
					} else{
						«attr.name.escapeDart» = cache[«attr.name.escapeDart».dywaId];
					}
				} else {
					«attr.name.escapeDart» = elem.«attr.name.escapeDart»;
				}
				«ELSEIF !attr.list && g.elementsAndTypes.map[name].exists[equals(attr.type)]»
				//remove missing
				«attr.name.escapeDart».removeWhere((m)=>elem.«attr.name.escapeDart».where((e)=>m.dywaId==e.dywaId).isEmpty);
			    //merge known
			    for(var m in «attr.name.escapeDart»){
			    	if(!cache.containsKey(m.dywaId)){
			    		m.merge(elem.«attr.name.escapeDart».firstWhere((e)=>m.dywaId==e.dywaId),cache:cache);
			    	}
			    }
			    //add new
			    elem.«attr.name.escapeDart».where((e)=>«attr.name.escapeDart».where((m)=>m.dywaId==e.dywaId).isEmpty).forEach((e)=>«attr.name.escapeDart».add(e));
				«ELSE»
				«attr.name.escapeDart» = elem.«attr.name.escapeDart»;
				«ENDIF»
			«ENDFOR»
		}
		
		«IF element instanceof Node || element instanceof Edge && !element.isIsAbstract»
		@override
		List<String> styleArgs() {
		    return [«element.styleArgs.map[n|'''"«n»"'''].join(",")»];
		}
		«ENDIF»
		
	'''
	
	def getStyleArgs(ModelElement element){
		val values = element.annotations.findFirst[name.equals("style")].value
		if(values.size>1){
			return values.subList(1,values.size);
		}
		return Collections.EMPTY_LIST
	}

	def pyroElementAttributeDeclaration(ModelElement element, GraphModel g) '''
		 «IF element instanceof GraphModel»
			«g.name.fuEscapeDart»CommandGraph commandGraph;
			int width;
			int height;
			double scale;
			String router;
			String connector;
	    «ENDIF»
	    «IF element instanceof Node»
	    	«IF element.prime»
	    	«{
	    		val refElem = (element.primeReference as ReferencedModelElement).type
	    		val refGraph = refElem.graphModel
	    		'''«IF !refGraph.equals(g)»«refGraph.name.lowEscapeDart».«ENDIF»«refElem.name.fuEscapeDart» «element.primeReference.name.escapeDart»;'''
	    	}»
	    	«ENDIF»
	    «ENDIF»
		«FOR attr : element.attributes.filter[isPrimitive(g)]»
			«IF attr.list»List<«ENDIF»«attr.primitiveDartType(g)»«IF attr.list»>«ENDIF» «attr.name.escapeDart»;
		«ENDFOR»
		«FOR attr : element.attributes.filter[!isPrimitive(g)]»
			«IF attr.list»List<«ENDIF»«attr.complexDartType.fuEscapeDart»«IF attr.list»>«ENDIF» «attr.name.escapeDart»;
		«ENDFOR»
	'''

	def pyroElementClass(ModelElement element, GraphModel g,Styles styles) '''
		«IF element.isIsAbstract»abstract «ENDIF»class «element.name.fuEscapeDart» extends «element.extending()»
		{
		  «element.pyroElementAttributeDeclaration(g)»
		  «IF !element.isIsAbstract»
		  «element.name.fuEscapeDart»({Map cache,Map jsog}) {
		    «element.pyroElementConstr(g,styles)»
		  }
		  «ENDIF»
		«IF !(element instanceof UserDefinedType)»
			«IF element.canContain»
				@override
				List<IdentifiableElement> allElements() {
				  List<IdentifiableElement> list = new List();
				  list.add(this);
				  list.addAll(modelElements.expand((n) => n.allElements()));
				  return list;
				}
			«ELSE»
				@override
				List<IdentifiableElement> allElements() {
					return [this];
				}
			«ENDIF»
		«ENDIF»
			
		 «element.pyroElementFromJSOG(g)»
			
		}
	'''

	def contentGraphmodel(GraphModel g,Styles styles) '''
		import 'core.dart';
		import 'dispatcher.dart';
		
		import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_command_graph.dart';
		«FOR pr:g.primeReferencedGraphModels.filter[!equals(g)]»
		//prime referenced graphmodel «pr.name»
		import '«pr.name.lowEscapeDart».dart' as «pr.name.lowEscapeDart»;
		«ENDFOR»
		
		//Graphmodel
		«g.pyroElementClass(g,styles)»
		
		//Nodes, Edges, Container and UserDefinedTypes
		«g.elementsAndTypes.map[pyroElementClass(g,styles)].join("\n")»
		
		//Enumerations
		«FOR enu : g.types.filter(Enumeration)»
			enum «enu.name.fuEscapeDart» {
			  «FOR lit:enu.literals SEPARATOR ","»«lit.escapeDart»«ENDFOR»
			}
			
			class «enu.name.fuEscapeDart»Parser {
			  static «enu.name.fuEscapeDart» fromJSOG(dynamic s){
			    switch(s['dywaName']) {
			  «FOR lit:enu.literals»
			  	case '«lit.escapeDart»':return «enu.name.fuEscapeDart».«lit.escapeDart»;
			  «ENDFOR»
			  }
			  return «enu.name.fuEscapeDart».«enu.literals.get(0).escapeDart»;
			  }
			
			  static Map toJSOG(«enu.name.fuEscapeDart» e)
			  {
			    Map map = new Map();
			    switch(e) {
			    «FOR lit:enu.literals»
			       case «enu.name.fuEscapeDart».«lit.escapeDart»:map['dywaName']='«lit.escapeDart»';break;
			    «ENDFOR»
			    }
			    return map;
			  }
			}
		«ENDFOR»
	'''
}
