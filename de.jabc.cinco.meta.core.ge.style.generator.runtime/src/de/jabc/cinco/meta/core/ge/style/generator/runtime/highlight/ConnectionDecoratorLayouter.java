package de.jabc.cinco.meta.core.ge.style.generator.runtime.highlight;

import org.eclipse.draw2d.IFigure;
import org.eclipse.draw2d.LayoutListener;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.internal.figures.GFPolylineConnection;

import de.jabc.cinco.meta.runtime.xapi.WorkbenchExtension;

@SuppressWarnings("restriction")
public class ConnectionDecoratorLayouter extends LayoutListener.Stub {

	public static ConnectionDecoratorLayouter applyTo(PictogramElement pe) {
		DiagramBehavior db = new WorkbenchExtension().getDiagramBehavior(pe);
		GraphicalEditPart ep = db.getEditPartForPictogramElement(pe);
		figure = ep.getFigure();
		ConnectionDecoratorLayouter layouter = new ConnectionDecoratorLayouter(figure);
		figure.addLayoutListener(layouter);
		return layouter;
	}
	
	
	private static IFigure figure;
	private boolean unregisterAfterNextLayout = false;
	
	public ConnectionDecoratorLayouter(IFigure figure) {
		ConnectionDecoratorLayouter.figure = figure;
	}
	
	
	@Override
	public boolean layout(IFigure fig) {
		if (fig instanceof GFPolylineConnection) {
			GFPolylineConnection con = (GFPolylineConnection) fig;
			con.getAllDecorations().forEach(dec -> {
				dec.setForegroundColor(fig.getForegroundColor());
				dec.setBackgroundColor(fig.getBackgroundColor());
			});
			if (unregisterAfterNextLayout) {
				figure.removeLayoutListener(this);
			}
		}
		return false;
	}

	public void setUnregisterAfterNextLayout(boolean flag) {
		this.unregisterAfterNextLayout = flag;
	}
}
