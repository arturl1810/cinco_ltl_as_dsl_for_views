package info.scce.pyro.core.command.types;

import info.scce.pyro.core.graphmodel.IdentifiableElement;
import info.scce.pyro.core.rest.types.PyroProject;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class PropertyMessage extends GraphMessage {

    @com.fasterxml.jackson.annotation.JsonProperty("graphModelType")
    private String graphModelType;

    @com.fasterxml.jackson.annotation.JsonProperty("delegate")
    private IdentifiableElement delegate;

    public PropertyMessage() {
        super();
        super.setMessageType("property");
    }

    public String getGraphModelType() {
        return graphModelType;
    }

    public void setGraphModelType(String graphModelType) {
        this.graphModelType = graphModelType;
    }

    public IdentifiableElement getDelegate() {
        return delegate;
    }

    public void setDelegate(IdentifiableElement delegate) {
        this.delegate = delegate;
    }
}
