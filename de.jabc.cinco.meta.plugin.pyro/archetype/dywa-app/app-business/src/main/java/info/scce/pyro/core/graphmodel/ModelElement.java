package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class ModelElement extends IdentifiableElement
{

    private IdentifiableElement container;

    @com.fasterxml.jackson.annotation.JsonProperty("container")
    public IdentifiableElement getcontainer() {
        return this.container;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("container")
    public void setcontainer(final IdentifiableElement container) {
        this.container = container;
    }

}
