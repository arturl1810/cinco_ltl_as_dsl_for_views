import 'package:angular2/core.dart';

import '../../../../model/core.dart';
import '../../../../service/graph_service.dart';

@Component(
    selector: 'graph-entry',
    templateUrl: 'graph_entry_component.html',
    directives: const []
)
class GraphEntryComponent implements OnInit {


  @Output()
  EventEmitter openGraphModel;

  @Output()
  EventEmitter delete;

  @Output()
  EventEmitter hasChanged;

  @Input()
  GraphModel graph;

  bool editMode = false;

  final GraphService graphService;

  GraphEntryComponent(GraphService this.graphService)
  {
    openGraphModel = new EventEmitter();
    delete = new EventEmitter();
    hasChanged = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
  }

  void editGraph(dynamic e)
  {
    editMode = true;
    e.preventDefault();
  }

  void save(dynamic e)
  {
    e.preventDefault();
    graphService.updateGraphModel(graph).then((g){
      editMode = false;
      hasChanged.emit(e);
    });

  }

  void selectGraphModel(GraphModel graph,dynamic e)
  {
    e.preventDefault();
    openGraphModel.emit(graph);
  }


}

