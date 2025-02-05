package info.scce.pyro.core.command.types;

import info.scce.pyro.core.graphmodel.IdentifiableElement;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class CreateNodeCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("x")
    long x;
    @com.fasterxml.jackson.annotation.JsonProperty("y")
    long y;
    @com.fasterxml.jackson.annotation.JsonProperty("width")
    long width;
    @com.fasterxml.jackson.annotation.JsonProperty("height")
    long height;
    @com.fasterxml.jackson.annotation.JsonProperty("containerId")
    long containerId;
    @com.fasterxml.jackson.annotation.JsonProperty("primeId")
    long primeId;
    @com.fasterxml.jackson.annotation.JsonProperty("primeElement")
    info.scce.pyro.core.graphmodel.IdentifiableElement primeElement;

    public long getX() {
        return x;
    }

    public void setX(long x) {
        this.x = x;
    }

    public long getY() {
        return y;
    }

    public void setY(long y) {
        this.y = y;
    }

    public long getWidth() {
        return width;
    }

    public void setWidth(long width) {
        this.width = width;
    }

    public long getHeight() {
        return height;
    }

    public void setHeight(long height) {
        this.height = height;
    }

    public long getContainerId() {
        return containerId;
    }

    public void setContainerId(long containerId) {
        this.containerId = containerId;
    }

    public long getPrimeId() {
        return primeId;
    }

    public void setPrimeId(long primeId) {
        this.primeId = primeId;
    }

    public IdentifiableElement getPrimeElement() {
        return primeElement;
    }

    public void setPrimeElement(IdentifiableElement primeElement) {
        this.primeElement = primeElement;
    }
}
