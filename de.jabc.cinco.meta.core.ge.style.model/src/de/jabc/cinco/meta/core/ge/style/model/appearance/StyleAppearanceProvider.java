package de.jabc.cinco.meta.core.ge.style.model.appearance;

import style.Appearance;

public interface StyleAppearanceProvider<T> {
	public Appearance getAppearance(T object, String element);
}
