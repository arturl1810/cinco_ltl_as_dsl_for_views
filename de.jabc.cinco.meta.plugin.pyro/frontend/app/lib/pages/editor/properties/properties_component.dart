import 'package:angular2/core.dart';

import '../../../model/core.dart';
import '../../../model/tree_view.dart';
import '../../../model/message.dart';
import 'tree/tree_component.dart';
import 'property/property_component.dart';

@Component(
    selector: 'properties',
    templateUrl: 'properties_component.html',
    directives: const [TreeComponent,PropertyComponent],
    styleUrls: const ['../editor_component.css']
)
class PropertiesComponent implements OnInit, OnChanges {

  @Input()
  IdentifiableElement currentGraphElement;
  @Input()
  GraphModel currentGraphModel;

  @Input()
  PyroUser user;

  @Output('hasChanged')
  EventEmitter hasPropertiesChanged;

  PyroElement currentElement;

  PropertiesComponent()
  {
    hasPropertiesChanged = new EventEmitter();
  }

  @override
  void ngOnInit()
  {
	if(currentGraphElement!=null) {
      currentElement = currentGraphElement;
    }

  }
  
  @override
  ngOnChanges(Map<String, SimpleChange> changes) {
      if(changes.containsKey('currentGraphElement')) {
            currentElement=currentGraphElement;
		}
      if(changes.containsKey('currentGraphModel')) {
        currentElement=currentGraphModel;
      }
  }

  ///triggered if an element is edited
  void hasChangedValues(PyroElement element)
  {
    //todo persist attributes of currentGraphElement recursive
    PropertyMessage pm = new PropertyMessage(
        currentGraphModel.dywaId,
        currentGraphModel.runtimeType.toString(),
        currentGraphElement,
        user.dywaId
    );
    hasPropertiesChanged.emit(pm);
  }

    /// triggerd if elements are created
    void hasChanged(TreeNode element)
    {
        //todo persist attributes of element recursive
      if(element.parent!=null){
        print(element.parent);
      }
      PropertyMessage pm = new PropertyMessage(
          currentGraphModel.dywaId,
          currentGraphModel.runtimeType.toString(),
          currentGraphElement,
          user.dywaId
      );
      hasPropertiesChanged.emit(pm);
  
    }
  
    /// triggerd if elements are removed
    void hasRemoved(PyroElement element)
    {
      if(currentElement==element){
        currentElement=null;
      }
      PropertyMessage pm = new PropertyMessage(
          currentGraphModel.dywaId,
          currentGraphModel.runtimeType.toString(),
          currentGraphElement,
          user.dywaId
      );
      hasPropertiesChanged.emit(pm);
  
    }

  /// triggered if a new node is selected
  void hasSelection(TreeNode node)
  {
    print("selectiont ${node}");
    currentElement = node.delegate;
  }

}

