package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
public class PyroEnum
{
    private String dywaName;

    @com.fasterxml.jackson.annotation.JsonProperty("dywaName")
    public String getdywaName() {
        return this.dywaName;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("dywaName")
    public void setdywaName(final String dywaName) {
        this.dywaName = dywaName;
    }

    public static PyroEnum fromDywaEntity(final de.ls5.dywa.generated.util.Identifiable entity, String type) {
        final PyroEnum result = new PyroEnum();
        result.setdywaName(entity.getDywaName());
        return result;
    }
}