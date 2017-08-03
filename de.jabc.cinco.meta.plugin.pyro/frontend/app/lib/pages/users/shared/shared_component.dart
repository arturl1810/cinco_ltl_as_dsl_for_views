import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../find_user/find_user_component.dart';
import '../../../service/project_service.dart';

@Component(
    selector: 'shared',
    templateUrl: 'shared_component.html',
    directives: const [FindUserComponent]
)
class SharedComponent implements OnInit {

  @Output()
  EventEmitter close;

  @Input()
  PyroUser user;


  @Input()
  PyroProject project;

  bool showFindUserModal = false;
  bool isOwner = false;

  final ProjectService projectService;

  SharedComponent(ProjectService this.projectService)
  {
    close = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
    isOwner= project.owner.dywaId==user.dywaId;
  }


  void removeUserFromProject(PyroUser user)
  {
    projectService.removeSharedUser(user,project).then((p)=>project=p);
  }

  void addUserToProject(PyroUser user)
  {
    projectService.addSharedUser(user,project).then((p)=>project=p);
  }

  List<PyroUser> notIncludedUsers()
  {
    return user.knownUsers.where((n) => project.shared.where((u)=>u.dywaId==n.dywaId).isEmpty).toList();
  }

}

