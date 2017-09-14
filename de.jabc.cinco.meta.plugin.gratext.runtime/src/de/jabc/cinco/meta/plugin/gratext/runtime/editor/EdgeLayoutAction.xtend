package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.Edge
import graphmodel.internal.InternalEdge
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.ui.actions.SelectionAction
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import org.eclipse.ui.IWorkbenchPart

import static extension org.eclipse.gef.tools.ToolUtilities.*

class EdgeLayoutAction extends SelectionAction {
	
	extension val WorkbenchExtension = new WorkbenchExtension
	
	final EdgeLayout layout
	Iterable<InternalEdge> selectedEdges
	
	new(IWorkbenchPart part, EdgeLayout layout) {
		super(part)
		this.layout = layout
	}
	
	override getId() {
		layout.id
	}
	
	override getText() {
		layout.text
	}
	
	override getImageDescriptor() {
		layout.imageDescriptor
	}
	
	override getDisabledImageDescriptor() {
		layout.imageDescriptor
	}
	
	override calculateEnabled() {
		val selection = getSelection(null)
			.map[model]
			.filter(PictogramElement)
			.map[businessObject]
		val onlyEdges = !selection.exists[!(it instanceof InternalEdge)]
		val enabled = onlyEdges && !selection.isEmpty
		selectedEdges = if (enabled) selection.filter(InternalEdge) else #[]
		return enabled
	}
	
	override run() {
		selectedEdges.forEach[ layout.apply(it.element as Edge) ]
	}
	
	def Iterable<EditPart> getSelection(Request request) {
		val allSelected = selectedObjects
		if (allSelected.isEmpty || !(allSelected.head instanceof GraphicalEditPart))
			return #[]
//		val primary = allSelected.last
		val selected = allSelected.selectionWithoutDependants
			.filter(EditPart)
//		if (selected.size < 2 || !selected.contains(primary))
//			return #[]
		return selected
	}
	
}