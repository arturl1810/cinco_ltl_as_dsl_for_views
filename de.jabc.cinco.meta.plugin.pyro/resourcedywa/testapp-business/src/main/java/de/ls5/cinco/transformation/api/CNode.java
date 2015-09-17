package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.*;

import java.util.ArrayList;
import java.util.List;

public interface CNode extends CModelElement {

    public List<CEdge> getIncoming();

    public List<CEdge> getOutgoing();

    public List<CNode> getSuccessors();

    public <T extends CNode> List<T> getSuccessors(Class<T> clazz);

    public List<CNode> getPredecessors();

    public <T extends CNode> List<T> getPredecessors(Class<T> clazz);

    public <T extends CEdge> List<T> getIncoming(Class<T> clazz);

    public <T extends CEdge> List<T> getOutgoing(Class<T> clazz);

    public long getX();

    public long getY();

    public long getWidth();

    public long getHeight();

    public void setX(long x);

    public void setY(long y);

    public void setWidth(long width);

    public void setHeight(long height);

    public void moveTo(long x,long y);

    public void resize(long width,long height);

    public void setAngle(double angle);

    public double getAngle();

    public void rotate(double degrees);

    public void setNode(Node node);

    public Node getNode();

    public void setModelElement(ModelElement modelElement);

    public ModelElement getModelElement();

    public void update();

    public boolean delete();
    
    public <T extends CGraphModel> T getCRootElement();


} // CNode
