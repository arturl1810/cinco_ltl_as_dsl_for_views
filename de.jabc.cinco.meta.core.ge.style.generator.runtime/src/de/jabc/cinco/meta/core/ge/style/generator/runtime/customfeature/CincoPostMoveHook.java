package de.jabc.cinco.meta.core.ge.style.generator.runtime.customfeature;

import graphicalgraphmodel.CModelElement;
import graphicalgraphmodel.CModelElementContainer;

public abstract class CincoPostMoveHook<T extends CModelElement> {

	abstract public void postMove(T modelElement, CModelElementContainer sourceContainer, CModelElementContainer targetContainer,
			int x, int y,
			int deltaX, int deltaY);
	
}