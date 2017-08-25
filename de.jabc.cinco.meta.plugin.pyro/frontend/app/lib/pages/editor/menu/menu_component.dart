import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../projects/new_project/new_project_component.dart';
import '../../users/info/user_info_component.dart';
import '../../users/shared/shared_component.dart';
import '../../projects/delete_project/delete_project_component.dart';
import '../../projects/settings/settings_component.dart';

import '../../../service/project_service.dart';

@Component(
    selector: 'menu',
    templateUrl: 'menu_component.html',
    directives: const [NewProjectComponent,UserInfoComponent,SharedComponent,DeleteProjectComponent,SettingsComponent],
    styleUrls: const ['menu_component.css']
)
class MenuComponent implements OnInit {

  @Output()
  EventEmitter back;
  @Output()
  EventEmitter logout;
  @Output()
  EventEmitter changeLayout;
  @Output()
  EventEmitter changeScale;
  @Output()
  EventEmitter openProject;
  @Output()
  EventEmitter redo;
  @Output()
  EventEmitter undo;
  @Output()
  EventEmitter export;


  @Input()
  PyroUser user;
  @Input()
  PyroProject project;
  @Input()
  GraphModel currentGraphModel;

  bool showNewProjectModal = false;
  bool showUserInfoModal = false;
  bool showDeleteProjectModal = false;
  bool showSettingsModal = false;
  bool showSharedModal = false;

  final ProjectService projectService;

  MenuComponent(ProjectService this.projectService)
  {
    back = new EventEmitter();
    logout = new EventEmitter();
    changeLayout = new EventEmitter();
    openProject = new EventEmitter();
    changeScale = new EventEmitter();
    redo = new EventEmitter();
    undo = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
  }

  void saveProject(dynamic e)
  {
    e.preventDefault();
    projectService.update(project);

  }

  void exportSVG(dynamic e)
  {
    e.preventDefault();
    export.emit('svg');
  }

  void exportPNG(dynamic e)
  {
    e.preventDefault();
    export.emit('png');
  }

  void openModalShowNewProjectModal(dynamic e)
  {
    e.preventDefault();
    showNewProjectModal=true;
  }

  void openModalShowUserInfoModal(dynamic e)
  {
    e.preventDefault();
    showUserInfoModal=true;
  }

  void openModalShowDeleteProjectModal(dynamic e)
  {
    e.preventDefault();
    showDeleteProjectModal=true;
  }

  void openModalShowSettingsModal(dynamic e)
  {
    e.preventDefault();
    showSettingsModal=true;
  }

  void openModalShowSharedModal(dynamic e)
  {
    e.preventDefault();
    showSharedModal=true;
  }


  void deleteProject(dynamic e)
  {
    e.preventDefault();
    showDeleteProjectModal=false;
    back.emit(e);
  }

  void scaleGraph(bool direction,dynamic e)
  {
    e.preventDefault();
    changeScale.emit(direction);
  }

  void showView(dynamic e)
  {
    e.preventDefault();
  }

  void showInfo(dynamic e)
  {
    e.preventDefault();
  }

  void openCurrentProject(PyroProject project)
  {
    showNewProjectModal = false;
    openProject.emit(project);
  }

  bool isActiveRouter(String s){
    if(currentGraphModel!=null){
      return s==currentGraphModel.router;
    }
    return false;
  }

  bool isActiveConnector(String s){
    if(currentGraphModel!=null){
      return s==currentGraphModel.connector;
    }
    return false;
  }

  void changeRouteLayout(String type,dynamic e)
  {
    e.preventDefault();
    currentGraphModel.router = type;
    changeLayout.emit(type);
  }

  void changeConnectorLayout(String type,dynamic e)
  {
    e.preventDefault();
    currentGraphModel.connector=type;
    changeLayout.emit(type);
  }

  void triggerRedo(dynamic e) {
    e.preventDefault();
    if(currentGraphModel!=null){
      redo.emit({});
    }
  }

  void triggerUndo(dynamic e) {
    e.preventDefault();
    if(currentGraphModel!=null){
      undo.emit({});
    }
  }

}

