package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import java.util.List;

import org.eclipse.draw2d.XYLayout;
import org.eclipse.draw2d.geometry.Rectangle;
import org.eclipse.gef.EditPart;
import org.eclipse.graphiti.internal.contextbuttons.IContextButtonPadDeclaration;
import org.eclipse.graphiti.internal.contextbuttons.PositionedContextButton;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.IResourceRegistry;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButton;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButtonManagerForPad;
import org.eclipse.graphiti.ui.internal.contextbuttons.ContextButtonPad;

@SuppressWarnings("restriction")
public class CincoContextButtonPad extends ContextButtonPad {

	public CincoContextButtonPad(ContextButtonManagerForPad contextButtonManagerForPad,
			IContextButtonPadDeclaration declaration, double zoomLevel, DiagramBehavior diagramBehavior,
			EditPart editPart, IResourceRegistry resourceRegistry) {
		
		super(contextButtonManagerForPad, declaration, zoomLevel, diagramBehavior, editPart, resourceRegistry);
		replaceContextButtons();
	}

	private void replaceContextButtons() {
		//System.out.println("["+getClass().getSimpleName()+"] replaceContextButtons: " + getChildren().size());
		for (Object child : getChildren()) {
			//System.out.println("["+getClass().getSimpleName()+"]  > " + child);
		}
		removeAll();
		List<PositionedContextButton> positionedButtons = getDeclaration().getPositionedContextButtons();
		String providerId = getDiagramBehavior().getDiagramTypeProvider().getProviderId();
		for (PositionedContextButton positionedButton : positionedButtons) {
			Rectangle position = transformGenericRectangle(positionedButton.getPosition(), 0);
			// translate position relative to bounds (after the bounds are set!)
			position.translate(-getBounds().getTopLeft().x, -getBounds().getTopLeft().y);
			CincoContextButton cb = new CincoContextButton(providerId, positionedButton, this);
			add(cb, position);
		}
	}
		
	private Rectangle transformGenericRectangle(java.awt.Rectangle source, int shrinkLines) {
		if (source == null) {
			return null;
		}

		double zoom = getZoomLevel();
		int lw = shrinkLines * ((int) (getDeclaration().getPadLineWidth() * zoom));

		Rectangle target = new Rectangle(source.x, source.y, source.width, source.height);
		target.scale(zoom);
		// shrink, but take care not to end up with a negative width or height
		int widthShrink = Math.min(target.width / 2, lw);
		int heightShrink = Math.min(target.height / 2, lw);
		target.shrink(widthShrink, heightShrink);
		return target;
	}
}
