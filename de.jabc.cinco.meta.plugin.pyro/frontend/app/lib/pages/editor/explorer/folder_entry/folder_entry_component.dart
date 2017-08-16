import 'package:angular2/core.dart';

import '../../../../model/core.dart';
import '../graph_entry/graph_entry_component.dart';
import '../../../../service/graph_service.dart';

@Component(
    selector: 'folder-entry',
    templateUrl: 'folder_entry_component.html',
    directives: const [FolderEntryComponent,GraphEntryComponent]
)
class FolderEntryComponent implements OnInit {


  @Output()
  EventEmitter openGraphModel;

  @Output()
  EventEmitter delete;

  @Output()
  EventEmitter hasChanged;

  @Output()
  EventEmitter hasDeleted;

  @Output()
  EventEmitter createFile;

  @Output()
  EventEmitter createFolder;

  @Input()
  PyroFolder folder;

  @Input()
  GraphModel currentGraphModel;

  @ContentChildren(FolderEntryComponent)
  QueryList<FolderEntryComponent> childFolders;


  bool open = false;
  bool editMode = false;

  final GraphService graphService;
  
  FolderEntryComponent(GraphService this.graphService)
  {
    openGraphModel = new EventEmitter();
    delete = new EventEmitter();
    createFile = new EventEmitter();
    createFolder = new EventEmitter();
    hasDeleted = new EventEmitter();
    hasChanged = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
  }

  String getFolderClass()
  {
    if(open){
      return "glyphicon glyphicon-chevron-down";
    }
    return "glyphicon glyphicon-chevron-right";
  }

  void openFolder(dynamic e)
  {
    open = !open;
    e.preventDefault();
  }

  void removeFolder(PyroFolder folder)
  {
    graphService.removeFolder(folder,this.folder).then((f)=>hasDeleted.emit(folder));

  }

  void deleteGraph(GraphModel graph)
  {
    graphService.removeGraph(graph,this.folder).then((f)=>hasDeleted.emit(graph));
  }

  void editEntry(dynamic e)
  {
    e.preventDefault();
    editMode =true;
  }

  void save(dynamic e)
  {
    e.preventDefault();
    graphService.updateFolder(folder).then((f){
      editMode = false;
      hasChanged.emit(e);
    });
  }

  void createInnerFolder(PyroFolder folder)
  {
    open = true;
    createFolder.emit(folder);
  }

  void createInnerFile(PyroFolder folder)
  {
    open = true;
    createFile.emit(folder);
  }

}

