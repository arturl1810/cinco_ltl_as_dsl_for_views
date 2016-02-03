package de.ls5.cinco.pyro.transformation.api;

import de.ls5.dywa.generated.entity.ModelElementContainer;

import java.util.List;

/**
 * Created by zweihoff on 16.06.15.
 */
public interface CContainer extends CNode, CModelElementContainer {


    public List<CModelElement> getModelElements();


    public void addModelElement(CModelElement cModelElement);

    public <T extends CModelElement> List<T> getCModelElements(Class<T> clazz);

    public void setModelElements(List<CModelElement> cModelElements);

    public List<CNode> getAllCNodes();

    public List<CEdge> getAllCEdges();

    public List<CContainer> getAllCContainers();
    public ModelElementContainer getModelElementContainer();
    
    public void setModelElementContainer(ModelElementContainer modelElementContainer);
}
