package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.draw2d.MouseEvent;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.gef.DefaultEditDomain;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.GraphicalViewer;
import org.eclipse.graphiti.internal.contextbuttons.PositionedContextButton;
import org.eclipse.graphiti.ui.internal.command.CreateConnectionCommand;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButton;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButtonPad;
import org.eclipse.swt.events.MouseAdapter;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.events.MouseMoveListener;
import org.eclipse.swt.widgets.Control;

@SuppressWarnings("restriction")
public class CincoContextButton extends ContextButton {

	private MouseMoveListener mouseDragMoveListener;
	private MouseListener mouseDragUpListener;
	private CincoDragConnectionTool dragConnectionTool;
	
	public CincoContextButton(String providerId, PositionedContextButton positionedContextButton, ContextButtonPad contextButtonPad) {
		super(providerId, positionedContextButton, contextButtonPad);
	}
	
	public void mouseDragged(MouseEvent me) {
		if (getEntry().getDragAndDropFeatures().size() == 0) {
			return;
		}

		me.consume();

		if (mouseDragMoveListener == null) { // not already in dragging

			GraphicalViewer graphicalViewer = getDiagramBehavior().getDiagramContainer().getGraphicalViewer();
			
			// creates a new drag-connection tool on each mouse move
			mouseDragMoveListener = new MouseMoveListener() {
				public void mouseMove(org.eclipse.swt.events.MouseEvent e) {
					EditPart targetEditPart = graphicalViewer.findObjectAt(new Point(e.x, e.y));
					getDragConnectionTool().continueConnection(getEditPart(), targetEditPart);
				}
			};

			// removes the mouse-drag listeners on mouse up
			mouseDragUpListener = new MouseAdapter() {
				@Override
				public void mouseUp(org.eclipse.swt.events.MouseEvent e) {
					Control control = getDiagramBehavior().getDiagramContainer().getGraphicalViewer().getControl();
					control.removeMouseListener(mouseDragUpListener);
					control.removeMouseMoveListener(mouseDragMoveListener);
					mouseDragUpListener = null;
					mouseDragMoveListener = null;
					dragConnectionTool = null;
				}
			};

			// adds the mouse-drag listeners
			Control control = graphicalViewer.getControl();
			control.addMouseListener(mouseDragUpListener);
			control.addMouseMoveListener(mouseDragMoveListener);
		}
	}

	private CincoDragConnectionTool getDragConnectionTool() {
		if (dragConnectionTool == null) {
			CincoDragConnectionTool dragConnectionTool = new CincoDragConnectionTool(getDiagramBehavior(), getEntry());

			DefaultEditDomain editDomain = getDiagramBehavior().getEditDomain();
			dragConnectionTool.setEditDomain(editDomain);
			editDomain.setActiveTool(dragConnectionTool);

			this.dragConnectionTool = dragConnectionTool;
		}

		return dragConnectionTool;
	}
}
