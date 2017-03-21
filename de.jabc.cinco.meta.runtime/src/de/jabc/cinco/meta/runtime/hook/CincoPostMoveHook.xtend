package de.jabc.cinco.meta.runtime.hook

import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.runtime.CincoRuntimeBaseClass
import graphmodel.ModelElementContainer

abstract class CincoPostMoveHook<T extends EObject> extends CincoRuntimeBaseClass {
	
	abstract def void postMove(T modelElement, 
		ModelElementContainer source, 
		ModelElementContainer target, 
		int x, int y, 
		int deltaX, int deltaY
	);
	
}