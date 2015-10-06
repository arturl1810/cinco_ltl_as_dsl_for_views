package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import org.eclipse.emf.ecore.EObject;

public abstract class CincoPreDeleteHook<T extends EObject> {

	public abstract void preDelete(T modelElement);
	
}
