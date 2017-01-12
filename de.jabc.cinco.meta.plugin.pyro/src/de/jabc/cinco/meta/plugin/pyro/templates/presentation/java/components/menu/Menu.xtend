package de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.menu

import de.jabc.cinco.meta.plugin.pyro.model.TemplateContainer
import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphModel

class Menu implements Templateable{
	
	override create(TemplateContainer tc)
	'''
		package de.ls5.cinco.pyro.components.menubar;

		import de.ls5.dywa.generated.controller.*;
		import de.ls5.dywa.generated.entity.*;
		import org.apache.tapestry5.ComponentResources;
		import org.apache.tapestry5.SymbolConstants;
		import org.apache.tapestry5.annotations.Parameter;
		import org.apache.tapestry5.annotations.Property;
		import org.apache.tapestry5.ioc.annotations.Inject;
		import org.apache.tapestry5.ioc.annotations.Symbol;
		import org.apache.tapestry5.services.Request;
		import org.apache.tapestry5.util.TextStreamResponse;
		
		import java.util.ArrayList;
		import java.util.List;
		
		/**
		 * Generated by Pyro CINCO Meta Plugin
		 */
		public class Menu {
		
		    @Property
		    @Inject
		    @Symbol(SymbolConstants.TAPESTRY_VERSION)
		    private String tapestryVersion;
		
		    @Inject
		    private ProjectController projectController;
		
			«FOR GraphModel g:tc.graphModels»
		    @Inject
		    private «g.name.toFirstUpper»Controller «g.name.toFirstLower»Controller;
			«ENDFOR»
			
			@Property
		    @Parameter
		    private GraphModel openedGraphModel;
		
		    @Property
		    private GraphModel iteratedGraphModel;
			
		    @Property
		    @Parameter(allowNull = false)
		    private Project openedProject;
		
		    @Property
		    private Project iteratedProject;
		
		    
		
		    @Property
		    private List<Project> projectList;
		
		    public void setupRender() {
		        if(this.openedProject != null){
		            if(this.openedGraphModel == null) {
		                if(isGraphContained()) {
		                    this.openedGraphModel = this.openedProject.getgraphModels_GraphModel().get(0);
		                }
		            }
		        }
		        this.projectList = new ArrayList<Project>(this.projectController.fetchProject());
		    }
		
		    public boolean isGraphContained() {
		        return !openedProject.getgraphModels_GraphModel().isEmpty();
		    }
		
		    public boolean isProjectLoaded() {
		        return openedProject != null;
		    }
		
		    public boolean isGraphLoaded() {
		        return openedGraphModel != null;
		    }
		
		    public String getNewBtnCss() {
		        return "";
		    }
		
		    public String getOpenBtnCss() {
		        return "";
		    }
		
		    public String getRemoveBtnCss() {
		        return "";
		    }
		
		    public String getEditBtnCss() {
		        return "";
		    }
		
		}
	'''	
}