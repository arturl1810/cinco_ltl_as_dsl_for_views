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
import org.eclipse.ui.IEditorInput
import org.eclipse.emf.ecore.EObject
import de.jabc.cinco.meta.core.ge.style.generator.runtime.editor.PageAwareDiagramEditorInput
import mgl.UserDefinedType
import org.eclipse.emf.common.util.TreeIterator

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
	
		«EObject.name» bo = getDiagramTypeProvider().getDiagram().getLink().getBusinessObjects().get(0);
		«TreeIterator.name»<«EObject.name»> eContents = bo.eAllContents();
		eContents.forEachRemaining(it ->
		{
			«FOR type : gm.types.filter(UserDefinedType)»
			if (it instanceof «type.fqInternalBeanName») {
				if (it.eAdapters().stream().filter(a -> a instanceof «type.packageNameEContentAdapter».«type.fuName»EContentAdapter).count() == 0) {
					it.eAdapters().add(new «type.packageNameEContentAdapter».«type.fuName»EContentAdapter());
				}
			}
			«ENDFOR»
		});
	
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
		«IF gm.annotations.exists[name == "postSave"]»
			«EObject.name» obj = getDiagramTypeProvider().getDiagram().eResource().getContents().get(1);
			if (obj instanceof «gm.fqInternalBeanName») {
				«gm.fqBeanName» graph = («gm.fqBeanName») ((«gm.fqInternalBeanName») obj).getElement();
				new «gm.annotations.filter[name == "postSave"]?.head?.value?.head»().postSave(graph);
			}
		«ENDIF»
	}

	@Override
	public void handleSaved() {
		super.handleSaved();
		«IF gm.annotations.exists[name == "postSave"]»
			«IEditorInput.name» input = getEditorInput();
			«EObject.name» obj = null;
			if (input instanceof «PageAwareDiagramEditorInput.name»)
				obj = ((«PageAwareDiagramEditorInput.name») input).getInnerStateSupplier().get().getContents().get(1);
			if (obj instanceof «gm.fqInternalBeanName») {
				«gm.fqBeanName» graph = («gm.fqBeanName») ((«gm.fqInternalBeanName») obj).getElement();
				new «gm.annotations.filter[name == "postSave"]?.head?.value?.head»().postSave(graph);
			}
		«ENDIF»
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