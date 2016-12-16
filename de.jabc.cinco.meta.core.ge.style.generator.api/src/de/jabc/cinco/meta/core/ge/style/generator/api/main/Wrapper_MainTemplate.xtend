package de.jabc.cinco.meta.core.ge.style.generator.api.main

import mgl.ContainingElement
import mgl.GraphModel
import mgl.NodeContainer

class Wrapper_MainTemplate extends GraphModel_MainTemplate {
	
	var GraphModel gm
	
	new(GraphModel me) {
		super(me)
		gm = me
	}
	
	override doGenerate() 
	'''package «gm.package».newcapi;

import java.util.HashMap;
import java.util.List;

import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.mm.pictograms.Connection;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.services.GraphitiUi;

import org.eclipse.xtext.util.StringInputStream;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.resources.IFile;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.emf.common.util.URI;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import java.io.IOException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.core.runtime.NullProgressMonitor;
import java.lang.Exception;

import graphicalgraphmodel.*;
import graphmodel.*;

import «gm.package».graphiti.*;

public class FlowGraphWrapper {
	
	private static HashMap<ModelElement, CModelElement> map;
	private static IDiagramTypeProvider dtp;
	
	public static final String DTP_ID = "info.scce.cinco.product.flowgraph.FlowGraphDiagramTypeProvider";
	
	
	public static «gm.fqn»View newFlowGraph(IPath path, String fileName) throws IOException, CoreException, Exception {
		IPath filePath = path.append(fileName).addFileExtension("flowgraph");
		URI uri = URI.createPlatformResourceURI(filePath.toOSString(), true);
		IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(filePath);
		Resource res = new ResourceSetImpl().createResource(uri);
		Diagram diagram = Graphiti.getPeCreateService().createDiagram("FlowGraph", fileName, true);
		info.scce.cinco.product.flowgraph.flowgraph.FlowGraph graph = info.scce.cinco.product.flowgraph.flowgraph.FlowgraphFactory.eINSTANCE.createFlowGraph();
		
		org.eclipse.emf.ecore.util.EcoreUtil.setID(graph, org.eclipse.emf.ecore.util.EcoreUtil.generateUUID());

		res.getContents().add(diagram);
		res.getContents().add(graph);
		
		IDiagramTypeProvider dtp = GraphitiUi.getExtensionManager().createDiagramTypeProvider(diagram, DTP_ID);
		FlowGraphGraphitiUtils.addToResource(diagram, dtp.getFeatureProvider());
		dtp.getFeatureProvider().link(diagram, graph);
		res.save(null);

		«gm.fqn»View retval = wrapGraphModel(graph, diagram);

		return retval;
	}

	public static «gm.fqn»View wrapGraphModel(GraphModel sg, Diagram d) {
		«gm.fqn» gsg = new «gm.fqn»();
		dtp = org.eclipse.graphiti.ui.services.GraphitiUi.getExtensionManager().createDiagramTypeProvider(d, DTP_ID);
		map = new HashMap<>();
		for (Node n : sg.getAllNodes()) {
			CNode gNode = wrap(n);
			gsg.getMap().put(n, gNode);
			gsg.getModelElements().add(gNode);
		}
		
		for (Edge e : sg.getAllEdges()) {
			CEdge gEdge = wrap(e);
			gsg.getMap().put(e, gEdge);
			gsg.getModelElements().add(gEdge);
		}
		
		gsg.getMap().putAll(map);
		gsg.setModelElement(sg);
		gsg.setShape(dtp.getDiagram());
		gsg.setDiagram(d);
		
		return gsg.get«gm.name»View();
	}
	
	private static CNode getNode(Node n) {
		«FOR n : gm.nodes.filter[n | !(n instanceof NodeContainer)]»
		if (n instanceof «n.fqn»)
			return new «n.fqn»();
		«ENDFOR»
		return null;
	}

	private static CNode wrap(Node n){
		CNode gNode = null;
		
		if (map.get(n) != null)
			return (CNode) map.get(n);
		
		if (n instanceof Container) {
			gNode = wrap((Container) n);
		} else {

			gNode = getNode(n);
				
			gNode.setModelElement(n);
			gNode.setPictogramElement((ContainerShape) getPictogramElement(n));

			map.put(n, gNode);
			
			for (Edge e : n.getIncoming()) {
				gNode.getIncoming().add(wrap(e));
			}
			
			for (Edge e : n.getOutgoing()) {
				gNode.getOutgoing().add(wrap(e));
			}
		}
		
		return gNode;
	}
	
	private static CContainer getContainer(Node c) {
		«FOR n : gm.nodes.filter[n | (n instanceof NodeContainer)]»
		if (c instanceof «n.fqn»)
			return new «n.fqn»();
		«ENDFOR»
		return null;
	}

	private static CNode wrap(Container c) {
		CContainer gCont = null;
		
		if (map.get(c) != null)
			return (CNode) map.get(c);
		
		gCont = getContainer(c);

		gCont.setModelElement(c);
		gCont.setPictogramElement((ContainerShape) getPictogramElement(c));

		map.put(c, gCont);
		
		for (ModelElement me : c.getModelElements()) {
			CModelElement gme = null;
			if (me instanceof Node)
				gme = wrap((Node) me);
			if (me instanceof Edge)
				gme = wrap((Edge) me);
			
			gCont.getModelElements().add(gme);
			gCont.getMap().put(me, gme);
		}
		
		return gCont;
	}
	
	private static CEdge getEdge(Edge e) {
		«FOR e : gm.edges»
		if (e instanceof «e.fqn»)
			return new «e.fqn»();
		«ENDFOR»
		return null;
	}

	private static CEdge wrap(Edge e) {
		CEdge gEdge = null;
		if (map.get(e) != null)
			return (CEdge) map.get(e);
		
		gEdge = getEdge(e);

		gEdge.setModelElement(e);
		gEdge.setPictogramElement((Connection) getPictogramElement(e));

		map.put(e, gEdge);
		
		gEdge.setSourceElement(wrap(e.getSourceElement()));
		gEdge.setTargetElement(wrap(e.getTargetElement()));

		return gEdge;
	}
	
	private static PictogramElement getPictogramElement(ModelElement me) {
		List<PictogramElement> pes = 
				GraphitiUi.getLinkService().getPictogramElements(dtp.getDiagram(), me);
		if (pes == null || pes.isEmpty()) {
			throw new RuntimeException("No pictogram element for: " + me);
		}
		else return pes.get(0);
	}
	
}
	
	'''
	
}
