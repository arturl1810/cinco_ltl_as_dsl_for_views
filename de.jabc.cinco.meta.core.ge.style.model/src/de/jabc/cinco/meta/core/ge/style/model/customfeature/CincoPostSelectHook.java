package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import graphicalgraphmodel.CModelElement;

public abstract class CincoPostSelectHook<T extends CModelElement>{

	public abstract void postSelect(T modelElement);
	
}