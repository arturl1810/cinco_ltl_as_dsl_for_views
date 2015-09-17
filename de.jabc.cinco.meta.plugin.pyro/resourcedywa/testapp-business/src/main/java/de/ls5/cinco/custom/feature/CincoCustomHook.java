package de.ls5.cinco.custom.feature;

import de.ls5.cinco.transformation.api.CIdentifiableElement;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public abstract class CincoCustomHook<T extends CIdentifiableElement> {

    public abstract boolean canExecute(T cModelElement);
    public abstract void execute(T cModelElement);
}
