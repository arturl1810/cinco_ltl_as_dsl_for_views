package de.jabc.cinco.meta.core.ui.editor;

import org.eclipse.gef.KeyHandler;
import org.eclipse.gef.Tool;
import org.eclipse.gef.dnd.TemplateTransferDragSourceListener;
import org.eclipse.gef.tools.ConnectionCreationTool;
import org.eclipse.gef.tools.CreationTool;
import org.eclipse.gef.ui.palette.PaletteViewer;
import org.eclipse.gef.ui.palette.PaletteViewerProvider;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.ui.editor.DefaultPaletteBehavior;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.editor.IDiagramEditorInput;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;

import de.jabc.cinco.meta.plugin.gratext.runtime.editor.PageAwareDiagramBehavior;

public class CincoDiagramEditor extends DiagramEditor {
	
	@Override
	protected DiagramBehavior createDiagramBehavior() {
		return new PageAwareDiagramBehavior(this) {
			
			@Override
			protected DefaultPaletteBehavior createPaletteBehaviour() {
				return new DefaultPaletteBehavior(this) {
					
					@Override
					protected PaletteViewerProvider createPaletteViewerProvider() {
						return new CustomPaletteViewerProvider();
					}
				};
			}
			
			@Override
			protected void setInput(IDiagramEditorInput input) {
				initRequiredPackages();
				super.setInput(input);
			}
			
//			@Override
//			public void refreshContent() {
//				Diagram diagram = getDiagramTypeProvider().getDiagram();
//				if (diagram != null) {
//					super.refreshContent();
//				}
//			}
		};
	}
	
	
	public void onPaletteViewerCreated(PaletteViewer pViewer) {
		pViewer.addDragSourceListener(new TemplateTransferDragSourceListener(pViewer));
	}
	
	public void initRequiredPackages() {
		// default: do nothing
	}
	
	
	public PaletteViewer getPaletteViewer() {
		return ((CustomPaletteViewerProvider)getPaletteViewerProvider()).getPaletteViewer();
	}
	
	
	private class CustomPaletteViewerProvider extends PaletteViewerProvider {
		
		private KeyHandler paletteKeyHandler = null;
		private PaletteViewer paletteViewer;
		
		public CustomPaletteViewerProvider() {
			super(getDiagramBehavior().getEditDomain());
		}

		protected void configurePaletteViewer(PaletteViewer viewer) {
			super.configurePaletteViewer(viewer);
			viewer.getKeyHandler().setParent(getPaletteKeyHandler());
			paletteViewer = viewer;
			onPaletteViewerCreated(viewer);
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
								tool.keyUp(event, getDiagramBehavior().getDiagramContainer().getGraphicalViewer());
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
	};
}
