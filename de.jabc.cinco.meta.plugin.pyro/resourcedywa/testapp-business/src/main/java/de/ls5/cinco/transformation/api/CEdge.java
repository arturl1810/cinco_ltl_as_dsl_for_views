package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.Edge;
import de.ls5.dywa.generated.entity.ModelElement;

import java.util.List;

public interface CEdge extends CModelElement {

    public CNode getSourceElement();

    public void reconnectSource(CNode cNode);

    public void reconnectTarget(CNode cNode);

    public void setSourceElement(CNode value);

    public CNode getTargetElement();

    public void setTargetElement(CNode value);

    public void addBendingPoint(long x,long y);

    public void addBendingPoint(CBendingpoint bendingpoint);

    public List<CBendingpoint> getBendingpoints();

    public void setBendingPoints(List<CBendingpoint> bendingPoints);
    
    public void setModelElement(ModelElement modelElement);
    
    public ModelElement getModelElement();

    public void setEdge(Edge edge);

    public Edge getEdge();
    
    public void update();
    
    public boolean delete();
    
    public <T extends CGraphModel> T getCRootElement();
} // CEdge
