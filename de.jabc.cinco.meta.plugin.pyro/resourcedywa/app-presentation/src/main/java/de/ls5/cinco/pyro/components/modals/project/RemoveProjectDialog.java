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

public class RemoveProjectDialog {

    @Inject
    private ProjectController projectController;

    @Parameter
    @Property
    private Project projectToRemove;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Property
    @Parameter
    private String linkCss;

    @Component
    private Form removeProjectDialogForm;

    public void onValidateFromRemoveProjectDialogForm() {

    }

    public void onFailureFromremoveProjectDialogForm() {
    }

    public void onSuccessFromremoveProjectDialogForm() {

        String projectName = projectToRemove.getName();
        this.projectController.deleteProject(projectToRemove);
        this.projectsPage.setupRender();

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-removed", projectName));

    }

    public Object onSubmitFromremoveProjectDialogForm() {
        return this.projectsPage;
    }

    public void onPrepare(long projectId) {
        this.projectToRemove = projectController.readProject(projectId);
    }
}
