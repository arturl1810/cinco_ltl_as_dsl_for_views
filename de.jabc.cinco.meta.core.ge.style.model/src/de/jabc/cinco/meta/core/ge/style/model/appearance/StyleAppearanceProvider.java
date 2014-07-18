package de.jabc.cinco.meta.core.ge.style.model.appearance;

import style.Appearance;

public interface StyleAppearanceProvider<T> {
	
	final String CONNECTION = "connection";
	
	public Appearance getAppearance(T object, String element);
}
