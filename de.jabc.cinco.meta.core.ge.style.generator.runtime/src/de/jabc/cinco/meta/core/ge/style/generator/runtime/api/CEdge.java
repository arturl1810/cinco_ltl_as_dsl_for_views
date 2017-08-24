package de.jabc.cinco.meta.core.ge.style.generator.runtime.api;

import graphmodel.Node;

public interface CEdge extends CModelElement {
	
	void reconnectSource(Node newSource);
	void reconnectTarget(Node newTarget);
	
	void addBendpoint(int x, int y);
}
