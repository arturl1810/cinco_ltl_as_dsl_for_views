package de.jabc.cinco.meta.core.ui.highlight;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.eclipse.draw2d.geometry.Point;
import org.eclipse.gef.EditPart;
import org.eclipse.gef.EditPartViewer;
import org.eclipse.gef.Request;
import org.eclipse.gef.commands.Command;
import org.eclipse.gef.dnd.AbstractTransferDropTargetListener;
import org.eclipse.gef.dnd.TemplateTransferDragSourceListener;
import org.eclipse.gef.palette.CombinedTemplateCreationEntry;
import org.eclipse.gef.palette.PaletteTemplateEntry;
import org.eclipse.gef.requests.CreateRequest;
import org.eclipse.gef.requests.CreationFactory;
import org.eclipse.gef.ui.palette.PaletteViewer;
import org.eclipse.graphiti.features.ICreateConnectionFeature;
import org.eclipse.graphiti.features.ICreateFeature;
import org.eclipse.graphiti.features.IReconnectionFeature;
import org.eclipse.graphiti.features.context.ICreateConnectionContext;
import org.eclipse.graphiti.features.context.IReconnectionContext;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.graphiti.ui.internal.parts.ContainerShapeEditPart;
import org.eclipse.jface.util.LocalSelectionTransfer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.dnd.DND;
import org.eclipse.swt.dnd.DragSourceEvent;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.swt.dnd.TransferData;
import org.eclipse.swt.events.MouseEvent;
import org.eclipse.swt.events.MouseListener;
import org.eclipse.swt.widgets.Control;

import de.jabc.cinco.meta.core.utils.WorkbenchUtil;
import de.jabc.cinco.meta.core.utils.registry.InstanceRegistry;

public abstract class Highlighter {
	
	public static InstanceRegistry<Highlighter> INSTANCE = new InstanceRegistry<>(() -> new DefaultHighlighter());
	
	private Map<String,Collection<Highlight>> highlightContexts = new HashMap<>();
	
	/**
	 * Retrieves the shapes that should be highlighted if the
	 * specified PictogramElement is dragged from the diagram.
	 * 
	 * @param dragged The dragged PictogramElement.
	 * @return The PictogramElements to be highlighted.
	 */
	protected abstract Set<PictogramElement> getHighlightablesOnDrag(PictogramElement dragged);
	
	/**
	 * Retrieves the shapes that should be highlighted if a
	 * component is dragged from the editor's palette.
	 * 
	 * @param createFeature The respective create feature.
	 * @return The PictogramElements to be highlighted.
	 */
	protected abstract Set<PictogramElement> getHighlightablesOnCreate(ICreateFeature feature);
	
	/**
	 * Retrieves the shapes that should be highlighted if connection
	 * has been started.
	 * 
	 * @param feature The respective create feature.
	 * @param context The respective create context.
	 * @return The PictogramElements to be highlighted.
	 */
	protected abstract Set<PictogramElement> getHighlightablesOnConnect(ICreateConnectionFeature feature, ICreateConnectionContext context);
	
	/**
	 * Retrieves the shapes that should be highlighted if reconnection
	 * has been started.
	 * 
	 * @param feature The respective create feature.
	 * @param context The respective create context.
	 * @return The PictogramElements to be highlighted.
	 */
	protected abstract Collection<PictogramElement> getHighlightablesOnReconnect(IReconnectionFeature feature, IReconnectionContext context);
	
	/**
	 * Retrieves the Highlight for the specified PictogramElement.
	 * 
	 * @param pe The PictogramElement to be highlighted.
	 * @return The Highlight to be applied.
	 */
	protected abstract Highlight getHighlight(PictogramElement pe);
	
	/**
	 * Registers this object for the specified viewer to activate highlighting
	 * when a new component is going to be created by dragging from the palette.
	 * 
	 * Corresponding event handling method: {@code highlightsOnCreate(ICreateFeature feature)}
	 * 
	 * @param viewer
	 * @return
	 */
	public Highlighter listenToPaletteDrag(PaletteViewer viewer) {
		System.out.println("Add PaletteDragSourceListener to " + viewer);
		viewer.addDragSourceListener(new PaletteDragSourceListener(viewer));
		return this;
	}
	
	/**
	 * Registers this object for the specified editor to activate highlighting
	 * when an existing PictogramElement in the Diagram is dragged.
	 * 
	 * Corresponding event handling method: {@code highlightsOnDrag(PictogramElement pe)}
	 * 
	 * @param editor
	 * @param control
	 * @return
	 */
	public Highlighter listenToDiagramDrag(DiagramEditor editor, Control control) {
		DiagramDragSourceListener listener = new DiagramDragSourceListener(editor);
		editor.getGraphicalViewer().addDragSourceListener(listener);
		control.addMouseListener(listener);
		return this;
	}
	
	public String onCreateStart(ICreateFeature feature) {
		return turnOnHighlights(getHighlightablesOnCreate((ICreateFeature) feature));
	}
	
