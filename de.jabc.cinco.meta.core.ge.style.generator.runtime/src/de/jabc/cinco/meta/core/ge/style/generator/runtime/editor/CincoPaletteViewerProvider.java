package de.jabc.cinco.meta.core.ge.style.generator.runtime.editor;

import org.eclipse.gef.KeyHandler;
import org.eclipse.gef.Tool;
import org.eclipse.gef.tools.ConnectionCreationTool;
import org.eclipse.gef.tools.CreationTool;
import org.eclipse.gef.ui.palette.PaletteViewer;
import org.eclipse.gef.ui.palette.PaletteViewerProvider;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;

public class CincoPaletteViewerProvider extends PaletteViewerProvider {
	
	private KeyHandler paletteKeyHandler = null;
	private PaletteViewer paletteViewer;
	private CincoDiagramEditor diagramEditor;
	
	public CincoPaletteViewerProvider(CincoDiagramEditor diagramEditor) {
		super(diagramEditor.getEditDomain());
		this.diagramEditor = diagramEditor;
	}

	protected void configurePaletteViewer(PaletteViewer viewer) {
		super.configurePaletteViewer(viewer);
		viewer.getKeyHandler().setParent(getPaletteKeyHandler());
		paletteViewer = viewer;
		diagramEditor.onPaletteViewerCreated(viewer);
	}
	
	public PaletteViewer getPaletteViewer() {
		return paletteViewer;
	}

	/**
	 * @return Palette Key Handler for the palette
	 */
	private KeyHandler getPaletteKeyHandler() {
		if (paletteKeyHandler == null) {
			paletteKeyHandler = new KeyHandler() {
				
				@Override
				public boolean keyReleased(KeyEvent event) {
					if (event.keyCode == SWT.Selection) {
						Tool tool = getEditDomain().getPaletteViewer().getActiveTool().createTool();
						if (tool instanceof CreationTool || tool instanceof ConnectionCreationTool) {
							tool.keyUp(event, diagramEditor.getDiagramBehavior().getDiagramContainer().getGraphicalViewer());
							// Deactivate current selection
							getEditDomain().getPaletteViewer().setActiveTool(null);
							return true;
						}
					}
					return super.keyReleased(event);
				}
			};
		}
		return paletteKeyHandler;
	}
}