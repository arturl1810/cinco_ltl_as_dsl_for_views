package de.jabc.cinco.meta.core.ge.style.model.customfeature;

import org.eclipse.emf.ecore.EObject;

abstract public class CincoPostCreateHook <T extends EObject> {

	abstract public void postCreate(T object);
	
}
