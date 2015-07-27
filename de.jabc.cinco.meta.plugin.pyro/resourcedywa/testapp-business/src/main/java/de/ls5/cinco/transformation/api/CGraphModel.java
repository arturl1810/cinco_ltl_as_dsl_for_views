package de.ls5.cinco.transformation.api;

import de.ls5.dywa.generated.entity.GraphModel;
import de.ls5.dywa.generated.entity.ModelElementContainer;

import java.util.List;

/**
 * Generated by Pyro Meta Plugin
 */
public interface CGraphModel extends CModelElementContainer{

    public List<CModelElement> getModelElements();

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz);

    public void setModelElements(List<CModelElement> cModelElements);

    public void addModelElement(CModelElement cModelElement);

    public List<CNode> getAllCNodes();

    public List<CEdge> getAllCEdges();

    public List<CContainer> getAllCContainers();

    public GraphModel getGraphModel();

    public void setGraphModel(GraphModel graphModel);

    public ModelElementContainer getModelElementContainer();

    public void setModelElementContainer(ModelElementContainer modelElementContainer);
}
