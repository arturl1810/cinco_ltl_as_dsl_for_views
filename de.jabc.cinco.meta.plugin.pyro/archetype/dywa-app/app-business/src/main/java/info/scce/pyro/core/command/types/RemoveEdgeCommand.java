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
public class RemoveEdgeCommand extends Command {
    @com.fasterxml.jackson.annotation.JsonProperty("sourceId")
    long sourceId;
    @com.fasterxml.jackson.annotation.JsonProperty("targetId")
    long targetId;
    @com.fasterxml.jackson.annotation.JsonProperty("positions")
    java.util.List<BendingPoint> positions;

    public RemoveEdgeCommand(){
        positions = new LinkedList<>();
    }

    public long getSourceId() {
        return sourceId;
    }

    public void setSourceId(long sourceId) {
        this.sourceId = sourceId;
    }

    public long getTargetId() {
        return targetId;
    }

    public void setTargetId(long targetId) {
        this.targetId = targetId;
    }

    public List<BendingPoint> getPositions() {
        return positions;
    }

    public void setPositions(List<BendingPoint> positions) {
        this.positions = positions;
    }
}
