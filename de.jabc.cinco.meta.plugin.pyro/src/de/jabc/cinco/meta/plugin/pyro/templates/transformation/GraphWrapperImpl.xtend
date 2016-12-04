package de.jabc.cinco.meta.plugin.pyro.templates.transformation

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable

class GraphWrapperImpl implements Templateable{
	
	override create(TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.transformation.api.«tc.graphModel.name.toFirstLower»;
		
		import de.ls5.dywa.generated.entity.*;
		
		import javax.enterprise.context.RequestScoped;
		import javax.inject.Inject;
		import javax.inject.Named;
		import java.util.ArrayList;
		import java.util.List;
		
		/**
		 * Created by Pyro CINCO Meta Plugin.
		 */
		@Named("c«tc.graphModel.name.toFirstUpper»Wrapper")
		@RequestScoped
		public class C«tc.graphModel.name.toFirstUpper»WrapperImpl implements C«tc.graphModel.name.toFirstUpper»Wrapper{
			
			@Inject
			private C«tc.graphModel.name.toFirstUpper» c«tc.graphModel.name.toFirstUpper»;
			
		
		    public C«tc.graphModel.name.toFirstUpper» wrap«tc.graphModel.name.toFirstUpper»(«tc.graphModel.name.toFirstUpper» «tc.graphModel.name.toFirstLower»){
		        c«tc.graphModel.name.toFirstUpper».setModelElementContainer(«tc.graphModel.name.toFirstLower»);
		        return c«tc.graphModel.name.toFirstUpper»;
		    }
		}
	'''
}