package de.jabc.cinco.meta.runtime.layout;

import graphmodel.ModelElementContainer;
import graphmodel.Node;

/**
 * Exception to be thrown whenever a @Node that is supposed to be put into
 * a @Container cannot be put there.
 */
public class NodeCannotBeMovedToContainerException extends Exception {

	/** generated */
	private static final long serialVersionUID = -2979430956616063736L;
	
	private Node child;
	private ModelElementContainer parent;

	public NodeCannotBeMovedToContainerException(Node node, ModelElementContainer ModelElementContainer) {
		super();
		assign(node, ModelElementContainer);
	}

	public NodeCannotBeMovedToContainerException(String error, Node node, ModelElementContainer ModelElementContainer) {
		super(error);
		assign(node, ModelElementContainer);
	}

	public NodeCannotBeMovedToContainerException(Throwable cause, Node node,
			ModelElementContainer ModelElementContainer) {
		super(cause);
		assign(node, ModelElementContainer);
	}

	public NodeCannotBeMovedToContainerException(String error, Throwable cause, Node node,
			ModelElementContainer ModelElementContainer) {
		super(error, cause);
		assign(node, ModelElementContainer);
	}

	private void assign(Node node, ModelElementContainer ModelElementContainer) {
		child = node;
		parent = ModelElementContainer;
	}

	public Node getChild() {
		return child;
	}

	public ModelElementContainer getParent() {
		return parent;
	}
}
