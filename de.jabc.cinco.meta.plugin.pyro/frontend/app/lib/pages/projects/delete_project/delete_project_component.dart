import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../../service/project_service.dart';

@Component(
    selector: 'delete-project',
    templateUrl: 'delete_project_component.html'
)
class DeleteProjectComponent implements OnInit {



  @Output()
  EventEmitter close;

  @Output()
  EventEmitter delete;

  @Input()
  bool shared;

  @Input()
  PyroUser user;

  @Input()
  PyroProject project;

  ProjectService projectService;

  DeleteProjectComponent(ProjectService this.projectService)
  {
    close = new EventEmitter();
    delete = new EventEmitter();
  }

  @override
  void ngOnInit()
  {

  }

  void closeModal(dynamic e)
  {
    e.preventDefault();
    close.emit(e);
  }

  void deleteProject(dynamic e)
  {
    e.preventDefault();
    projectService.remove(project,user).then((u){
      user = u;
      close.emit(e);
      delete.emit(e);
    });
  }

}

