package info.scce.pyro.core.graphmodel;

/**
 * Author zweihoff
 */

@com.fasterxml.jackson.annotation.JsonFilter("DIME_Selective_Filter")
@com.fasterxml.jackson.annotation.JsonIdentityInfo(generator = com.voodoodyne.jackson.jsog.JSOGGenerator.class)
@com.fasterxml.jackson.annotation.JsonTypeInfo(use = com.fasterxml.jackson.annotation.JsonTypeInfo.Id.CLASS, property = info.scce.pyro.util.Constants.DYWA_RUNTIME_TYPE)
public class Edge extends ModelElement
{

    private Node sourceElement;

    @com.fasterxml.jackson.annotation.JsonProperty("sourceElement")
    public Node getsourceElement() {
        return this.sourceElement;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("sourceElement")
    public void setsourceElement(final Node sourceElement) {
        this.sourceElement = sourceElement;
    }

    private Node targetElement;

    @com.fasterxml.jackson.annotation.JsonProperty("targetElement")
    public Node gettargetElement() {
        return this.targetElement;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("targetElement")
    public void settargetElement(final Node targetElement) {
        this.targetElement = targetElement;
    }

    private java.util.List<BendingPoint> bendingPoints;

    @com.fasterxml.jackson.annotation.JsonProperty("bendingPoints")
    public java.util.List<BendingPoint> getbendingPoints() {
        return this.bendingPoints;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("bendingPoints")
    public void setbendingPoints(final java.util.List<BendingPoint> bendingPoints) {
        this.bendingPoints = bendingPoints;
    }

}
