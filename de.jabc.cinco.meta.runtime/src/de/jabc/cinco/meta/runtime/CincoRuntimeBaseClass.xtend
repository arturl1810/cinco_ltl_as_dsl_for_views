package de.jabc.cinco.meta.runtime

import de.jabc.cinco.meta.runtime.xapi.FileExtension
import de.jabc.cinco.meta.runtime.xapi.GraphModelExtension
import de.jabc.cinco.meta.runtime.xapi.ResourceExtension
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import de.jabc.cinco.meta.util.xapi.CollectionExtension
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension

class CincoRuntimeBaseClass {
	protected extension CollectionExtension = new CollectionExtension
    protected extension WorkspaceExtension = new WorkspaceExtension
    protected extension WorkbenchExtension = new WorkbenchExtension
    protected extension GraphModelExtension = new GraphModelExtension
    protected extension ResourceExtension = new ResourceExtension
    protected extension FileExtension = new FileExtension
}