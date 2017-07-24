package de.jabc.cinco.meta.plugin.pyro.frontend.model

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound
import mgl.GraphModel
import mgl.ModelElement
import mgl.Enumeration
import mgl.NodeContainer
import mgl.ContainingElement
import mgl.Edge
import mgl.Node
import java.util.Collections
import mgl.UserDefinedType

class Model extends Generatable {

	new(GeneratorCompound gc) {
		super(gc)
	}

	def fileNameCommand() '''command.dart'''

	def contentCommand() '''
		import 'package:«gc.projectName.escapeDart»/deserializer/command_property_deserializer.dart';
		
		abstract class Command {
		  int delegateId;
		  String type;
		
		  Map toJSOG();
		}
		
		class CompoundCommand {
		  List<Command> queue;
		  CompoundCommand({Command first})
		  {
		    queue = new List();
		    if(first!=null) {
		      queue.add(first);
		    }
		  }
		
		  static CompoundCommand fromJSOG(jsog)
		  {
		    CompoundCommand cc = new CompoundCommand();
		    cc.queue = jsog['queue'].map((n) => CommandPropertyDeserializer.deserialize(n));
		    return cc;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['queue'] = queue.map((n) => n.toJSOG());
		    return map;
		  }
		
		}
		
		
		
		abstract class NodeCommand extends Command{
		  int dywaVersion;
		  String dywaName;
		}
		
		abstract class EdgeCommand extends Command {
		  int dywaVersion;
		  String dywaName;
		}
		/// Node Commands
		class CreateNodeCommand extends NodeCommand {
		  int x;
		  int y;
		  int containerId;
		
		  static CreateNodeCommand fromJSOG(Map jsog)
		  {
		    CreateNodeCommand cmd = new CreateNodeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		    cmd.type = jsog['type'];
		
		    cmd.x = jsog['x'];
		    cmd.y = jsog['y'];
		    cmd.containerId = jsog['containerId'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['x'] = x;
		    map['y'] = y;
		    map['containerId'] = containerId;
		    return map;
		  }
		}
		
		class MoveNodeCommand extends NodeCommand {
		  int oldX;
		  int oldY;
		  int oldContainerId;
		  int x;
		  int y;
		  int containerId;
		
		  static MoveNodeCommand fromJSOG(Map jsog)
		  {
		    MoveNodeCommand cmd = new MoveNodeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.x = jsog['x'];
		    cmd.y = jsog['y'];
		    cmd.containerId = jsog['containerId'];
		
		    cmd.oldX = jsog['oldX'];
		    cmd.oldY = jsog['oldY'];
		    cmd.oldContainerId = jsog['oldContainerId'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['x'] = x;
		    map['y'] = y;
		    map['containerId'] = containerId;
		
		    map['oldX'] = oldX;
		    map['oldY'] = oldY;
		    map['oldContainerId'] = oldContainerId;
		    return map;
		  }
		}
		
		class RemoveNodeCommand extends NodeCommand {
		  int x;
		  int y;
		  int containerId;
		
		  static RemoveNodeCommand fromJSOG(Map jsog)
		  {
		    RemoveNodeCommand cmd = new RemoveNodeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.x = jsog['x'];
		    cmd.y = jsog['y'];
		    cmd.containerId = jsog['containerId'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['x'] = x;
		    map['y'] = y;
		    map['containerId'] = containerId;
		
		    return map;
		  }
		}
		
		class ResizeNodeCommand extends NodeCommand {
		  int oldWidth;
		  int oldHeight;
		  int width;
		  int height;
		
		  static ResizeNodeCommand fromJSOG(Map jsog)
		  {
		    ResizeNodeCommand cmd = new ResizeNodeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.oldWidth = jsog['oldWidth'];
		    cmd.oldHeight = jsog['oldHeight'];
		    cmd.width = jsog['width'];
		    cmd.height = jsog['height'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['oldWidth'] = oldHeight;
		    map['oldHeight'] = oldWidth;
		    map['width'] = width;
		    map['height'] = height;
		
		    return map;
		  }
		}
		
		class RotateNodeCommand extends NodeCommand {
		  int oldAngle;
		  int angle;
		
		  static RotateNodeCommand fromJSOG(Map jsog)
		  {
		    RotateNodeCommand cmd = new RotateNodeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.oldAngle = jsog['oldAngle'];
		    cmd.angle = jsog['angle'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['oldAngle'] = oldAngle;
		    map['angle'] = angle;
		
		    return map;
		  }
		}
		
		/// Edge Commands
		class CreateEdgeCommand extends EdgeCommand {
		  int sourceId;
		  int targetId;
		
		  static CreateEdgeCommand fromJSOG(Map jsog)
		  {
		    CreateEdgeCommand cmd = new CreateEdgeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.sourceId = jsog['sourceId'];
		    cmd.targetId = jsog['targetId'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['sourceId'] = sourceId;
		    map['targetId'] = targetId;
		
		    return map;
		  }
		}
		
		class RemoveEdgeCommand extends EdgeCommand {
		  int sourceId;
		  int targetId;
		
		  static RemoveEdgeCommand fromJSOG(Map jsog)
		  {
		    RemoveEdgeCommand cmd = new RemoveEdgeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		
		    cmd.sourceId = jsog['sourceId'];
		    cmd.targetId = jsog['targetId'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['sourceId'] = sourceId;
		    map['targetId'] = targetId;
		
		    return map;
		  }
		}
		
		class ReconnectEdgeCommand extends EdgeCommand {
		  int oldSourceId;
		  int oldTargetId;
		  int sourceId;
		  int targetId;
		
		  static ReconnectEdgeCommand fromJSOG(Map jsog)
		  {
		    ReconnectEdgeCommand cmd = new ReconnectEdgeCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    cmd.dywaVersion = jsog['dywaVersion'];
		    cmd.dywaName = jsog['dywaName'];
		
		    cmd.sourceId = jsog['sourceId'];
		    cmd.targetId = jsog['targetId'];
		    cmd.oldSourceId = jsog['oldSourceId'];
		    cmd.oldTargetId = jsog['oldTargetId'];
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    map['dywaVersion'] = dywaVersion;
		    map['dywaName'] = dywaName;
		
		    map['sourceId'] = sourceId;
		    map['targetId'] = targetId;
		
		    map['oldSourceId'] = oldSourceId;
		    map['oldTargetId'] = oldTargetId;
		
		    return map;
		  }
		}
		
		
		class UpdateBendPointCommand extends Command {
		  List positions;
		
		  UpdateBendPointCommand() {
		    positions = new List();
		  }
		
		  static UpdateBendPointCommand fromJSOG(Map jsog)
		  {
		    UpdateBendPointCommand cmd = new UpdateBendPointCommand();
		    cmd.delegateId = jsog['delegateId'];
		    cmd.type = jsog['type'];
		    for(var value in jsog['positions']) {
		      Map pos = new Map();
		      pos['x']=value['x'];
		      pos['y']=value['y'];
		      cmd.positions.add(pos);
		    }
		    return cmd;
		  }
		
		  Map toJSOG()
		  {
		    Map map = new Map();
		    map['delegateId'] = delegateId;
		    map['type'] = type;
		    
		    map['positions'] = positions.map((n)=>{'x':n.x,'y':n.y});
		
		    return map;
		  }
		  
		}
	'''

