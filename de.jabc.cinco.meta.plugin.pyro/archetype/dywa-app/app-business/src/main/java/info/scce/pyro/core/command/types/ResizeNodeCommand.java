package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class ResizeNodeCommand extends Command{
    @com.fasterxml.jackson.annotation.JsonProperty("oldWidth")
    long oldWidth;
    @com.fasterxml.jackson.annotation.JsonProperty("width")
    long width;
    @com.fasterxml.jackson.annotation.JsonProperty("oldHeight")
    long oldHeight;
    @com.fasterxml.jackson.annotation.JsonProperty("height")
    long height;
    @com.fasterxml.jackson.annotation.JsonProperty("direction")
    String direction;

    public long getOldWidth() {
        return oldWidth;
    }

    public void setOldWidth(long oldWidth) {
        this.oldWidth = oldWidth;
    }

    public long getWidth() {
        return width;
    }

    public void setWidth(long width) {
        this.width = width;
    }

    public long getOldHeight() {
        return oldHeight;
    }

    public void setOldHeight(long oldHeight) {
        this.oldHeight = oldHeight;
    }

    public long getHeight() {
        return height;
    }

    public void setHeight(long height) {
        this.height = height;
    }

    public String getDirection() {
        return direction;
    }

    public void setDirection(String direction) {
        this.direction = direction;
    }
}
