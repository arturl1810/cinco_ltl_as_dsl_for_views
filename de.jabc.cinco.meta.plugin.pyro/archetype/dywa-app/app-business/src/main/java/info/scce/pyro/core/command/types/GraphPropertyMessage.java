package info.scce.pyro.core.command.types;

import info.scce.pyro.core.rest.types.GraphModelProperty;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class GraphPropertyMessage extends Message{
    @com.fasterxml.jackson.annotation.JsonProperty("graph")
    private GraphModelProperty graph;

    public GraphPropertyMessage() {
        super();
        super.setMessageType("graph");
    }

    public GraphModelProperty getGraph() {
        return graph;
    }

    public void setGraph(GraphModelProperty graph) {
        this.graph = graph;
    }
}
