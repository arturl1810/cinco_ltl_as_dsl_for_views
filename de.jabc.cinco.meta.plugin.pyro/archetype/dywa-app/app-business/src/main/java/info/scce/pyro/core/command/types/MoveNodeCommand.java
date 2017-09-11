package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class MoveNodeCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("oldX")
    long oldX;
    @com.fasterxml.jackson.annotation.JsonProperty("oldY")
    long oldY;
    @com.fasterxml.jackson.annotation.JsonProperty("x")
    long x;
    @com.fasterxml.jackson.annotation.JsonProperty("y")
    long y;
    @com.fasterxml.jackson.annotation.JsonProperty("oldContainerId")
    long oldContainerId;
    @com.fasterxml.jackson.annotation.JsonProperty("containerId")
    long containerId;

    public long getOldX() {
        return oldX;
    }

    public void setOldX(long oldX) {
        this.oldX = oldX;
    }

    public long getOldY() {
        return oldY;
    }

    public void setOldY(long oldY) {
        this.oldY = oldY;
    }

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

    public long getOldContainerId() {
        return oldContainerId;
    }

    public void setOldContainerId(long oldContainerId) {
        this.oldContainerId = oldContainerId;
    }

    public long getContainerId() {
        return containerId;
    }

    public void setContainerId(long containerId) {
        this.containerId = containerId;
    }
}

