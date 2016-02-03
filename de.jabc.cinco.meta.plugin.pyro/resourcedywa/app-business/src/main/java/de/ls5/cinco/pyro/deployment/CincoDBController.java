package de.ls5.cinco.pyro.deployment;

/**
 * Created by zweihoff on 23.03.15.
 */
public interface CincoDBController {

    /**
     * Creates all necessary DBTypes for the underlying Cinco GraphModel.ecore and MGL
     */
    public void createGraphModelDBTypes();

    public void removeGraphModelDBTypes();

}
