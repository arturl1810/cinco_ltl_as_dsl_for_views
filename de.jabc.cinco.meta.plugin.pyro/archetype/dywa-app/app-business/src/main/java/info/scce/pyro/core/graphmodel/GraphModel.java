package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class GraphModel extends ModelElementContainer
{

    private double scale;

    @com.fasterxml.jackson.annotation.JsonProperty("scale")
    public double getscale() {
        return this.scale;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("scale")
    public void setscale(final double scale) {
        this.scale = scale;
    }
    
    private long width;

    @com.fasterxml.jackson.annotation.JsonProperty("width")
    public long getwidth() {
        return this.width;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("width")
    public void setwidth(final long width) {
        this.width = width;
    }

    private long height;

    @com.fasterxml.jackson.annotation.JsonProperty("height")
    public long getheight() {
        return this.height;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("height")
    public void setheight(final long height) {
        this.height = height;
    }
    
    private String filename;

    @com.fasterxml.jackson.annotation.JsonProperty("filename")
    public String getfilename() {
        return this.filename;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("filename")
    public void setfilename(final String filename) {
        this.filename = filename;
    }


    private String router;

    @com.fasterxml.jackson.annotation.JsonProperty("router")
    public String getrouter() {
        return this.router;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("router")
    public void setrouter(final String router) {
        this.router = router;
    }

    private String connector;

    @com.fasterxml.jackson.annotation.JsonProperty("connector")
    public String getconnector() {
        return this.connector;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("connector")
    public void setconnector(final String connector) {
        this.connector = connector;
    }

}
