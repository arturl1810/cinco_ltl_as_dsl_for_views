package de.jabc.cinco.meta.plugin.behavior.runtime.behaviorInterface;

import graphmodel.Container;
import graphmodel.Node;

/**
 *  Interface that specifies how a behavior provider for the MetaPlugin 
 *  behaviorModification works. Classes which are passed to the plugin
 *  with the annotation behavior have to implement this Interface.
 *  The implementing class should specify a behavior for a container, that is triggered,
 *  whenever a node enters or leaves that container, including when it is created in that container
 *  but excluding when it is deleted there.  
 */
public interface BehaviorProvider{
	/**
	 * Method which is called whenever a node leaves the specified container.
	 * @param leftNode node that left source
	 * @param source the specified container
	 */
	public void hasLeft(Node leftNode, Container source);
	/**
	 * Method which is called whenever a node enters the specified container.
	 * @param enteredNode node that entered target
	 * @param target the specified container
	 */
	public void hasEntered(Node enteredNode, Container target);
	
}
