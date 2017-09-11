import 'package:angular2/core.dart';
import 'dart:html';
import 'dart:convert';

import '../../model/core.dart';
import 'new_project/new_project_component.dart';
import 'edit_project/edit_project_component.dart';
import 'delete_project/delete_project_component.dart';
import '../users/find_user/find_user_component.dart';
import '../editor/notification/notification_component.dart';

import '../../service/project_service.dart';
import '../../service/user_service.dart';


@Component(
  selector: 'projects',
  templateUrl: 'projects_component.html',
  directives: const [NotificationComponent,NewProjectComponent, FindUserComponent,EditProjectComponent,DeleteProjectComponent],
  styleUrls: const ['projects_component.css'],
  providers: const [ProjectService]
)
class ProjectsComponent implements OnInit, OnDestroy {

  String tabState;

  String editProjectHeader;

  @ViewChild(NotificationComponent)
  NotificationComponent notificationComponent;

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

  WebSocket webSocketCurrentUser;

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
    userService.loadUser().then((u){
      user = u;
      if(notificationComponent!=null){
        notificationComponent.displayMessage("Welcome back ${u.username}",AlertType.SUCCESS);
      }
      showProjects(user.ownedProjects,'owned',null);
      activateWebSocket();
    });
    
  }

  @override
  void ngOnDestroy()
  {
    if(this.webSocketCurrentUser != null && this.webSocketCurrentUser.readyState == WebSocket.OPEN) {
      window.console.debug("Closing Websocket webSocketCurrentUser");
      this.webSocketCurrentUser.close();
      this.webSocketCurrentUser = null;
    }
  }

  void activateWebSocket() {
    if(this.user != null && this.webSocketCurrentUser == null) {
      this.webSocketCurrentUser = new WebSocket('ws://${window.location.hostname}:8080/app/ws/user/private');

      // Callbacks for currentUser
      this.webSocketCurrentUser.onOpen.listen((e) {
        window.console.debug("[PYRO] onOpen User Websocket");
      });
      this.webSocketCurrentUser.onMessage.listen((MessageEvent e) {
        window.console.debug("[PYRO] onMessage User Websocket");
        if(e.data != null) {
          var jsog = JSON.decode(e.data);
          if(jsog['senderId']!=user.dywaId){
            this.user = PyroUser.fromJSOG(new Map(),jsog['content']);
            if(tabState=='owned'){
              showProjects(user.ownedProjects,tabState,null);
            } else {
              showProjects(user.sharedProjects,tabState,null);
            }
            if(notificationComponent!=null){
              notificationComponent.displayMessage("Update Received",AlertType.INFO);
            }
          }
        }
      });
      this.webSocketCurrentUser.onClose.listen((CloseEvent e) {
        if(notificationComponent!=null) {
          notificationComponent.displayMessage(
              "Synchronisation Terminated", AlertType.WARNING);
        }
        window.console.debug("[PYRO] onClose User Websocket");
      });
      this.webSocketCurrentUser.onError.listen((e) {
        if(notificationComponent!=null) {
          notificationComponent.displayMessage(
              "Synchronisation Error", AlertType.DANGER);
        }
        window.console.debug("[PYRO] Error on Websocket webSocketCurrentUser: ${e.toString()()}");
      });
    }
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

  void refresh() {
    userService.loadUser().then((u){
      user = u;
      if(tabState=='owned'){
        showProjects(user.ownedProjects,tabState,null);
      } else {
        showProjects(user.sharedProjects,tabState,null);
      }
      if(notificationComponent!=null) {
        notificationComponent.displayMessage(
            "Refreshed", AlertType.WARNING);
      }
    });
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

