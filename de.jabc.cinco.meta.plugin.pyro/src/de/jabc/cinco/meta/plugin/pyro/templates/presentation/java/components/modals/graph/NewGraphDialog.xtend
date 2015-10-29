package de.jabc.cinco.meta.plugin.pyro.templates.presentation.java.components.modals.graph

import de.jabc.cinco.meta.plugin.pyro.templates.Templateable
import mgl.GraphModel
import java.util.ArrayList
import de.jabc.cinco.meta.plugin.pyro.model.StyledNode
import de.jabc.cinco.meta.plugin.pyro.model.StyledEdge
import java.util.HashMap
import de.jabc.cinco.meta.plugin.pyro.model.ConnectionConstraint
import de.jabc.cinco.meta.plugin.pyro.model.EmbeddingConstraint
import mgl.Type
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EPackage
import mgl.Annotation
import de.jabc.cinco.meta.plugin.pyro.utils.ModelParser

class NewGraphDialog implements Templateable{
	
	override create(GraphModel graphModel, ArrayList<StyledNode> nodes, ArrayList<StyledEdge> edges, HashMap<String, ArrayList<StyledNode>> groupedNodes, ArrayList<ConnectionConstraint> validConnections, ArrayList<EmbeddingConstraint> embeddingConstraints, ArrayList<Type> enums,ArrayList<GraphModel> graphModels,ArrayList<EPackage> ecores)
	'''
package de.mtf.dywa.components.modals.graph;

import de.ls5.dywa.generated.controller.*;
import de.ls5.dywa.generated.entity.*;
import de.mtf.dywa.pages.Pyro;
import org.apache.tapestry5.SelectModel;
import org.apache.tapestry5.ValueEncoder;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.PageRenderLinkSource;
import org.apache.tapestry5.services.SelectModelFactory;
«FOR GraphModel g : graphModels»
import de.ls5.cinco.transformation.api.«g.name.toFirstLower».*;
«IF ModelParser.isCustomeHookAvailable(g)»
import de.ls5.cinco.custom.hook.«g.name.toFirstLower».*;
«ENDIF»
«ENDFOR»


import java.util.ArrayList;
import java.util.List;

/**
 * Generated by Pyro CINCO Meta Plugin
 */
public class NewGraphDialog {


    @Inject
    private ProjectController projectController;
	«FOR GraphModel g:graphModels»
    @Inject
    private «g.name.toFirstUpper»Controller «g.name.toFirstLower»Controller;
    
    @Inject
    private C«g.name.toFirstUpper»Wrapper c«g.name.toFirstUpper»Wrapper;
	«ENDFOR»
    @InjectPage
    private Pyro pyro;

    @Parameter
    @Property
    private Project project;

    @Inject
    private Messages messages;

    @Inject
    private SelectModelFactory smf;

    @Component
    private Form newGraphDialogForm;

    @Property
    private String newGraphDialogName;

    @Property
    private String newGraphDialogType;

    @Inject
    private PageRenderLinkSource pageRenderLS;

    @Property
    private Class<? extends GraphModel> selectedGraphModel;

    @Property
    private List<Class<? extends GraphModel>> graphModels;

    private long newGraphModelId;

    private GraphModel newGraphModel;

    @Property
    @Parameter
    private String linkCss;

    public void setupRender() {

        this.graphModels = new ArrayList<Class<? extends GraphModel>>();
        «FOR GraphModel g:graphModels»
        this.graphModels.add(«g.name.toFirstUpper».class);
        «ENDFOR»
    }

    public ValueEncoder<Class<? extends GraphModel>> getTypeEncoder() {
        return new ValueEncoder<Class<? extends GraphModel>>() {

            @Override
            public Class<? extends GraphModel> toValue(String clientValue) {
                try {
                    return (Class<? extends GraphModel>) Class.forName(clientValue);
                } catch (ClassNotFoundException e) {
                    throw new RuntimeException(e);
                }
            }

            @Override
            public String toClient(Class<? extends GraphModel> value) {
                return value.getName();
            }
        };
    }
    
    public SelectModel getSelectModel() {
        return this.smf.create(graphModels, "name");
    }

    public void onValidateFromNewGraphDialogForm() {

    }
    public void onFailureFromNewGraphDialogForm() {

    }

    public void onSuccessFromNewGraphDialogForm() {
    	«FOR GraphModel g:graphModels»
        if(this.selectedGraphModel.getName().equals(«g.name.toFirstUpper».class.getName()) ) {
	        this.newGraphModel = this.«g.name.toFirstLower»Controller.create«g.name.toFirstUpper»(newGraphDialogName);
    	}
        «ENDFOR»
        this.project.getgraphModels_GraphModel().add(this.newGraphModel);
        this.newGraphModelId = newGraphModel.getId();
        this.newGraphModel.setscaleFactor(1.0);
        this.newGraphModel.setedgeTriggerWidth(10.0);
        this.newGraphModel.setedgeStyleModeConnector("normal");
        this.newGraphModel.setedgeStyleModeRouter("");
        this.newGraphModel.setsnapRadius(20.0);
        this.newGraphModel.setpaperHeight(1000.0);
        this.newGraphModel.setpaperWidth(1000.0);
        this.newGraphModel.setgridSize(1.0);
        this.newGraphModel.setresizeStep(0.1);
        this.newGraphModel.setrotateStep(5.0);
        this.newGraphModel.settheme("default");
        this.newGraphModel.setminimizedMenu(false);
        this.newGraphModel.setminimizedGraph(true);
        this.newGraphModel.setminimizedMap(false);
        «FOR GraphModel g:graphModels»
        «FOR Annotation a:g.annotations»
        «IF a.name.equals("postCreate")»
        if(this.selectedGraphModel.getName().equals(«g.name.toFirstUpper».class.getName()) ) {
	        «ModelParser.getCustomHookName(a).toFirstUpper»CustomHook «ModelParser.getCustomHookName(a).toFirstLower»CustomHook = new de.ls5.cinco.custom.hook.«g.name.toFirstLower».«ModelParser.getCustomHookName(a).toFirstUpper»CustomHook();
            C«g.name.toFirstUpper» c«g.name.toFirstUpper» = c«g.name.toFirstUpper»Wrapper.wrap«g.name.toFirstUpper»((«g.name.toFirstUpper»)this.newGraphModel);
            if(«ModelParser.getCustomHookName(a).toFirstLower»CustomHook.canExecute(c«g.name.toFirstUpper»)){
        		«ModelParser.getCustomHookName(a).toFirstLower»CustomHook.execute(c«g.name.toFirstUpper»);
        	}
    	}
        «ENDIF»
        «ENDFOR»
        «ENDFOR»
    }

    public Object onSubmitFromNewGraphDialogForm() {
        return pageRenderLS.createPageRenderLinkWithContext("Pyro", this.project.getId(),this.newGraphModel.getId());
    }

    public void onPrepare(long projectId) {
        this.project = projectController.readProject(projectId);
    }
}
	
	'''
	
}