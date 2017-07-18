import 'dart:async';

import 'package:angular2/angular2.dart';
import '../model/core.dart';

@Injectable()
class ProjectService {

  List<PyroProject> _projects;


  ProjectService() {
    _projects = new List();
  }


  Future<PyroProject> create(String name,String description,PyroUser user,List<PyroUser> sharedUsers) async{
    PyroProject pp = new PyroProject();
    pp.dywaId = 15;
    pp.dywaName = name;
    pp.name = name;
    pp.description = description;
    pp.owner = user;
    pp.shared.addAll(sharedUsers);
    sharedUsers.forEach((p)=>p.sharedProjects.add(pp));
    user.ownedProjects.add(pp);
    print("[Send] new project ${pp.name}");
    return new Future.value(pp);
  }

  Future<PyroProject> update(PyroProject project) async{
  print("[Send] update project ${project.name}");
    return new Future.value(project);
  }

  Future<PyroProject> removeSharedUser(PyroUser user,PyroProject project) async {
    user.sharedProjects.remove(project);
    project.shared.remove(user);
    print("[Send] update project: remove shared user ${user.username}");
    return new Future.value(project);
  }

  Future<PyroProject> addSharedUser(PyroUser user,PyroProject project) async {
    user.sharedProjects.add(project);
    project.shared.add(user);
    print("[Send] update project: add shared user ${user.username}");
    return new Future.value(project);
  }

  Future<PyroUser> remove(PyroProject project,PyroUser user) async {
    if(user.ownedProjects.contains(project)){
      print("[Send] remove project ${project.name}");
      //really remove project from db
      project.shared.forEach((u)=>u.sharedProjects.remove(project));
      project.shared.clear();
      project.owner = null;
      user.ownedProjects.remove(project);
    }
    if(user.sharedProjects.contains(project)){
    print("[Send] remove shared project ${project.name}");
    project.shared.remove(user);
    user.sharedProjects.remove(project);
    }
    return new Future.value(user);
  }


}