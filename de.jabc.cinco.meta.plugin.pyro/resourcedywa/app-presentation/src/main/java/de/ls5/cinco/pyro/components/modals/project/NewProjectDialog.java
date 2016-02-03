package de.ls5.cinco.pyro.components.modals.project;

import de.ls5.dywa.generated.controller.ProjectController;
import de.ls5.dywa.generated.entity.Project;
import de.ls5.cinco.pyro.pages.Pyro;
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
import org.apache.tapestry5.services.PageRenderLinkSource;

import java.util.Date;

public class NewProjectDialog {

    @InjectPage
    private Pyro pyroPage;

    @Inject
    private ProjectController projectController;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Component
    private Form newProjectDialogForm;

    @Property
    private String newProjectDialogName;

    @Inject
    private PageRenderLinkSource pageRenderLS;

    private Project newProject;

    @Property
    @Parameter
    private String linkCss;

    @Parameter
    @Property
    private boolean isExplorerPage = true;

    public void onValidateFromNewProjectDialogForm() {
        if (this.newProjectDialogName != null && !this.newProjectDialogName.isEmpty()) {
            if (!projectController.fetchProject().isEmpty()) {
                for(Project project : this.projectController.fetchProject())
                {
                    if(project.getName().equals(newProjectDialogName)){
                        newProjectDialogForm.recordError(messages.get("name-in-use"));
                        return;
                    }
                }
                //TODO Validate Unique Name depending on the user
            }
        }
        else {
            newProjectDialogForm.recordError(messages.get("invalid-name"));
        }
    }

    public void onFailureFromNewProjectDialogForm() {
        for (String str : newProjectDialogForm.getDefaultTracker().getErrors()) {
            alertManager.alert(Duration.TRANSIENT, Severity.ERROR, str);
        }
    }

    public void onSuccessFromNewProjectDialogForm() {

        this.newProject = this.projectController.createProject(newProjectDialogName);
        this.newProject.setcreated(new Date());
        this.newProject.setedited(new Date());

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-created", newProjectDialogName));
    }

    public Object onSubmitFromNewProjectDialogForm() {
        return this.projectsPage;

    }
}
