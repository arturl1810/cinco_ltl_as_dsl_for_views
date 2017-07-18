import 'package:angular2/core.dart';

import '../../model/core.dart';
import 'new_project/new_project_component.dart';
import 'edit_project/edit_project_component.dart';
import 'delete_project/delete_project_component.dart';
import '../users/find_user/find_user_component.dart';

import '../../service/project_service.dart';
import '../../service/user_service.dart';

import 'dart:html';

@Component(
  selector: 'projects',
  templateUrl: 'projects_component.html',
  directives: const [NewProjectComponent, FindUserComponent,EditProjectComponent,DeleteProjectComponent],
  styleUrls: const ['projects_component.css'],
  providers: const [ProjectService]
)
class ProjectsComponent implements OnInit {

  String tabState;

  String editProjectHeader;

  bool showNewProjectModal = false;
  bool showFindUserModal = false;
  bool showEditProjectModal = false;
  PyroProject editProject = null;
  bool showDeleteProjectModal = false;
  PyroProject deleteProject = null;

  @ViewChild(FindUserComponent)
  FindUserComponent findUserComponent;

  @Output()
  EventEmitter openProject;

  @Output()
  EventEmitter logout;

  @Input()
  PyroUser user;

  List<PyroProject> currentProjects;
  final ProjectService projectService;
  final UserService userService;

  ProjectsComponent(ProjectService this.projectService,UserService this.userService)
  {
    editProjectHeader = '';
    currentProjects = new List();
    openProject = new EventEmitter();
    logout = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
    tabState = 'owned';
    window.console.log(user);
    showProjects(user.ownedProjects,'owned',null);
  }

  bool isActive(String s)
  {
    if(s==tabState) {
      return true;
    }
    return false;
  }

  void showProjects(List<PyroProject> projects,String s,dynamic e)
  {
    currentProjects = projects;
    tabState = s;
    if(e!=null) {
      e.preventDefault();
    }

  }

  void showEditProject(PyroProject project) {
    if(isActive('shared'))return;
    editProject = project;
    showEditProjectModal = true;
  }

  void removeProject(PyroProject project) {
    deleteProject=project;
    showDeleteProjectModal=true;
  }

  void openCurrentProject(PyroProject project)
  {
    openProject.emit(project);
  }

  void findUser(Map map)
  {


  }

}

