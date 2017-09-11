import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../../service/project_service.dart';


@Component(
    selector: 'new-project',
    templateUrl: 'new_project_component.html'
)
class NewProjectComponent implements OnInit {


  @Output()
  EventEmitter newProject;

  @Output()
  EventEmitter close;

  @Input()
  PyroUser user;

  ProjectService projectService;

  List<PyroUser> selectedUser;

  NewProjectComponent(ProjectService this.projectService)
  {
    selectedUser = new List();
    newProject = new EventEmitter();
    close = new EventEmitter();
    print("new project");
  }

  @override
  void ngOnInit()
  {

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

  void createNewProject(String name,String description)
  {
    projectService.create(name,description,user,selectedUser).then((p)=>this.newProject.emit(p));
  }

}

