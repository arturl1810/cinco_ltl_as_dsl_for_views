package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import java.util.HashMap;
import java.util.Map;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.MouseEvent;
import org.eclipse.draw2d.MouseMotionListener;
import org.eclipse.draw2d.geometry.Point;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.gef.LayerConstants;
import org.eclipse.gef.Tool;
import org.eclipse.gef.editparts.ScalableFreeformRootEditPart;
import org.eclipse.gef.tools.AbstractConnectionCreationTool;
import org.eclipse.gef.tools.CreationTool;
import org.eclipse.graphiti.internal.contextbuttons.IContextButtonPadDeclaration;
import org.eclipse.graphiti.internal.contextbuttons.SpecialContextButtonPadDeclaration;
import org.eclipse.graphiti.internal.contextbuttons.StandardContextButtonPadDeclaration;
import org.eclipse.graphiti.internal.features.context.impl.base.PictogramElementContext;
import org.eclipse.graphiti.internal.pref.GFPreferences;
import org.eclipse.graphiti.internal.services.GraphitiInternal;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.tb.IContextButtonPadData;
import org.eclipse.graphiti.tb.IToolBehaviorProvider;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.IResourceRegistry;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButtonManagerForPad;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButtonPad;
import org.eclipse.graphiti.ui.internal.parts.IPictogramElementEditPart;
import org.eclipse.swt.SWT;

@SuppressWarnings("restriction")
public class CincoContextButtonManagerForPad extends ContextButtonManagerForPad {

	private IFigure activeFigure;
	private ContextButtonPad activeContextButtonPad;
	private boolean contextButtonShowing;
	private IResourceRegistry resourceRegistry;
	private Map<IFigure, EditPart> figure2EditPart = new HashMap<IFigure, EditPart>();
	
	private MouseMotionListener mouseMotionListener = new MouseMotionListener.Stub() {
		@Override
		public void mouseEntered(MouseEvent me) {
			reactOnMouse(me);
		}

		@Override
		public void mouseMoved(MouseEvent me) {
			reactOnMouse(me);
		}

		private void reactOnMouse(MouseEvent me) {
			//System.out.println("["+getClass().getSimpleName()+"] reactOnMouse");
			DiagramBehavior diagramBehavior = getDiagramBehavior();
			//System.out.println("["+getClass().getSimpleName()+"]  > diagramBehavior: " + diagramBehavior);

			if (diagramBehavior.isDirectEditingActive()) {
				return;
			}
			Tool activeTool = diagramBehavior.getEditDomain().getActiveTool();
			//System.out.println("["+getClass().getSimpleName()+"]  > activeTool: " + activeTool);
			if (activeTool instanceof CreationTool || activeTool instanceof AbstractConnectionCreationTool) {
				return;
			}

			if ((me.getState() & SWT.MOD1) != 0) {
				// If CTRL is pressed while buttons are shown hide them
				hideContextButtonsInstantly();
				return;
			}

			//System.out.println("["+getClass().getSimpleName()+"]  > contextButtonShowing: " + contextButtonShowing);
			if (!contextButtonShowing) {
				return;
			}

			Object source = me.getSource();
			showContextButtonsInstantly((IFigure) source, me.getLocation());
		}
	};
	
	public CincoContextButtonManagerForPad(DiagramBehavior diagramBehavior, IResourceRegistry resourceRegistry) {
		super(diagramBehavior, resourceRegistry);
		//System.out.println("["+getClass().getSimpleName()+"] constructor");
		this.resourceRegistry = resourceRegistry;
		contextButtonShowing = true;
	}
	
	public void register(GraphicalEditPart graphicalEditPart) {
		//System.out.println("["+getClass().getSimpleName()+"] register: " + graphicalEditPart);
		figure2EditPart.put(graphicalEditPart.getFigure(), graphicalEditPart);
		graphicalEditPart.getFigure().addMouseMotionListener(mouseMotionListener);
	}
	
	public void deRegister(GraphicalEditPart graphicalEditPart) {
		if (graphicalEditPart.getFigure().equals(activeFigure)) {
			hideContextButtonsInstantly();
		}
		figure2EditPart.remove(graphicalEditPart.getFigure());
		graphicalEditPart.getFigure().removeMouseMotionListener(mouseMotionListener);
	}
	
