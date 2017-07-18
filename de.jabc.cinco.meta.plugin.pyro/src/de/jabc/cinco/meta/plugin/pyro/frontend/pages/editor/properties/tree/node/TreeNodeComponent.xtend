package de.jabc.cinco.meta.plugin.pyro.frontend.pages.editor.properties.tree.node

import de.jabc.cinco.meta.plugin.pyro.util.Generatable
import de.jabc.cinco.meta.plugin.pyro.util.GeneratorCompound

class TreeNodeComponent extends Generatable {
	
	new(GeneratorCompound gc) {
		super(gc)
	}
	
	def fileNameTreeNodeComponent()
	'''tree_node_component.dart'''
	
	def contentTreeNodeComponent()
	'''
	import 'package:angular2/core.dart';
	
	import 'package:«gc.projectName.escapeDart»/model/tree_view.dart';
	
	
	@Component(
	    selector: 'tree-node',
	    templateUrl: 'tree_node_component.html',
	    directives: const [TreeNodeComponent]
	)
	class TreeNodeComponent implements OnInit {
	
	  @Output()
	  EventEmitter hasNew;
	  @Output()
	  EventEmitter hasDeleted;
	  @Output()
	  EventEmitter hasSelected;
	
	
	  @Input()
	  TreeNode currentNode;
	
	  bool open;
	
	
	  TreeNodeComponent() {
	    hasNew = new EventEmitter();
	    hasDeleted = new EventEmitter();
	    hasSelected = new EventEmitter();
	    open = false;
	    print("const");
	  }
	
	  @override
	  void ngOnInit() {
	
	  }
	
	  String getStatusSign()
	  {
	    if(currentNode.children.isEmpty){
	      return "glyphicon glyphicon-option-vertical";
	    }
	    if(open){
	      return "glyphicon glyphicon-menu-down";
	    }
	    return "glyphicon glyphicon-menu-right";
	  }
	
	  void clickEntry(dynamic e)
	  {
	    e.preventDefault();
	    if(currentNode.isSelectable()){
	      hasSelected.emit(currentNode);
	    }
	
	  }
	
	  void createChildren(dynamic e,String name)
	  {
	    e.preventDefault();
	    currentNode.createChildren(name);
	    hasNew.emit(currentNode);
	  }
	
	  void delete(dynamic e)
	  {
	    e.preventDefault();
	    if(currentNode.parent!=null){
	      currentNode.parent.removeChild(currentNode);
	    }
	    hasDeleted.emit(currentNode);
	  }
	
	  void removeChild(TreeNode node)
	  {
	    //currentNode.removeChild(node);
	    hasDeleted.emit(node);
	  }
	
	  void clickOpen(dynamic e)
	  {
	    e.preventDefault();
	    open = !open;
	  }
	
	
	}
	
	'''
	
	
}