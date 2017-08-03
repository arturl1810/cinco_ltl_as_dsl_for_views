package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class ReconnectEdgeCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("oldSourceId")
    long oldSourceId;
    @com.fasterxml.jackson.annotation.JsonProperty("sourceId")
    long sourceId;
    @com.fasterxml.jackson.annotation.JsonProperty("oldTargetId")
    long oldTargetId;
    @com.fasterxml.jackson.annotation.JsonProperty("targetId")
    long targetId;

    public long getOldSourceId() {
        return oldSourceId;
    }

    public void setOldSourceId(long oldSourceId) {
        this.oldSourceId = oldSourceId;
    }

    public long getSourceId() {
        return sourceId;
    }

    public void setSourceId(long sourceId) {
        this.sourceId = sourceId;
    }

    public long getOldTargetId() {
        return oldTargetId;
    }

    public void setOldTargetId(long oldTargetId) {
        this.oldTargetId = oldTargetId;
    }

    public long getTargetId() {
        return targetId;
    }

    public void setTargetId(long targetId) {
        this.targetId = targetId;
    }
}