	private void showContextButtonsInstantly(IFigure figure, Point mouse) {
		//System.out.println("["+getClass().getSimpleName()+"] showContextButtonsInstantly.replace?: " + replaceContextButtonPad(figure, mouse));
		if (!replaceContextButtonPad(figure, mouse))
			return;

		synchronized (this) {
			hideContextButtonsInstantly();

			// determine zoom level
			ScalableFreeformRootEditPart rootEditPart = (ScalableFreeformRootEditPart) getDiagramBehavior()
					.getDiagramContainer().getGraphicalViewer().getRootEditPart();
			double zoom = rootEditPart.getZoomManager().getZoom();
			if (zoom < MINIMUM_ZOOM_LEVEL) {
				return;
			}

			// determine pictogram element
			IPictogramElementEditPart editPart = (IPictogramElementEditPart) figure2EditPart.get(figure);
			PictogramElement pe = editPart.getPictogramElement();
			if (pe instanceof Diagram) {
				// No context buttons of diagram itself, should also exit here
				// to avoid showing scrollbars when displaying tooltips on root
				// decorators (see Bugzilla 392309)
				return;
			}
			if (!GraphitiInternal.getEmfService().isObjectAlive(pe)) {
				return;
			}
			PictogramElementContext context = new PictogramElementContext(pe);

			// retrieve context button pad data
			IToolBehaviorProvider toolBehaviorProvider = getDiagramBehavior().getDiagramTypeProvider()
					.getCurrentToolBehaviorProvider();
			IContextButtonPadData contextButtonPadData = toolBehaviorProvider.getContextButtonPad(context);
			if (contextButtonPadData == null) {
				return; // no context buttons to show
			}
			if (contextButtonPadData.getDomainSpecificContextButtons().size() == 0
					&& contextButtonPadData.getGenericContextButtons().size() == 0
					&& contextButtonPadData.getCollapseContextButton() == null) {
				return; // no context buttons to show
			}

			if (!contextButtonPadData.getPadLocation().contains(mouse.x, mouse.y)) {
				return; // mouse outside area of context button pad
			}

			// determine context button pad declaration
			int declarationType = GFPreferences.getInstance().getContextButtonPadDeclaration();
			IContextButtonPadDeclaration declaration;
			if (declarationType == 1) {
				declaration = new SpecialContextButtonPadDeclaration(contextButtonPadData);
			} else {
				declaration = new StandardContextButtonPadDeclaration(contextButtonPadData);
			}

			// create context button pad and add to handle layer
			EditPart activeEditPart = figure2EditPart.get(figure);
			CincoContextButtonPad contextButtonPad = new CincoContextButtonPad(this, declaration, zoom, getDiagramBehavior(),
					activeEditPart, resourceRegistry);
			activeFigure = figure;
			activeContextButtonPad = contextButtonPad;

			IFigure feedbackLayer = rootEditPart.getLayer(LayerConstants.HANDLE_LAYER);
			feedbackLayer.add(contextButtonPad);
		}
	}
	
	private boolean replaceContextButtonPad(IFigure figure, Point mouseLocation) {
		// requires new context buttons, if there is no active figure
		if (activeFigure == null) {
			return true;
		}

		// requires no changed context buttons, if the given figure equals
		// the active figure
		if (figure.equals(activeFigure))
			return false;

		// requires changed context buttons, if the given figure is a child of
		// the active figure (otherwise children would not have context buttons
		// when the mouse moves from parent to child -- see next check)
		IFigure parent = figure.getParent();
		while (parent != null) {
			if (parent.equals(activeFigure))
				return true;
			parent = parent.getParent();
		}

		// requires changed context buttons, if the mouse location is inside the
		// active figure (that means the
		// figure overlaps the active figure)
		if (activeFigure.containsPoint(mouseLocation)) {
			return true;
		}

		// requires no (new) context buttons, if the the mouse is still in the
		// sensitive area of the active context button pad
		if (activeContextButtonPad != null) {
			if (activeContextButtonPad.isMouseInOverlappingArea()) {
				return false;
			}
		}

		return true;
	}
	
	public void hideContextButtonsInstantly() {
		//System.out.println("["+getClass().getSimpleName()+"] hideContextButtonsInstantly: " + activeContextButtonPad);
		if (activeContextButtonPad != null) {
			synchronized (this) {
				ScalableFreeformRootEditPart rootEditPart = (ScalableFreeformRootEditPart) getDiagramBehavior()
						.getDiagramContainer().getGraphicalViewer().getRootEditPart();
				IFigure feedbackLayer = rootEditPart.getLayer(LayerConstants.HANDLE_LAYER);
				feedbackLayer.remove(activeContextButtonPad);
				activeFigure = null;
				activeContextButtonPad = null;
			}
		}
	}
	
	public void setContextButtonShowing(boolean enable) {
		super.setContextButtonShowing(enable);
		contextButtonShowing = enable;
	}
}
