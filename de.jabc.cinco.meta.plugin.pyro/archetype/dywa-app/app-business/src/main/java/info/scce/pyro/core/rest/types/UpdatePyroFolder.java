package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class UpdatePyroFolder
{


    private long dywaId;

    @com.fasterxml.jackson.annotation.JsonProperty("dywaId")
    public long getdywaId() {
        return this.dywaId;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("dywaId")
    public void setdywaId(final long dywaId) {
        this.dywaId = dywaId;
    }

    private String name;

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public String getname() {
        return this.name;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("name")
    public void setname(final String name) {
        this.name = name;
    }


}
