package de.ls5.cinco.pyro.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.ls5.cinco.pyro.pages.Projects;
import org.apache.tapestry5.alerts.AlertManager;
import org.apache.tapestry5.alerts.Duration;
import org.apache.tapestry5.alerts.Severity;
import org.apache.tapestry5.annotations.Component;
import org.apache.tapestry5.annotations.InjectPage;
import org.apache.tapestry5.annotations.Parameter;
import org.apache.tapestry5.annotations.Property;
import org.apache.tapestry5.corelib.components.Form;
import org.apache.tapestry5.ioc.Messages;
import org.apache.tapestry5.ioc.annotations.Inject;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class OpenProjectDialog {

    @Inject
    private ProjectController projectController;

    @Property
    private List<Project> projects;

    @Property
    private Project iteratedProject;

    @Property
    @Parameter
    private String linkCss;

    @Property
    private int index;

    public void setupRender() {
        this.projects = new ArrayList<Project>(projectController.fetchProject());
    }
}
