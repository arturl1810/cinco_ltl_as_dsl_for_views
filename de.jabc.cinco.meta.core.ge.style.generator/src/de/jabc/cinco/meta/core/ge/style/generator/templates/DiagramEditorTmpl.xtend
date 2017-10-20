package de.jabc.cinco.meta.core.ge.style.generator.templates

import de.jabc.cinco.meta.core.ge.style.generator.runtime.editor.CincoDiagramEditor
import de.jabc.cinco.meta.core.referenceregistry.ReferenceRegistry
import de.jabc.cinco.meta.core.utils.generator.GeneratorUtils
import mgl.GraphModel
import org.eclipse.core.runtime.IProgressMonitor
import org.eclipse.graphiti.features.context.impl.ResizeShapeContext
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm
import org.eclipse.graphiti.mm.pictograms.Shape
import org.eclipse.graphiti.ui.editor.DiagramEditor
import de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight.Highlighter
import de.jabc.cinco.meta.core.utils.CincoUtil

class DiagramEditorTmpl extends GeneratorUtils{

/**
 * Generates the {@link DiagramEditor} for the {@link GraphModel}
 * 
 * @param gm The processed {@link GraphModel}
 */
def generateDiagramEditor(GraphModel gm) '''
package «gm.packageName»;

public class «gm.fuName»DiagramEditor extends «CincoDiagramEditor.name» {
	
	@Override
	public «gm.fuName»Diagram createDiagram() {
		return new «gm.fuName»Diagram();
	}
		
	@Override
	public void initializeGraphicalViewer() {
		super.initializeGraphicalViewer();
		
		«ReferenceRegistry.name».getInstance().registerListener();
	
«««		for («PictogramLink.name» pl : «gm.fuName»GraphitiUtils.getInstance().getDTP().getDiagram().getPictogramLinks())
«««			for («EObject.name» bo : pl.getBusinessObjects())
«««				«gm.packageNameEContentAdapter».«gm.fuName»EContentAdapter.getInstance().addAdapter(bo);
		
		«IF ! CincoUtil.isHighlightContainmentDisabled(gm)»
			«Highlighter.name».INSTANCE.get().listenToDiagramDrag(this, getGraphicalControl());
		«ENDIF»
	}
	
	«IF ! CincoUtil.isHighlightContainmentDisabled(gm)»
		@Override
		public void onPaletteViewerCreated(org.eclipse.gef.ui.palette.PaletteViewer pViewer) {
			«Highlighter.name».INSTANCE.get().listenToPaletteDrag(pViewer);
		}
	«ENDIF»
	
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