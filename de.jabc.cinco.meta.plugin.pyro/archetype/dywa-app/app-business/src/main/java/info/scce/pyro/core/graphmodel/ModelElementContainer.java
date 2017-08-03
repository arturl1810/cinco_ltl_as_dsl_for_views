package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class ModelElementContainer extends IdentifiableElement
{

    private java.util.List<ModelElement> modelElements;

    @com.fasterxml.jackson.annotation.JsonProperty("modelElements")
    public java.util.List<ModelElement> getmodelElements() {
        return this.modelElements;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("modelElements")
    public void setmodelElements(final java.util.List<ModelElement> modelElements) {
        this.modelElements = modelElements;
    }

}
