import 'package:angular2/core.dart';
import 'dart:html';

import 'pages/main/main_component.dart';
import 'pages/login/login_component.dart';
import 'pages/features/features_component.dart';
import 'pages/welcome/welcome_component.dart';
import 'pages/projects/projects_component.dart';
import 'pages/editor/editor_component.dart';
import 'model/core.dart';

import 'service/user_service.dart';

@Component(
    selector: 'pyro-app',
    templateUrl: 'app_component.html',
    directives: const [MainComponent,LoginComponent,FeaturesComponent,WelcomeComponent,ProjectsComponent,EditorComponent],
    providers: const [UserService]
)
class AppComponent implements AfterViewInit,OnInit{

  String majorState;
  String minorState;
  PyroUser currentUser;
  PyroProject currentProject;

  final UserService userService;

  AppComponent(UserService this.userService)
  {
    minorState = '';
    majorState = '';

    print("app");
  }

  @override
  ngAfterViewInit() {

    //js.context.callMethod("initCanvas",[]);
  }

  @override
  void ngOnInit() {
    welcome();
  }

  void welcome()
  {
    minorState = 'welcome';
    majorState = 'main';
  }

  void pyroSignin(event)
  {
    majorState = 'main';
    minorState = 'login';
  }

  void pyroLogin(String userJson)
  {
    userService.login(userJson)
        .then((n){
      currentUser=n;
      projectPage(null);
    });

  }

  void changeMinorState(String state)
  {
    minorState = state;
  }

  void logout(dynamic e) {
    window.location.href="logout";
    minorState = 'welcome';
    majorState = 'main';
  }

  void openProject(PyroProject project)
  {
    if(project!=null){
      print("open project");
      currentProject = project;
      majorState = 'editor';
      minorState = '';
    }
  }

  void projectPage(dynamic e)
  {
    if(e!=null) {
      e.preventDefault();
    }
    majorState = 'projects';
    minorState = '';
  }
}

