import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular2/angular2.dart';
import '../model/core.dart';

@Injectable()
class ProjectService {

  Map requestHeaders;

  ProjectService() {
    requestHeaders = {'Content-Type':'application/json'};
  }


  Future<PyroProject> create(String name,String description,PyroUser user,List<PyroUser> sharedUsers) async{
    PyroProject pp = new PyroProject();
    pp.dywaName = name;
    pp.name = name;
    pp.description = description;
    pp.owner = user;
    pp.shared.addAll(sharedUsers);
    return HttpRequest.request("rest/project/create/private",sendData:JSON.encode(pp.toJSOG(new Map())),method: "POST",requestHeaders: requestHeaders).then((response){
      var newProject = PyroProject.fromJSON(response.responseText);
      newProject.owner=user;
      user.ownedProjects.add(newProject);
      print("[PYRO] new project ${newProject.name}");
      return newProject;

    });
  }

  Future<PyroProject> update(PyroProject project) async{
    return HttpRequest.request("rest/project/update/private",sendData:JSON.encode(project.toJSOG(new Map())),method: "POST",requestHeaders: requestHeaders).then((response){
      var newProject = PyroProject.fromJSON(response.responseText);
      print("[PYRO] update project ${newProject.name}");
      return newProject;
    });
  }

  Future<PyroProject> removeSharedUser(PyroUser user,PyroProject project) async {
    var data = {
      'projectId':project.dywaId,
      'userId':user.dywaId
    };
    return HttpRequest.request("rest/project/update/removesharing/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
      var newProject = PyroProject.fromJSON(response.responseText);
      print("[PYRO] remove project ${newProject.name} sharing ${user.username}");
      return newProject;

    });
  }

  Future<PyroProject> addSharedUser(PyroUser user,PyroProject project) async {
    var data = {
      'projectId':project.dywaId,
      'userId':user.dywaId
    };
    return HttpRequest.request("rest/project/update/addsharing/private",sendData:JSON.encode(data),method: "POST",requestHeaders: requestHeaders).then((response){
      var newProject = PyroProject.fromJSON(response.responseText);
      print("[PYRO] add project ${newProject.name} sharing ${user.username}");
      return newProject;

    });
  }

  Future<PyroUser> remove(PyroProject project,PyroUser user) async {
    return HttpRequest.request("rest/project/remove/${project.dywaId}/private",method: "GET",requestHeaders: requestHeaders).then((response){
      if(user.ownedProjects.contains(project)){
        print("[PYRO] remove project ${project.name}");
        //really remove project from db
        project.shared.forEach((u)=>u.sharedProjects.remove(project));
        project.shared.clear();
        project.owner = null;
        user.ownedProjects.remove(project);
      }
      if(user.sharedProjects.contains(project)){
        print("[PYRO] remove shared project ${project.name}");
        project.shared.remove(user);
        user.sharedProjects.remove(project);
      }
      return user;

    });

  }


}