package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class BendingPoint
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


    public static BendingPoint fromDywaEntity(final de.ls5.dywa.generated.entity.info.scce.pyro.core.BendingPoint entity) {

        final BendingPoint result;
        result = new BendingPoint();
        result.setx(entity.getx());
        result.sety(entity.gety());

        return result;
    }



}
