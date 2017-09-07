package de.jabc.cinco.meta.plugin.gratext.runtime.editor

import org.eclipse.draw2d.geometry.PrecisionRectangle
import org.eclipse.draw2d.geometry.Rectangle
import org.eclipse.gef.EditPart
import org.eclipse.gef.GraphicalEditPart
import org.eclipse.gef.Request
import org.eclipse.gef.ui.actions.SelectionAction
import org.eclipse.ui.IWorkbenchPart

import static extension org.eclipse.gef.tools.ToolUtilities.*
import org.eclipse.core.commands.Command
import org.eclipse.graphiti.mm.pictograms.ContainerShape
import org.eclipse.graphiti.mm.pictograms.PictogramElement
import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension
import graphmodel.Edge
import org.eclipse.graphiti.features.context.impl.AddBendpointContext
import org.eclipse.graphiti.mm.pictograms.FreeFormConnection
import org.eclipse.graphiti.features.context.impl.RemoveBendpointContext

class EdgeLayoutAction extends SelectionAction {
	
	extension val WorkbenchExtension = new WorkbenchExtension
	
	final EdgeLayoutMode mode
	Iterable<EditPart> selection
	
	new(IWorkbenchPart part, EdgeLayoutMode mode) {
		super(part)
		this.mode = mode
	}
	
	override getId() {
		mode.id
	}
	
	override calculateEnabled() {
		System.err.println("[EdgeLayoutAction] calculateEnabled");
		val selection = getSelection(null)
		selection.forEach[
			println("EditPart: " + it)
			if (it.model instanceof PictogramElement) {
				println(" > PE: " + it.model)
				println(" > BO: " + (it.model as PictogramElement).businessObject)
			}
		]
		val bos = selection.map[model]
			.filter(PictogramElement)
			.map[businessObject]
			.filterNull
			
		println("BOs.size: " + bos.size)
		
		val onlyEdges = !bos.exists[!(it instanceof Edge)]
			
		println("OnlyEdges: " + onlyEdges)
		val enabled = onlyEdges && !selection.isEmpty
		println("Enabled: " + enabled)
		enabled
	}
	
//	def Rectangle calculateEditPartRectangle(Request request) {
//		val editparts = getSelection(request)
//		if (editparts.nullOrEmpty)
//			return null;
//		val part = editparts.last as GraphicalEditPart
//		val rect = new PrecisionRectangle(part.figure.bounds)
//		part.figure.translateToAbsolute(rect)
//		return rect
//	}
	
	def Iterable<EditPart> getSelection(Request request) {
		if (this.selection != null)
			return this.selection
		val allSelected = selectedObjects
		if (allSelected.isEmpty || !(allSelected.head instanceof GraphicalEditPart))
			return #[]
//		val primary = allSelected.last
		val selected = allSelected.selectionWithoutDependants
			.filter(EditPart)
//			.filter[understandsRequest(request)]
//			.toList
//		if (selected.size < 2 || !selected.contains(primary))
//			return #[]
//		val parent = selected.head.parent
//		if (selected.exists[it.parent != parent])
//			return #[]
		return selected
	}
	
	def addBendpoint(Edge edge, int x, int y) {
		val diagram = edge.diagram
		val dtp = diagram.diagramTypeProvider
		val fp = dtp.featureProvider
		
		val index = edge.bendpoints.size
		val ctx = new AddBendpointContext(edge.connection, x, y, index)
		
		val ftr = fp.getAddBendpointFeature(ctx)
		val db = dtp.diagramBehavior
		db.executeFeature(ftr, ctx)
	}
	
	def removeBendpoint(Edge edge, int bpIndex) {
		val diagram = edge.diagram
		val dtp = diagram.diagramTypeProvider
		val fp = dtp.featureProvider
		
		val ctx = new RemoveBendpointContext(edge.connection, null) => [
			bendpointIndex = bpIndex
		]
		
		val ftr = fp.getRemoveBendpointFeature(ctx)
		val db = dtp.diagramBehavior
		db.executeFeature(ftr, ctx)
	}
	
	def getBendpoints(Edge edge) {
		val connection = edge.connection
		if (connection != null)
			return connection.getBendpoints();
		return newArrayList
	}
	
	def FreeFormConnection getConnection(Edge edge) {
		val pe = edge.pictogramElement
		if (pe instanceof FreeFormConnection)
			return pe
		return null
	}
}