package de.ls5.cinco.pyro.pages;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.beaneditor.BeanModel;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;
import org.apache.tapestry5.services.BeanModelSource;

import java.util.ArrayList;
import java.util.List;

public class Projects {

    @Inject
    private ProjectController projectController;

    @Property
    private int index;

    @Inject
    private Messages messages;

    @Property
    private Project iteratedProject;

    @Property
    private List<Project> projects;

    @Property
    private int rowIndex;

    @Inject
    private BeanModelSource beanModelSource;

    public BeanModel<Project> getModel(){
        BeanModel<Project> projectBeanModel = beanModelSource.createDisplayModel(Project.class, messages);
        projectBeanModel.addEmpty("actions");
        projectBeanModel.addEmpty("counter");
        projectBeanModel.include("counter","name","edited","created","actions");
        return projectBeanModel;
    }


    public void setupRender() {

        this.projects = new ArrayList<Project>(this.projectController.fetchProject());
    }

    public String getNewBtnCss() {
        return "btn btn-success";
    }

    public String getRemoveBtnCss() {
        return "btn btn-danger";
    }

    public String getEditBtnCss() {
        return "btn btn-primary";
    }

}
