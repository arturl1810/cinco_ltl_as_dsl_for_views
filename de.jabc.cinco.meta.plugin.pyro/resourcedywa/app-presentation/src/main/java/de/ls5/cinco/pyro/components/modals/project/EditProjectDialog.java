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

public class EditProjectDialog {

    @Inject
    private ProjectController projectController;

    @Parameter
    @Property
    private Project projectToEdit;

    @Inject
    private AlertManager alertManager;

    @Inject
    private Messages messages;

    @InjectPage
    private Projects projectsPage;

    @Component
    private Form editProjectDialogForm;

    @Property
    private String editProjectDialogName;

    @Property
    @Parameter
    private String linkCss;

    public void onValidateFromeditProjectDialogForm() {
        if (this.editProjectDialogName != null && !this.editProjectDialogName.isEmpty()) {
            if (!projectController.fetchProject().isEmpty()) {
                for(Project project : this.projectController.fetchProject())
                {
                    if(project.getName().equals(editProjectDialogName)){
                        editProjectDialogForm.recordError(messages.get("name-in-use"));
                        return;
                    }
                }
                //TODO Validate Unique Name depending on the user
            }
        }
        else {
            editProjectDialogForm.recordError(messages.get("invalid-name"));
        }
    }


    public void onFailureFromeditProjectDialogForm() {
        for (String str : editProjectDialogForm.getDefaultTracker().getErrors()) {
            alertManager.alert(Duration.TRANSIENT, Severity.ERROR, str);
        }
    }

    public void onSuccessFromeditProjectDialogForm() {

        this.projectToEdit.setName(editProjectDialogName);
        this.projectToEdit.setedited(new Date());

        alertManager.alert(Duration.TRANSIENT, Severity.INFO,
                messages.format("successfully-edited", editProjectDialogName));

    }

    public Object onSubmitFromeditProjectDialogForm() {
        return this.projectsPage;
    }

    public void setupRender() {
        this.editProjectDialogName = projectToEdit.getName();
    }

    public void onPrepare(long projectId) {
        this.projectToEdit = projectController.readProject(projectId);
    }
}