	def fileNameDispatcher() '''dispatcher.dart'''

	def contentDispatcher() '''
		import 'core.dart';
		«FOR g:gc.graphMopdels»
		import '«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
		«ENDFOR»
		class GraphModelDispatcher {
		
		  static GraphModel dispatch(Map cache,dynamic jsog){
		  	«FOR g:gc.graphMopdels»
		    if(jsog["__type"]=='«g.name.escapeDart»'){
		      return «g.name.lowEscapeDart».«g.name.escapeDart».fromJSOG(jsog,cache);
		    }
		    «ENDFOR»
		    throw new Exception("Unkown graphmodel type ${jsog["__type"]}");
		  }
		  
	  	«FOR g:gc.graphMopdels»
		  static ModelElement dispatch«g.name.escapeDart»ModelElement(Map cache,dynamic jsog){
		  	«FOR e:g.elements»
		    if(jsog["__type"]=='«e.name.escapeDart»'){
  		      return «g.name.lowEscapeDart».«e.name.escapeDart».fromJSOG(jsog,cache);
  		    }
  		    «ENDFOR»
  		    throw new Exception("Unkown modelelement type ${jsog["__type"]}");
  		  }
	    «ENDFOR»
		}
	'''

	def fileNameGraphModel(String graphModelName) '''«graphModelName.lowEscapeDart».dart'''

