import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../../service/project_service.dart';


@Component(
    selector: 'edit-project',
    templateUrl: 'edit_project_component.html'
)
class EditProjectComponent implements OnInit {

  @Output()
  EventEmitter close;

  @Input()
  PyroUser user;

  @Input()
  PyroProject project;

  ProjectService projectService;

  List<PyroUser> selectedUser;

  String projectName;
  String projectDescription;

  bool hasBeenSaved = false;

  EditProjectComponent(ProjectService this.projectService)
  {
    selectedUser = new List();
    close = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
    projectName = project.name;
    projectDescription = project.description;
    selectedUser.addAll(project.shared);
  }

  bool isToggeled(PyroUser pu)
  {
    return selectedUser.contains(pu);
  }

  void toggelUser(PyroUser pu)
  {
    if(selectedUser.contains(pu)){
      selectedUser.remove(pu);
    } else {
      selectedUser.add(pu);
    }
  }

  void editProject()
  {
    project.name = projectName;
    project.description = projectDescription;
    var noMoreSharedUsers = new List<PyroUser>();
    noMoreSharedUsers.addAll(project.shared.where((u)=>!selectedUser.contains(u)));
    var newSharedUsers = new List<PyroUser>();
    newSharedUsers.addAll(selectedUser.where((u)=>!project.shared.contains(u)));

    //remove no more shared
    noMoreSharedUsers.forEach((u)=>project.shared.remove(u));
    noMoreSharedUsers.forEach((u)=>u.sharedProjects.remove(project));

    //add new users
    newSharedUsers.forEach((u)=>project.shared.add(u));
    newSharedUsers.forEach((u)=>u.sharedProjects.add(project));

    projectService.update(project).then((_)=>hasBeenSaved=true);
  }

}

