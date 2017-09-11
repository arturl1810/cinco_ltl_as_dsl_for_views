package info.scce.pyro.core.command;

import de.ls5.dywa.generated.controller.info.scce.pyro.core.BendingPointController;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.EdgeController;
import de.ls5.dywa.generated.controller.info.scce.pyro.core.NodeController;

/**
 * Author zweihoff
 */
public class ControllerBundle {
    NodeController nodeController;

    EdgeController edgeController;

    BendingPointController bendingPointController;

    ControllerBundle(NodeController nodeController,EdgeController edgeController,BendingPointController bendingPointController) {
        this.nodeController = nodeController;
        this.edgeController = edgeController;
        this.bendingPointController = bendingPointController;
    }
}
