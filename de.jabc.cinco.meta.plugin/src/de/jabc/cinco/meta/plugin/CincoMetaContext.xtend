package de.jabc.cinco.meta.plugin

import de.jabc.cinco.meta.core.utils.xapi.GraphModelExtension
import de.jabc.cinco.meta.util.xapi.CodingExtension
import de.jabc.cinco.meta.util.xapi.CollectionExtension
import de.jabc.cinco.meta.util.xapi.WorkspaceExtension
import mgl.GraphModel
import org.eclipse.xtend.lib.annotations.Accessors
import productDefinition.CincoProduct

abstract class CincoMetaContext {
	
	protected extension CodingExtension = new CodingExtension
	protected extension CollectionExtension = new CollectionExtension
	protected extension WorkspaceExtension = new WorkspaceExtension
	protected extension GraphModelExtension = new GraphModelExtension
	
	@Accessors(PROTECTED_GETTER,PUBLIC_SETTER) GraphModel model
	@Accessors(PROTECTED_GETTER,PUBLIC_SETTER) CincoProduct cpd
	
	new() {/* empty constructor for instantiation via reflection */}
	
	def <T extends CincoMetaContext> T withContext(T obj, CincoMetaContext context) {
		obj.setModel(context.getModel)
		obj.setCpd(context.getCpd)
		return obj
	}
}