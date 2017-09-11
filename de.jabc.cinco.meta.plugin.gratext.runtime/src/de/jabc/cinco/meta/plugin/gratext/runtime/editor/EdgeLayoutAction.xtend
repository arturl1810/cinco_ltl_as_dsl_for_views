package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.Edge
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
	Iterable<Edge> selectedEdges
	
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
		val bos = selection.map[model]
			.filter(PictogramElement)
			.map[businessObject]
			.filterNull
		
		val onlyEdges = !bos.exists[!(it instanceof Edge)]
		val enabled = onlyEdges && !selection.isEmpty
		selectedEdges = if (enabled) bos.filter(Edge) else #[]
		enabled
	}
	
	override run() {
		selectedEdges.forEach[ layout.apply(it) ]
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