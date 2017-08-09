package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public abstract class Command {
    @com.fasterxml.jackson.annotation.JsonProperty("delegateId")
    long delegateId;
    @com.fasterxml.jackson.annotation.JsonProperty("dywaVersion")
    long dywaVersion;
    @com.fasterxml.jackson.annotation.JsonProperty("dywaName")
    String dywaName;
    @com.fasterxml.jackson.annotation.JsonProperty("type")
    String type;

    public long getDelegateId() {
        return delegateId;
    }

    public void setDelegateId(long delegateId) {
        this.delegateId = delegateId;
    }

    public long getDywaVersion() {
        return dywaVersion;
    }

    public void setDywaVersion(long dywaVersion) {
        this.dywaVersion = dywaVersion;
    }

    public String getDywaName() {
        return dywaName;
    }

    public void setDywaName(String dywaName) {
        this.dywaName = dywaName;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }
}
