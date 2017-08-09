package info.scce.pyro.core.command.types;


import info.scce.pyro.core.graphmodel.IdentifiableElement;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class UpdateCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("element")
    IdentifiableElement element;

    public IdentifiableElement getElement() {
        return element;
    }

    public void setElement(IdentifiableElement element) {
        this.element = element;
    }
}
