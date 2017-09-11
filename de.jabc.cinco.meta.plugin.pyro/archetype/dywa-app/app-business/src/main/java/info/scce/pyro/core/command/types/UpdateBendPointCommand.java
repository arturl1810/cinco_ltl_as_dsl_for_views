package info.scce.pyro.core.command.types;

import info.scce.pyro.core.graphmodel.BendingPoint;

import java.util.LinkedList;
import java.util.List;

/**
 * Author zweihoff
 */
@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class UpdateBendPointCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("oldPositions")
    java.util.List<BendingPoint> oldPositions;
    @com.fasterxml.jackson.annotation.JsonProperty("positions")
    java.util.List<BendingPoint> positions;

    public UpdateBendPointCommand() {
        oldPositions = new LinkedList<>();
        positions = new LinkedList<>();
    }

    public List<BendingPoint> getOldPositions() {
        return oldPositions;
    }

    public void setOldPositions(List<BendingPoint> oldPositions) {
        this.oldPositions = oldPositions;
    }

    public List<BendingPoint> getPositions() {
        return positions;
    }

    public void setPositions(List<BendingPoint> positions) {
        this.positions = positions;
    }
}
