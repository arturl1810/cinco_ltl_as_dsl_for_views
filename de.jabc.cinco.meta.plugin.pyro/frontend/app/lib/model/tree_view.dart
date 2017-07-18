import 'core.dart';

class Tree {
  TreeNode root;
}

abstract class TreeNode {
  List<TreeNode> children;
  String symbol;
  bool open;
  PyroElement delegate;
  TreeNode parent;

  TreeNode()
  {
    children = new List<TreeNode>();
  }

  String get name;

  List<String> getPossibleChildren();

  TreeNode createChildren(String child);

  void removeChild(TreeNode node)
  {
    children.remove(node);
    removeAttribute(node.name);
  }

  void removeAttribute(String name);

  bool isSelectable();

  bool canRemove(){
    if(parent!=null) {
      print("can remove ${parent}");
      return parent.isChildRemovable(this);
    }
    return false;
  }

  bool isRemovable();

  bool isChildRemovable(TreeNode node)
  {
    return true;
  }

}

