package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public abstract class GraphMessage extends Message{
    @com.fasterxml.jackson.annotation.JsonProperty("graphModelId")
    long graphModelId;

    public long getGraphModelId() {
        return graphModelId;
    }

    public void setGraphModelId(long graphModelId) {
        this.graphModelId = graphModelId;
    }
}
