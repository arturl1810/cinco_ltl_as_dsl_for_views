package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class Node extends ModelElement
{

    private long x;

    @com.fasterxml.jackson.annotation.JsonProperty("x")
    public long getx() {
        return this.x;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("x")
    public void setx(final long x) {
        this.x = x;
    }

    private long y;

    @com.fasterxml.jackson.annotation.JsonProperty("y")
    public long gety() {
        return this.y;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("y")
    public void sety(final long y) {
        this.y = y;
    }

    private long angle;

    @com.fasterxml.jackson.annotation.JsonProperty("angle")
    public long getangle() {
        return this.angle;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("angle")
    public void setangle(final long angle) {
        this.angle = angle;
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
    

    private java.util.List<Edge> incoming;

    @com.fasterxml.jackson.annotation.JsonProperty("incoming")
    public java.util.List<Edge> getincoming() {
        return this.incoming;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("incoming")
    public void setincoming(final java.util.List<Edge> incoming) {
        this.incoming = incoming;
    }

    private java.util.List<Edge> outgoing;

    @com.fasterxml.jackson.annotation.JsonProperty("outgoing")
    public java.util.List<Edge> getoutgoing() {
        return this.outgoing;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("outgoing")
    public void setoutgoing(final java.util.List<Edge> outgoing) {
        this.outgoing = outgoing;
    }

}
