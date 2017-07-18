package de.jabc.cinco.meta.plugin.pyro.frontend.service

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class GraphService extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameGraphServcie()'''graph_service.dart'''
	
	def contentGraphService()
	'''
	import 'dart:async';
	import 'dart:math';
	
	import 'package:angular2/angular2.dart';
	import '../model/core.dart';
	import '../model/command.dart';
	import '../model/message.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_command_graph.dart' as «g.name.lowEscapeDart»CG;
	«ENDFOR»
	
	import 'dart:html' as html;
	
	@Injectable()
	class GraphService {
		
	   Future<Message> sendMessage(Message m) async{
	    print("[SEND] message ${m}");
        html.window.console.log(m);
        if(m is CompoundCommandMessage){
        if(m.cmd.queue.first is CreateNodeCommand || m.cmd.queue.first is CreateEdgeCommand){
          return new ValidCreatedMessage(m.senderDywaId,new Random().nextInt(999999));
        }
      }
    	return new ValidMessage(m.senderDywaId);
	}
	
	
	  Future<PyroFolder> createFolder(PyroFolder folder,dynamic parent) async {
	    folder.dywaId = new Random().nextInt(999999);
	    parent.innerFolders.add(folder);
	    print("[SEND] new folder ${folder.name}");
	    return new Future.value(folder);
	  }
	
	  Future<PyroFolder> updateFolder(PyroFolder folder) async {
	  	print("[SEND] update folder name ${folder.name}");
	    return new Future.value(folder);
	  }
	
	  Future<Null> removeFolder(PyroFolder folder,PyroFolder parent) async {
		print("[SEND] remove folder ${folder.name}");
	    parent.innerFolders.remove(folder);
	    
	    return;
	  }
	
	  Future<Null> removeGraph(GraphModel graph,PyroFolder parent) async {
		print("[SEND] remove graph ${graph.filename}");
	    parent.graphModels.remove(graph);
	    
	    return;
	  }
	
	  Future<GraphModel> updateGraphModel(GraphModel graph) async {
	    return new Future.value(graph);
	  }
	«FOR g:gc.graphMopdels»
	  Future<«g.name.lowEscapeDart».«g.name.fuEscapeDart»> create«g.name.escapeDart»(«g.name.lowEscapeDart».«g.name.fuEscapeDart» graph,PyroFolder parent) async {
	    graph.dywaId = new Random().nextInt(999999);
		print("[SEND] new graph ${graph.filename}");
	    parent.graphModels.add(graph);
	    
	    return new Future.value(graph);
	  }
	
	  Future<«g.name.lowEscapeDart».«g.name.fuEscapeDart»> update«g.name.escapeDart»(«g.name.lowEscapeDart».«g.name.fuEscapeDart» graph) async {
	  	print("[SEND] update graph ${graph.filename}");
	    return new Future.value(graph);
	  }
	  
	  Future<«g.name.lowEscapeDart»CG.«g.name.fuEscapeDart»CommandGraph> loadCommandGraph«g.name.fuEscapeDart»(«g.name.lowEscapeDart».«g.name.fuEscapeDart» graph) async{
	      print("[RECEIVE] load «g.name.lowEscapeDart» command graph ${graph.dywaId}");
	      var cg = new «g.name.lowEscapeDart»CG.«g.name.fuEscapeDart»CommandGraph(graph);
	      return new Future.value(cg);
	  }
	«ENDFOR»
	
	}
	'''
	
}