	public void onCreateEnd(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	public String onConnectionStart(ICreateConnectionFeature feature, ICreateConnectionContext context) {
		String contextKey = turnOnHighlights(getHighlightablesOnConnect(feature, context));
		return contextKey;
	}
	
	public void onConnectionCancel(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	public void onConnectionEnd(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	public String onReconnectionStart(IReconnectionFeature feature, IReconnectionContext context) {
		String contextKey = turnOnHighlights(getHighlightablesOnReconnect(feature, context));
		return contextKey;
	}
	
	public void onReconnectionCancel(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	public void onReconnectionEnd(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	public String onDragStart(PictogramElement dragged) {
		return turnOnHighlights(getHighlightablesOnDrag(dragged));
	}
	
	public void onDragEnd(String contextKey) {
		turnOffHighlights(contextKey);
	}
	
	private String turnOnHighlights(Collection<PictogramElement> pes) {
		List<Highlight> highlights = new ArrayList<>();
		if (pes != null && !pes.isEmpty()) {
			for (PictogramElement pe : pes) {
				Highlight highlight = getHighlight(pe);
				if (highlight != null) {
					highlights.add(highlight);
					highlight.swell(0.2);
				}
			}
		}
		String contextKey = getContextKey();
		highlightContexts.put(contextKey, highlights);
		return contextKey;
	}
	
	private void turnOffHighlights(String transactionKey) {
		Collection<Highlight> highlights = highlightContexts.get(transactionKey);
		if (highlights != null && !highlights.isEmpty()) {
			for (Highlight highlight : highlights) try {
				highlight.fade(0.2);
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	private String getContextKey() {
		return UUID.randomUUID().toString();
	}
	
	
	protected class PaletteDragSourceListener extends TemplateTransferDragSourceListener {
		
		private String contextKey;
		
		public PaletteDragSourceListener(PaletteViewer viewer) {
			super(viewer);
		}
		
		@Override
		public void dragStart(DragSourceEvent event) {
			super.dragStart(event);
			try {
				CreationFactory template = (CreationFactory) getTemplate();
				if (template != null) {
					Object feature = template.getNewObject();
					if (feature instanceof ICreateFeature) {
						contextKey = onCreateStart((ICreateFeature) feature);
					}
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		
		
		@Override
		public void dragFinished(DragSourceEvent event) {
			super.dragFinished(event);
			onCreateEnd(contextKey);
		}
	}
	
	
	protected class DiagramDragSourceListener extends TemplateTransferDragSourceListener implements MouseListener {
		
		String contextKey;
		DiagramEditor editor;
		
		public DiagramDragSourceListener(DiagramEditor editor) {
			super(editor.getGraphicalViewer());
			this.editor = editor;
		}
		
		@Override
		@SuppressWarnings("restriction")
		public void dragStart(DragSourceEvent event) {
			event.doit = false;
			System.out.println("[Highlighter] dragStart doit=" + event.doit);
			try {
//				System.out.println("[Highlighter] dragStart " + editor.getDiagramBehavior().getDiagramContainer().getGraphicalViewer().findHandleAt(new Point(event.x, event.y)));
				
				EditPart clicked = editor.getDiagramBehavior().getDiagramContainer().getGraphicalViewer().findObjectAt(new Point(event.x, event.y));
				if (clicked instanceof ContainerShapeEditPart) {
					contextKey = onDragStart(((ContainerShapeEditPart)clicked).getPictogramElement());
				}
//				else if (editor.getDiagramBehavior().getDiagramContainer().getGraphicalViewer().getFocusEditPart() instanceof FreeFormConnectionEditPart) {
//					FreeFormConnectionEditPart part = (FreeFormConnectionEditPart) editor.getDiagramBehavior().getDiagramContainer().getGraphicalViewer().getFocusEditPart();
//					EditPolicy policy = part.getEditPolicy(EditPolicy.CONNECTION_ENDPOINTS_ROLE);
//					if (policy != null && policy instanceof ConnectionHighlightEditPolicy) {
//						ConnectionHighlightEditPolicy chep = (ConnectionHighlightEditPolicy) policy;
//					}
//				}
			} catch(Exception e) {
				e.printStackTrace();
			}
			
			// inform that we are not interested in handling the drag
			
		}
		
		@Override
		public void mouseUp(MouseEvent evt) {
			onDragEnd(contextKey);
		}
		
		@Override
		public Transfer getTransfer() {
			return LocalSelectionTransfer.getTransfer();
		}
		
		@Override public void dragSetData(DragSourceEvent event) {}
		@Override public void dragFinished(DragSourceEvent event) {}
		@Override public void mouseDoubleClick(MouseEvent e) {}
		@Override public void mouseDown(MouseEvent event) {}
		
	}
	
	
	protected class DiagramDropTargetListener extends AbstractTransferDropTargetListener {

		public DiagramDropTargetListener(EditPartViewer viewer) {
			super(viewer);
			setEnablementDeterminedByCommand(true);
		}
		
		@Override
		protected void updateTargetRequest() {
			((CreateRequest) getTargetRequest()).setLocation(getDropLocation());
		}

		@Override
		protected Request createTargetRequest() {
			CreateRequest request = new CreateRequest();
			request.setFactory(new MyCreationFactory());
			request.setLocation(getDropLocation());
			return request;
		}

		@Override
		protected void handleDragOver() {
			super.handleDragOver();
			Command command = getCommand();
			if (command != null && command.canExecute())
				getCurrentEvent().detail = DND.DROP_COPY;
		}
		
		@Override
		public Transfer getTransfer() {
			return new LocalSelectionTransfer() {
				
				@Override
				protected int[] getTypeIds() {
					return super.getTypeIds();
				}
				
				@Override
				protected String[] getTypeNames() {
					return super.getTypeNames();
				}
				
				@Override
				public TransferData[] getSupportedTypes() {
					return super.getSupportedTypes();
				}
				
				@Override
				public boolean isSupportedType(TransferData transferData) {
					return super.isSupportedType(transferData);
				}
			};
		}

		private class MyCreationFactory implements CreationFactory {

			public MyCreationFactory() {
			}

			public Object getNewObject() {
				return LocalSelectionTransfer.getTransfer().getSelection();
			}

			public Object getObjectType() {
				return ISelection.class;
			}
		}
	}
}
	
