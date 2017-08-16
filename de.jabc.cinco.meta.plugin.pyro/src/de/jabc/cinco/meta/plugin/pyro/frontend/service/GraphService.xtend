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
	
	import 'package:angular2/angular2.dart';
	import '../model/core.dart';
	import '../model/message.dart';
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	import 'package:«gc.projectName.escapeDart»/pages/editor/canvas/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_command_graph.dart' as «g.name.lowEscapeDart»CG;
	«ENDFOR»
	
	import 'dart:html' as html;
	import 'dart:convert';
	
	@Injectable()
	class GraphService {
		
	  Map requestHeaders = {'Content-Type':'application/json'};
		
	  Future<Message> sendMessage(Message m,String graphModelType,int graphModelId) async{
	     print("[SEND] message ${m}");
	     return html.HttpRequest.request("rest/${graphModelType}/message/${graphModelId.toString()}/private",sendData:m.toJSON(),method: "POST",requestHeaders: requestHeaders).then((response){
	       var p = Message.fromJSON(response.responseText);
	       print("[PYRO] send command ${p.messageType}");
	       return p;
	     });
	  }
	
	  Future<PyroProject> loadProjectStructure(PyroProject project) async {
	    return html.HttpRequest.request("rest/project/structure/${project.dywaId}/private",method: "GET",requestHeaders: requestHeaders).then((response){
	      var p = PyroProject.fromJSON(response.responseText);
	      print("[PYRO] load project ${p.name}");
	      return p;
	    });
	  }
	
	  Future<PyroFolder> createFolder(PyroFolder folder,dynamic parent) async {
	    var data = {
	      'parentId':parent.dywaId,
	      'name':folder.name
	    };
	    return html.HttpRequest.request("rest/graph/create/folder/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
	      var newFolder = PyroFolder.fromJSON(response.responseText);
	      parent.innerFolders.add(newFolder);
	      print("[PYRO] new folder ${folder.name} in folder ${parent.name}");
	      return newFolder;
	    });
	  }
	
	  Future<PyroFolder> updateFolder(PyroFolder folder) async {
	    var data = {
	      'dywaId':folder.dywaId,
	      'name':folder.name
	    };
	    return html.HttpRequest.request("rest/graph/update/folder/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
	      print("[PYRO] update folder ${folder.name}");
	      return folder;
	    });
	  }
	
	  Future<Null> removeFolder(PyroFolder folder,PyroFolder parent) async {
	    return html.HttpRequest.request("rest/graph/remove/folder/${folder.dywaId}/${parent.dywaId}/private", method: "GET",requestHeaders: requestHeaders).then((response){
	      print("[PYRO] remove folder ${folder.name}");
	      parent.innerFolders.remove(folder);
	    });
	  }
	
	  Future<Null> removeGraph(GraphModel graph,PyroFolder parent) async {
	    return html.HttpRequest.request("rest/${graph.runtimeType.toString().toLowerCase()}/remove/${graph.dywaId}/${parent.dywaId}/private", method: "GET",requestHeaders: requestHeaders).then((response){
	      print("[PYRO] remove graphmodel ${graph.filename}");
	      parent.graphModels.remove(graph);
	    });
	  }
	
	  Future<GraphModel> updateGraphModel(GraphModel graph) async {
	    return html.HttpRequest.request("rest/graph/update/graphmodel/private",sendData:JSON.encode(graph.toJSOG(new Map())),method: "POST",requestHeaders: requestHeaders).then((response){
	      print("[PYRO] update graphmodel ${graph.filename}");
	      return graph;
	    });
	  }
	
	
	«FOR g:gc.graphMopdels»
	  Future<«g.name.lowEscapeDart».«g.name.fuEscapeDart»> create«g.name.escapeDart»(«g.name.lowEscapeDart».«g.name.fuEscapeDart» graph,PyroFolder parent) async {
	    var data = {
	        'parentId':parent.dywaId,
	        'filename':graph.filename
	    };
	    return html.HttpRequest.request("rest/«g.name.lowEscapeDart»/create/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
	        var newGraph = «g.name.lowEscapeDart».«g.name.fuEscapeDart».fromJSOG(JSON.decode(response.responseText),new Map());
	        print("[PYRO] created «g.name.fuEscapeDart» ${graph.filename}");
	        graph.merge(newGraph);
	        parent.graphModels.add(graph);
	        return newGraph;
	    });
	  }

	  
	  Future<«g.name.lowEscapeDart»CG.«g.name.fuEscapeDart»CommandGraph> loadCommandGraph«g.name.fuEscapeDart»(«g.name.lowEscapeDart».«g.name.fuEscapeDart» graph) async{
	      return html.HttpRequest.request("rest/«g.name.lowEscapeDart»/read/${graph.dywaId}/private",method: "GET",requestHeaders: requestHeaders).then((response){
	          var newGraph = «g.name.lowEscapeDart».«g.name.fuEscapeDart».fromJSOG(JSON.decode(response.responseText),new Map());
	          print("[PYRO] load «g.name.lowEscapeDart» ${newGraph.filename}");
	          graph.merge(newGraph);
	          var cg = new «g.name.lowEscapeDart»CG.«g.name.fuEscapeDart»CommandGraph(graph);
	          return cg;
	      });
	  }
	«ENDFOR»
	
	}
	'''
	
}