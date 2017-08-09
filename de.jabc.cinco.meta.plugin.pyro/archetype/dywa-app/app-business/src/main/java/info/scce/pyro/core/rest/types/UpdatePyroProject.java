package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class UpdatePyroProject
{

    private long projectId = -1;

    @com.fasterxml.jackson.annotation.JsonProperty("projectId")
    public long getprojectId() {
        return this.projectId;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("projectId")
    public void setprojectId(final long projectId) {
        this.projectId = projectId;
    }

    private long userId = -1;

    @com.fasterxml.jackson.annotation.JsonProperty("userId")
    public long getuserId() {
        return this.userId;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("userId")
    public void setuserId(final long userId) {
        this.userId = userId;
    }


}
