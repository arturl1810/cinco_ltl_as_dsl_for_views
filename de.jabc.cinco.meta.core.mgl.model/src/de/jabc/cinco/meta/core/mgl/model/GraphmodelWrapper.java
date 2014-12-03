package de.jabc.cinco.meta.core.mgl.model;

import graphicalgraphmodel.GContainer;
import graphicalgraphmodel.GEdge;
import graphicalgraphmodel.GGraphModel;
import graphicalgraphmodel.GModelElementContainer;
import graphicalgraphmodel.GNode;
import graphicalgraphmodel.GraphicalgraphmodelFactory;
import graphmodel.Container;
import graphmodel.Edge;
import graphmodel.GraphModel;
import graphmodel.ModelElementContainer;
import graphmodel.Node;

import java.util.HashMap;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;

public class GraphmodelWrapper {

	/**
	 *  This map is used to store information about created GraphicalModelElements
	 *  and the mapping from Graphmodel elements to GraphicalGraphModel elements. 
	 *  Thus, it is a map of <Graphmodel, GraphicalGraphmodel>
	 *  
	 *  **/
	private HashMap<EObject, EObject> map;
	
	private Diagram diagram;
	
	public GraphmodelWrapper(Diagram diagram) {
		map = new HashMap<>();
		this.diagram = diagram;
	}
	

	private GModelElementContainer wrap(ModelElementContainer mec) {
		if (mec instanceof GraphModel)
			return wrap((GraphModel) mec);
		if (mec instanceof Container) 
			return wrap((Container) mec);
		return null;
	}
	
	public GGraphModel wrap(GraphModel gm) {
		if ((map.get(gm) instanceof GGraphModel))
			return (GGraphModel) map.get(gm);
		
		GGraphModel ggm = GraphicalgraphmodelFactory.eINSTANCE.createGGraphModel();
		
		ggm.setGraphModel(gm);
		ggm.setContainerShape(diagram);
		
		map.put(gm, ggm);
		
		for (Node n : gm.getAllNodes()) {
			if (n instanceof Container) {
				continue;
			}
			ggm.getModelElements().add(wrap(n));
		}
		
		for (Container c : gm.getAllContainers()) {
			ggm.getModelElements().add(wrap(c));
		}
		
		for (Edge e : gm.getAllEdges()) {
			ggm.getModelElements().add(wrap(e));
		}
		
		return ggm;
	}
	
	
	private GNode wrap(Node n) {
		if ( (map.get(n) instanceof GNode)) 
			return (GNode) map.get(n);
		
		GNode gNode = GraphicalgraphmodelFactory.eINSTANCE.createGNode();
		
		gNode.setNode(n);
		gNode.setShape(getContainerShape(n));
		map.put(n, gNode);
		
		return gNode;
	}

	private GContainer wrap(Container c) {
		if ((map.get(c) instanceof GContainer))
			return (GContainer) map.get(c);
		
		GContainer gContainer = GraphicalgraphmodelFactory.eINSTANCE.createGContainer();
		gContainer.setContainerBO(c);
		gContainer.setShape(getContainerShape(c));
		gContainer.setContainer(wrap(c.getContainer()));
		
		map.put(c, gContainer);
		
		for (Node n : c.getAllNodes()) { 
			if (n instanceof Container)
				continue;
			gContainer.getModelElements().add(wrap(n));
		}
		
		for (Container cont : c.getAllContainers())
			gContainer.getModelElements().add(wrap(cont));

		for (Edge e : c.getAllEdges()) {
			gContainer.getModelElements().add(wrap(e));
		}
		
		return gContainer;
		
	}
	
	private GEdge wrap(Edge e) {
		if ((map.get(e) instanceof Edge))
			return (GEdge) map.get(e);
		
		GEdge gEdge = GraphicalgraphmodelFactory.eINSTANCE.createGEdge();
		gEdge.setEdge(e);
		gEdge.setConnection(getConnection(e));
		
		map.put(e, gEdge);
		
		gEdge.setSourceElement(wrap(e.getSourceElement()));
		gEdge.setTargetElement(wrap(e.getTargetElement()));
		
		return gEdge;
	}

	
	private ContainerShape getContainerShape(Node node) {
		List<PictogramElement> pes = Graphiti.getLinkService().getPictogramElements(diagram, node);
		if (pes == null || pes.isEmpty()) {
			// TODO: Throw exception
		}
		
		PictogramElement pe = pes.get(0);
		if ( !(pe instanceof ContainerShape)) {
			// TODO: Throw exception
		}	
		
		return (ContainerShape) pe;
	}
	
	private ContainerShape getContainerShape(Container container) {
		List<PictogramElement> pes = Graphiti.getLinkService().getPictogramElements(diagram, container);
		if (pes == null || pes.isEmpty()) {
			// TODO: Throw exception
		}
		
		PictogramElement pe = pes.get(0);
		if ( !(pe instanceof ContainerShape)) {
			// TODO: Throw exception
		}	
		
		return (ContainerShape) pe;
	}
	
	private Connection getConnection(Edge edge) {
		List<PictogramElement> pes = Graphiti.getLinkService().getPictogramElements(diagram, edge);
		if (pes == null || pes.isEmpty()) {
			// TODO: Throw exception
		}
		
		PictogramElement pe = pes.get(0);
		if ( !(pe instanceof Connection)) {
			// TODO: Throw exception
		}	
		
		return (Connection) pe;
	}
	
}