	def pyroElementConstr(ModelElement element, GraphModel g) '''
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
	  	  this.incoming = new List();
	  	  this.outgoing = new List();
  		  «ENDIF»
  		  «IF element instanceof GraphModel»
  		  this.commandGraph = new «g.name.fuEscapeDart»CommandGraph(this);
  		  this.width = 1000;
  		  this.height = 600;
  		  this.scale = 1.0;
  		  this.router = null;
  		  this.connector = 'normal';
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
		      «IF element instanceof Edge»
		      this.bendingPoints = jsog['bendingPoints'].map((n)=>new BendingPoint(jsog:n));
		      «ENDIF»
		      «IF element instanceof GraphModel»
		      this.commandGraph = new «g.name.fuEscapeDart»CommandGraph(this,jsog:jsog['commandGraph']);
    		  this.width = jsog['width'];
    		  this.height = jsog['height'];
    		  this.scale = jsog['scale'];
    		  this.router = jsog['router'];
    		  this.connector = jsog['connector'];
    		  «ENDIF»
			«IF element instanceof ContainingElement»
			if (jsog.containsKey("modelElements")) {
				for(var v in jsog["modelElements"]){
					if(v.containsKey("@ref")){
						this.modelElements.add(cache[v['@ref']]);
					} else {
					  this.modelElements.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
					}
				}
			}
			«ENDIF»
			«IF element instanceof Node»
			if (jsog.containsKey("incoming")) {
				for(var v in jsog["incoming"]){
					if(v.containsKey("@ref")){
						this.incoming.add(cache[v['@ref']]);
					} else {
					  this.incoming.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
					}
				}
			}
			if (jsog.containsKey("outgoing")) {
				for(var v in jsog["outgoing"]){
					if(v.containsKey("@ref")){
						this.outgoing.add(cache[v['@ref']]);
					} else {
					  this.outgoing.add(GraphModelDispatcher.dispatch«g.name.escapeDart»ModelElement(cache,v));
					}
				}
			}
	  		«ENDIF»
		      // properties
		      «FOR attr : element.attributes»
			if (jsog.containsKey("«attr.name.escapeDart»")) {
				«IF attr.list»
				for(var jsogObj in jsog["«attr.name.escapeDart»"]) {
				«ELSE»
				var jsogObj = jsog["«attr.name.escapeDart»"];
				«ENDIF»
				 if (jsogObj != null) {
			«IF attr.isPrimitive(g)»
					«attr.primitiveDartType(g)» value«attr.name.escapeDart»;
					if (jsogObj != null) {
						«IF attr.type.getEnum(g)!=null»
						value«attr.name.escapeDart» = «attr.type.fuEscapeDart»Parser.fromJSOG(jsogObj.toString());
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
				  «FOR subType:attr.name.selfAndSubTypeNames(g)»
				  	if (jsogObj['__type'] ==
				  	"«fqn».«subType.fuEscapeDart»Impl") {
				  	    value«attr.name.escapeDart» =
				  	    new «subType.fuEscapeDart»(cache: cache, jsog: jsogObj);
				  	}
				  «ENDFOR»
				  }
				}
				this.«attr.name.escapeDart» = value«attr.name.escapeDart»;
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
		      map['@ref']=dywaId;
		      return map;
		    }
		    else{
		      map['@id']=dywaId;
		      map['dywaId']=dywaId;
		      map['dywaVersion']=dywaVersion;
		      map['dywaName']=dywaName;
		      «IF element instanceof GraphModel»
      		 map['width'] = this.width;
      		 map['height'] = this.height;
      		 map['scale'] = this.scale;
      		 map['router'] = this.router;
      		 map['connector'] = this.connector;
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
		void merge(«element.name» elem) {
			dywaVersion = elem.dywaVersion;
			«FOR attr : element.attributes»
				«attr.name.escapeDart» = elem.«attr.name.escapeDart»;
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
		«FOR attr : element.attributes.filter[isPrimitive(g)]»
			«IF attr.list»List<«ENDIF»«attr.primitiveDartType(g)»«IF attr.list»>«ENDIF» «attr.name.escapeDart»;
		«ENDFOR»
		«FOR attr : element.attributes.filter[!isPrimitive(g)]»
			«IF attr.list»List<«ENDIF»«attr.complexDartType.fuEscapeDart»«IF attr.list»>«ENDIF» «attr.name.escapeDart»;
		«ENDFOR»
	'''

	def pyroElementClass(ModelElement element, GraphModel g) '''
		«IF element.isIsAbstract»abstract «ENDIF»class «element.name.fuEscapeDart» extends «element.extending»
		{
		  «element.pyroElementAttributeDeclaration(g)»
		  «IF !element.isIsAbstract»
		  «element.name.fuEscapeDart»({Map cache,Map jsog}) {
		    «element.pyroElementConstr(g)»
		  }
		  «ENDIF»
		
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
			
		 «element.pyroElementFromJSOG(g)»
			
		}
	'''

	def contentGraphmodel(GraphModel g) '''
		import 'core.dart';
		import 'dispatcher.dart';
		
		import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_command_graph.dart';
		
		//Graphmodel
		«g.pyroElementClass(g)»
		
		//Nodes, Edges, Container and UserDefinedTypes
		«g.elementsAndTypes.map[pyroElementClass(g)].join("\n")»
		
		//Enumerations
		«FOR enu : g.types.filter(Enumeration)»
			enum «enu.name.fuEscapeDart» {
			  «FOR lit:enu.literals SEPARATOR ","»«lit.escapeDart»«ENDFOR»
			}
			
			class «enu.name.fuEscapeDart»Parser {
			  static «enu.name.fuEscapeDart» fromJSOG(String s){
			    switch(s) {
			  «FOR lit:enu.literals»
			  	case '«lit.escapeDart»':return «enu.name.fuEscapeDart».«lit.escapeDart»;
			  «ENDFOR»
			  }
			  return null;
			  }
			
			  static String toJSOG(«enu.name.fuEscapeDart» e)
			  {
			    return "${e.toString().substring(e.toString().indexOf('.')+1)}";
			  }
			}
		«ENDFOR»
	'''
}
