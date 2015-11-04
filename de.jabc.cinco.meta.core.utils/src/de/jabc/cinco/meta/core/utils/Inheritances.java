package de.jabc.cinco.meta.core.utils;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import mgl.Edge;
import mgl.ModelElement;
import mgl.Node;

public class Inheritances {
	
	private List<InheritanceTree<ModelElement>> trees;
	
	public Inheritances() {
		trees = new ArrayList<InheritanceTree<ModelElement>>();
	}
	
	public void addElement(ModelElement me) {
		ModelElement parent = getParent(me);
		if (parent == null) { 
			trees.add(new InheritanceTree<ModelElement>(me));
			return;
		}

		InheritanceTree<ModelElement> containingTree = getContainingTree(me, parent);
		if (containingTree != null)
			containingTree.get(parent).add(me);
		else trees.add(new InheritanceTree<ModelElement>(me));
		
	}

	private InheritanceTree<ModelElement> getContainingTree(ModelElement me, ModelElement parent) {
		for (InheritanceTree<ModelElement> t : trees) {
			if (t.contains(parent)) {
				return t;
			}
		}
		return null;
	}

	public void printTrees() {
		for (InheritanceTree<ModelElement> t : trees) {
			System.out.println("Tree: ......");
			t.print();
		}
	}
	
	public List<ModelElement> createList(){
		List<ModelElement> list = new ArrayList<ModelElement>();
		for (InheritanceTree<ModelElement> t : trees) {
			t.getInorder(list);
		}
		return list;
	}
	
	private ModelElement getParent(ModelElement me) {
		if (me instanceof Node)
			return ((Node) me).getExtends();
		if (me instanceof Edge)
			return ((Edge) me).getExtends();
		return null;
	}
	
}



class InheritanceTree<E extends ModelElement> {
	
	private E root;
	private List<InheritanceTree<E>> children;
	
	public InheritanceTree() {
		children = new ArrayList<InheritanceTree<E>>();
	}
	
	public void print() {
		System.out.println(root.getName() + ": ");
		children.forEach(c -> System.out.print(c.getRoot().getName() + ", "));
		System.err.println("\n------------------------------------------\n\n");
		children.forEach(c -> c.print());
	}

	public void getInorder(List<ModelElement> list) {
		for (InheritanceTree<E> c : children) {
			c.getInorder(list);
		}
		if (!isEmpty())
			list.add(root);
	}

	public InheritanceTree(E element) {
		root = element;
		children = new ArrayList<InheritanceTree<E>>();
	}
	
	public void add(E element) {
		InheritanceTree<E> r = new InheritanceTree<E>(element);
		children.add(r);
	}
	
	public boolean contains(E element) {
		return get(element) != null;
	}
	
	public InheritanceTree<E> get(E element) {
		if (isEmpty())
			return null;
		
		if (root.equals(element))
			return this;
	
		else {
			for (InheritanceTree<E> child : children) {
				if (child.get(element) != null)
					return child.get(element);
			}
		}
		return null;
	}
	
	public boolean isEmpty() {
		return root == null;
	}
	
	public E getRoot() {
		return root;
	}
	
	public List<InheritanceTree<E>> getChildren() {
		return children;
	}
}
