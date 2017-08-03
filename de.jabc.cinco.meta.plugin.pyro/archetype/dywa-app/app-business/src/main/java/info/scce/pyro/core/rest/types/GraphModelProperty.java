package info.scce.pyro.core.rest.types;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
public class GraphModelProperty extends info.scce.pyro.rest.RESTBaseImpl implements info.scce.pyro.rest.RESTBaseType
{

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

    private double scale;

    @com.fasterxml.jackson.annotation.JsonProperty("scale")
    public double getscale() {
        return this.scale;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("scale")
    public void setscale(final double scale) {
        this.scale = scale;
    }




    public static GraphModelProperty fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.GraphModel entity) {

        final GraphModelProperty result;
        result = new GraphModelProperty();
        result.setDywaId(entity.getDywaId());
        result.setDywaName(entity.getDywaName());
        result.setDywaVersion(entity.getDywaVersion());

        result.setconnector(entity.getconnector());
        result.setrouter(entity.getrouter());
        result.setwidth(entity.getwidth());
        result.setheight(entity.getheight());
        result.setscale(entity.getscale());


        return result;
    }
}
