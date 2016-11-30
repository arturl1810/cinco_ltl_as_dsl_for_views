package de.jabc.cinco.meta.core.ge.style.generator.templates

import mgl.GraphModel
import de.jabc.cinco.meta.core.ge.style.generator.templates.util.GeneratorUtils
import org.eclipse.graphiti.ui.editor.DiagramEditor
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry
import org.eclipse.graphiti.mm.pictograms.PictogramLink
import org.eclipse.emf.ecore.EObject
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.mm.pictograms.Shape

class DiagramEditorTmpl extends GeneratorUtils{
	
def generateDiagramEditor(GraphModel gm) '''
package «gm.packageName»;

public class «gm.fuName»DiagramEditor extends «DiagramEditor.name» {
	
	@Override
	public void initializeGraphicalViewer() {
		super.initializeGraphicalViewer();
		
		«ReferenceRegistry.name».getInstance().registerListener();
	
«««		for («PictogramLink.name» pl : «gm.fuName»GraphitiUtils.getInstance().getDTP().getDiagram().getPictogramLinks())
«««			for («EObject.name» bo : pl.getBusinessObjects())
«««				«gm.fuName»EContentAdapter.getInstance().addAdapter(bo);
		
	}
	
	@Override
	public void doSave(«IProgressMonitor.name» monitor) {
		super.doSave(monitor);
		«ReferenceRegistry.name».getInstance().save();
	}

	protected «ResizeShapeContext.name» createContext(«Shape.name» child) {
		«GraphicsAlgorithm.name» ga = child.getGraphicsAlgorithm();
		«ResizeShapeContext.name» context = new «ResizeShapeContext.name»(child);
		context.setSize(ga.getWidth(), ga.getHeight());
		context.setLocation(ga.getX(), ga.getY());
		return context;
	}
}
'''
	
	
}