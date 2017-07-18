import 'package:angular2/core.dart';

import '../../../model/core.dart';
import 'graph_entry/graph_entry_component.dart';
import 'folder_entry/folder_entry_component.dart';
import 'folder_entry/create/create_folder_component.dart';
import 'graph_entry/create/create_file_component.dart';
import '../../../service/graph_service.dart';

@Component(
    selector: 'explorer',
    templateUrl: 'explorer_component.html',
    directives: const [FolderEntryComponent,GraphEntryComponent,CreateFileComponent,CreateFolderComponent],
    styleUrls: const ['../editor_component.css']
)
class ExplorerComponent implements OnInit {


  @Output()
  EventEmitter openGraphModel;

  @Output()
  EventEmitter hasDeleted;

  @Output()
  EventEmitter hasChanged;

  @Input()
  PyroUser user;
  @Input()
  PyroProject project;

  @ViewChildren(FolderEntryComponent)
  QueryList<FolderEntryComponent> childFolders;

  bool showCreateFileModal = false;
  bool showCreateFolderModal = false;
  PyroFolder currentFolder;

  final GraphService graphService;

  ExplorerComponent(GraphService this.graphService)
  {
    openGraphModel = new EventEmitter();
    hasDeleted = new EventEmitter();
    hasChanged = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
  }


  void removeFolder(PyroFolder folder)
  {
    graphService.removeFolder(folder,project).then((_)=>hasDeleted.emit(folder));
  }

  void deleteGraph(GraphModel graph)
  {
    graphService.removeGraph(graph,project).then((_)=>hasDeleted.emit(graph));
  }

  void createEntry(dynamic e)
  {
    e.preventDefault();
  }

  void hideCreateFile(dynamic e)
  {
    e.preventDefault();
    showCreateFileModal=false;
  }

  void hideCreateFolder(dynamic e)
  {
    e.preventDefault();
    showCreateFolderModal=false;
  }

  void createFolder(PyroFolder folder)
  {
    currentFolder = folder;
    showCreateFolderModal = true;
  }

  void createFile(PyroFolder folder)
  {
    currentFolder = folder;
    showCreateFileModal = true;
  }

  void expandAll(dynamic e)
  {
    e.preventDefault();
    changeFolderStatus(true);
  }

  void collapseAll(dynamic e)
  {
    e.preventDefault();
    changeFolderStatus(false);
  }

  void changeFolderStatus(bool o)
  {
    childFolders.forEach((n) {
      n.open = o;
    });
  }


}

