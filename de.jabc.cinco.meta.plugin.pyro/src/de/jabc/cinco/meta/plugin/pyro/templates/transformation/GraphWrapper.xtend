package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable

class GraphWrapper extends Templateable{
	
	override create(TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
		import de.ls5.dywa.generated.entity.*;
		
		import java.util.ArrayList;
		import java.util.List;
		
		/**
		 * Created by Pyro CINCO Meta Plugin.
		 */
		public interface C«tc.graphModel.name.toFirstUpper»Wrapper {
		    public C«tc.graphModel.name.toFirstUpper» wrap«tc.graphModel.name.toFirstUpper»(«tc.graphModel.name.toFirstUpper» «tc.graphModel.name.toFirstLower»);
		}
	'''
}
