import 'package:angular2/core.dart';

import '../../../../../model/core.dart';
import '../../../../../service/graph_service.dart';

@Component(
    selector: 'create-folder',
    templateUrl: 'create_folder_component.html',
    directives: const []
)
class CreateFolderComponent implements OnInit {

  @Output()
  EventEmitter close;

  @Input()
  PyroFolder folder;

  final GraphService graphService;

  CreateFolderComponent(GraphService this.graphService)
  {
    close = new EventEmitter();
  }

  @override
  void ngOnInit()
  {

  }

  void createNewFolder(String name,dynamic e)
  {
    e.preventDefault();
    print(name);
    print(folder.name);
    PyroFolder pf = new PyroFolder();
    pf.name = name;
    graphService.createFolder(pf,folder).then((f)=>close.emit(e));

  }


}

