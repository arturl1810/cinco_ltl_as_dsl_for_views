package info.scce.pyro.core.command;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.BendingPoint;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.Edge;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.GraphModel;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.IdentifiableElement;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.ModelElement;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.ModelElementContainer;
import de.ls5.dywa.generated.entity.info.scce.pyro.core.Node;

import info.scce.pyro.core.command.types.*;

import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;


/**
 * Author zweihoff
 */
public class CommandExecuter {

    final ControllerBundle controllerBundle;
    protected final BatchExecution batch;
    CommandExecuter(ControllerBundle controllerBundle,BatchExecution batch) {
        this.controllerBundle = controllerBundle;
        this.batch = batch;
    }

    protected void createNode(String type,Node node, ModelElementContainer modelElementContainer,long x, long y,long width, long height){
        createNode(type,node, modelElementContainer,x, y,width, height,null);
    }


    protected void createNode(String type, Node node, ModelElementContainer modelElementContainer, long x, long y, long width, long height, info.scce.pyro.core.graphmodel.IdentifiableElement primeElement){

        info.scce.pyro.core.command.types.CreateNodeCommand cmd = new CreateNodeCommand();
        cmd.setDelegateId(node.getDywaId());
        cmd.setDywaVersion(node.getDywaVersion());
        cmd.setDywaName(node.getDywaName());
        cmd.setContainerId(modelElementContainer.getDywaId());
        cmd.setWidth(width);
        cmd.setHeight(height);
        cmd.setX(x);
        cmd.setY(y);
        cmd.setType(type);
        if(primeElement!=null){
            cmd.setPrimeId(primeElement.getDywaId());
            cmd.setPrimeElement(primeElement);
        }
        batch.add(cmd);

        node.setcontainer(modelElementContainer);
        modelElementContainer.getmodelElements_ModelElement().add(node);
        node.setx(x);
        node.sety(y);
        node.setwidth(width);
        node.setheight(height);
    }

    protected void moveNode(String type,Node node, ModelElementContainer modelElementContainer, long x, long y){

        info.scce.pyro.core.command.types.MoveNodeCommand cmd = new MoveNodeCommand();
        cmd.setDelegateId(node.getDywaId());
        cmd.setDywaVersion(node.getDywaVersion());
        cmd.setDywaName(node.getDywaName());
        cmd.setOldContainerId(node.getcontainer().getDywaId());
        cmd.setContainerId(modelElementContainer.getDywaId());
        cmd.setOldX(node.getx());
        cmd.setOldY(node.gety());
        cmd.setX(x);
        cmd.setY(y);
        cmd.setType(type);
        batch.add(cmd);

        node.getcontainer().getmodelElements_ModelElement().remove(node);
        node.setcontainer(modelElementContainer);
        modelElementContainer.getmodelElements_ModelElement().add(node);
        node.setx(x);
        node.sety(y);
    }

    protected void resizeNode(String type,Node node, long width, long height){

        info.scce.pyro.core.command.types.ResizeNodeCommand cmd = new ResizeNodeCommand();
        cmd.setDelegateId(node.getDywaId());
        cmd.setDywaVersion(node.getDywaVersion());
        cmd.setDywaName(node.getDywaName());
        cmd.setOldHeight(node.getheight());
        cmd.setOldWidth(node.getwidth());
        cmd.setWidth(width);
        cmd.setHeight(height);
        cmd.setType(type);
        batch.add(cmd);

        node.setwidth(width);
        node.setheight(height);
    }

    protected void rotateNode(String type,Node node,long angle){
        info.scce.pyro.core.command.types.RotateNodeCommand cmd = new RotateNodeCommand();
        cmd.setDelegateId(node.getDywaId());
        cmd.setDywaVersion(node.getDywaVersion());
        cmd.setDywaName(node.getDywaName());
        cmd.setOldAngle(node.getangle());
        cmd.setAngle(angle);
        cmd.setType(type);
        batch.add(cmd);

        node.setangle(angle);
    }

    protected void removeNode(String type,Node node,info.scce.pyro.core.graphmodel.IdentifiableElement primeNode){
        info.scce.pyro.core.command.types.RemoveNodeCommand cmd = new RemoveNodeCommand();
        cmd.setDelegateId(node.getDywaId());
        cmd.setDywaVersion(node.getDywaVersion());
        cmd.setDywaName(node.getDywaName());
        cmd.setContainerId(node.getcontainer().getDywaId());
        cmd.setWidth(node.getwidth());
        cmd.setHeight(node.getheight());
        cmd.setX(node.getx());
        cmd.setY(node.gety());
        cmd.setType(type);
        if(primeNode != null){
            cmd.setPrimeId(primeNode.getDywaId());
            cmd.setPrimeElement(primeNode);
        }
        
        batch.add(cmd);

        node.getcontainer().getmodelElements_ModelElement().remove(node);
        node.setcontainer(null);
        //remove edges
        node.getincoming_Edge().forEach(e->e.settargetElement(null));
        node.getincoming_Edge().clear();
        node.getoutgoing_Edge().forEach(e->e.setsourceElement(null));
        node.getoutgoing_Edge().clear();
        //controllerBundle.nodeController.delete(node);
    }

    protected GraphModel getRootModel(IdentifiableElement modelElement){
        if(modelElement instanceof GraphModel){
            return (GraphModel) modelElement;
        }
        if(modelElement instanceof ModelElement){
            if((((ModelElement) modelElement).getcontainer())!=null){
                return getRootModel((((ModelElement) modelElement).getcontainer()));
            }
        }
        return null;
    }

