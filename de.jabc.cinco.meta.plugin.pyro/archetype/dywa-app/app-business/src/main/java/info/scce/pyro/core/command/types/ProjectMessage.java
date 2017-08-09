package info.scce.pyro.core.command.types;

import info.scce.pyro.core.rest.types.PyroProject;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class ProjectMessage extends Message{
    @com.fasterxml.jackson.annotation.JsonProperty("project")
    private PyroProject project;

    public ProjectMessage() {
        super();
        super.setMessageType("project");
    }

    public PyroProject getProject() {
        return project;
    }

    public void setProject(PyroProject project) {
        this.project = project;
    }
}
