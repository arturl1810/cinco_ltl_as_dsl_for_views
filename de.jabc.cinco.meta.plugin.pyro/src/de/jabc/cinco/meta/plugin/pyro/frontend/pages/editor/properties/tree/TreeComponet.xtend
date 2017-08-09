package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.tree

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class TreeComponet extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameTreeComponent()'''tree_component.dart'''
	
	def contentTreeComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/core.dart';
	import 'package:«gc.projectName.escapeDart»/model/tree_view.dart';
	//For each graphmodel
	«FOR g:gc.graphMopdels»
	import 'package:«gc.projectName.escapeDart»/model/«g.name.lowEscapeDart».dart' as «g.name.lowEscapeDart»;
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/graphs/«g.name.lowEscapeDart»/«g.name.lowEscapeDart»_tree.dart' as «g.name.lowEscapeDart»TB;
	«ENDFOR»
	import 'package:«gc.projectName.escapeDart»/pages/editor/properties/tree/node/tree_node_component.dart';
	
	
	@Component(
	    selector: 'tree',
	    templateUrl: 'tree_component.html',
	    directives: const [TreeNodeComponent]
	)
	class TreeComponent implements OnInit, OnChanges {
	
	  @Output()
	  EventEmitter hasChanged;
	  
	  @Output()
	  EventEmitter hasRemoved;
	
	  @Output()
	  EventEmitter hasSelected;
	
	
	  @Input()
	  IdentifiableElement currentElement;
	  @Input()
	  GraphModel currentGraphModel;
	
	  Tree currentTree;
	
	  TreeComponent()
	  {
	    hasChanged = new EventEmitter();
	    hasSelected = new EventEmitter();
	    hasRemoved = new EventEmitter();
	  }
	
	  @override
	  void ngOnInit()
	  {
	    init();
	  }
	  
	  @override
	  ngOnChanges(Map<String, SimpleChange> changes) {
  	    init();
	  }
	
	  void init() {
  	  	if(currentGraphModel!=null&&currentElement!=null);
  	    {
  	      //instanceof
	      «FOR g:gc.graphMopdels»
  	      if(currentGraphModel is «g.name.lowEscapeDart».«g.name.fuEscapeDart»){
	        currentTree = new «g.name.lowEscapeDart»TB.«g.name.fuEscapeDart»TreeBuilder().getTree(currentElement);
  	      }
  	      «ENDFOR»
  	    }
  	  }
	
	  void hasNew(TreeNode node)
	  {
	    hasChanged.emit(node);
	  }
	
	  void hasDeleted(TreeNode node)
	  {
	    print(node.delegate);
	    var delegate = node.delegate;
	    node.delegate = null;
	    hasRemoved.emit(delegate);
	  }
	
	}
	
	'''
}