    protected void createEdge(String type,Edge edge, Node source, Node target,List<BendingPoint> positions){

        GraphModel graphModel = getRootModel(source);

        info.scce.pyro.core.command.types.CreateEdgeCommand cmd = new CreateEdgeCommand();
        cmd.setDelegateId(edge.getDywaId());
        cmd.setDywaVersion(edge.getDywaVersion());
        cmd.setDywaName(edge.getDywaName());
        cmd.setSourceId(source.getDywaId());
        cmd.setTargetId(target.getDywaId());
        cmd.setPositions(positions.stream().map(info.scce.pyro.core.graphmodel.BendingPoint::fromDywaEntity).collect(Collectors.toList()));
        cmd.setType(type);
        batch.add(cmd);

        edge.setcontainer(graphModel);
        graphModel.getmodelElements_ModelElement().add(edge);
        edge.settargetElement(target);
        if(!edge.getbendingPoints_BendingPoint().equals(positions)){
            edge.setbendingPoints_BendingPoint(positions);
        }
        edge.setsourceElement(source);
        source.getoutgoing_Edge().add(edge);
        target.getincoming_Edge().add(edge);
    }

    protected void reconnectEdge(String type,Edge edge, Node source, Node target){

        info.scce.pyro.core.command.types.ReconnectEdgeCommand cmd = new ReconnectEdgeCommand();
        cmd.setDelegateId(edge.getDywaId());
        cmd.setDywaVersion(edge.getDywaVersion());
        cmd.setDywaName(edge.getDywaName());
        cmd.setOldSourceId(edge.getsourceElement().getDywaId());
        cmd.setSourceId(source.getDywaId());
        cmd.setOldTargetId(edge.gettargetElement().getDywaId());
        cmd.setTargetId(target.getDywaId());
        cmd.setType(type);
        batch.add(cmd);

        edge.getsourceElement().getoutgoing_Edge().remove(edge);
        source.getoutgoing_Edge().add(edge);
        edge.setsourceElement(source);

        edge.gettargetElement().getincoming_Edge().remove(edge);
        target.getincoming_Edge().add(edge);
        edge.settargetElement(target);
    }

    protected void updateBendingPoints(String type,Edge edge, List<info.scce.pyro.core.graphmodel.BendingPoint> points){

        info.scce.pyro.core.command.types.UpdateBendPointCommand cmd = new UpdateBendPointCommand();
        cmd.setDelegateId(edge.getDywaId());
        cmd.setDywaVersion(edge.getDywaVersion());
        cmd.setDywaName(edge.getDywaName());
        cmd.setOldPositions(edge.getbendingPoints_BendingPoint().stream().map(info.scce.pyro.core.graphmodel.BendingPoint::fromDywaEntity).collect(Collectors.toList()));
        cmd.setPositions(points);
        cmd.setType(type);
        batch.add(cmd);


        List<BendingPoint> cpPoints = new LinkedList<>(edge.getbendingPoints_BendingPoint());
        edge.getbendingPoints_BendingPoint().clear();
        cpPoints.forEach(b->controllerBundle.bendingPointController.delete(b));
        points.forEach(b->{
            BendingPoint bp = controllerBundle.bendingPointController.create("BendingPoint");
            bp.setx(b.getx());
            bp.sety(b.gety());
            edge.getbendingPoints_BendingPoint().add(bp);
        });
    }

    protected void removeEdge(String type,Edge edge){

        info.scce.pyro.core.command.types.RemoveEdgeCommand cmd = new RemoveEdgeCommand();
        cmd.setDelegateId(edge.getDywaId());
        cmd.setDywaVersion(edge.getDywaVersion());
        cmd.setDywaName(edge.getDywaName());
        cmd.setSourceId(edge.getsourceElement().getDywaId());
        cmd.setTargetId(edge.gettargetElement().getDywaId());
        cmd.setPositions(edge.getbendingPoints_BendingPoint().stream().map(info.scce.pyro.core.graphmodel.BendingPoint::fromDywaEntity).collect(Collectors.toList()));
        cmd.setType(type);
        batch.add(cmd);

        edge.getcontainer().getmodelElements_ModelElement().remove(edge);
        edge.setcontainer(null);
        //List<BendingPoint> points = new LinkedList<>(edge.getbendingPoints_BendingPoint());
        //edge.getbendingPoints_BendingPoint().clear();
        //points.forEach((b)->controllerBundle.bendingPointController.delete(b));
        edge.getsourceElement().getoutgoing_Edge().remove(edge);
        edge.setsourceElement(null);
        edge.gettargetElement().getincoming_Edge().remove(edge);
        edge.settargetElement(null);
        //controllerBundle.edgeController.delete(edge);
    }
    
    protected void updateProperties(String type, info.scce.pyro.core.graphmodel.IdentifiableElement element){
        info.scce.pyro.core.command.types.UpdateCommand cmd = new UpdateCommand();
        cmd.setDelegateId(element.getDywaId());
        cmd.setDywaVersion(element.getDywaVersion());
        cmd.setDywaName(element.getDywaName());
        cmd.setType(type);
        cmd.setElement(element);
        batch.add(cmd);
    }

    public BatchExecution getBatch(){
        return batch;
    }
}
