package info.scce.pyro.core.command.types;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class RotateNodeCommand extends Command{
    @com.fasterxml.jackson.annotation.JsonProperty("oldAngle")
    long oldAngle;
    @com.fasterxml.jackson.annotation.JsonProperty("angle")
    long angle;

    public long getOldAngle() {
        return oldAngle;
    }

    public void setOldAngle(long oldAngle) {
        this.oldAngle = oldAngle;
    }

    public long getAngle() {
        return angle;
    }

    public void setAngle(long angle) {
        this.angle = angle;
    }
}
