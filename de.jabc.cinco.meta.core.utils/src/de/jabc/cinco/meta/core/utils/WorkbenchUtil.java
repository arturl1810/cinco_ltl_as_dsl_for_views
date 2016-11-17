package de.jabc.cinco.meta.core.utils;

import graphmodel.GraphModel;
import graphmodel.ModelElement;

import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.mm.pictograms.ContainerShape;
import org.eclipse.graphiti.mm.pictograms.Diagram;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.mm.pictograms.Shape;
import org.eclipse.graphiti.ui.editor.DiagramBehavior;
import org.eclipse.graphiti.ui.editor.DiagramEditor;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.MultiPageEditorPart;

import de.jabc.cinco.meta.core.utils.eapi.DiagramEAPI;
import de.jabc.cinco.meta.core.utils.eapi.DiagramEditorEAPI;
import de.jabc.cinco.meta.core.utils.eapi.DiagramTypeProviderEAPI;
import de.jabc.cinco.meta.core.utils.eapi.IEditorPartEAPI;
import de.jabc.cinco.meta.core.utils.eapi.ModelElementEAPI;

public class WorkbenchUtil {
		
	/**
	 * Retrieve the API extension of the specified editor that
	 * provides editor-specific utility methods for convenience.
	 */
	public static IEditorPartEAPI eapi(IEditorPart editor) {
		return new IEditorPartEAPI(editor);
	}
	
	public static DiagramEAPI eapi(Diagram diagram) {
		return new DiagramEAPI(diagram);
	}
	
	public static ModelElementEAPI eapi(ModelElement element) {
		return new ModelElementEAPI(element);
	}
	
	public static DiagramEditorEAPI eapi(DiagramEditor editor) {
		return new DiagramEditorEAPI(editor);
	}
	
	public static DiagramTypeProviderEAPI eapi(IDiagramTypeProvider dtp) {
		return new DiagramTypeProviderEAPI(dtp);
	}
	
	public static IWorkbench getWorkbench() {
		return PlatformUI.getWorkbench();
	}
	
	public static IWorkbenchWindow getActiveWorkbenchWindow() {
		IWorkbench workbench = getWorkbench();
		return (workbench != null) ? workbench.getActiveWorkbenchWindow() : null;
	}

	public static IWorkbenchPage getActivePage() {
		IWorkbenchWindow window = getActiveWorkbenchWindow();
		return (window != null) ? window.getActivePage() : null;
	}
	
	public static IEditorPart getActiveEditor() {
		IWorkbenchPage page = getActivePage();
		return (page != null) ? page.getActiveEditor() : null;
	}
	
	public static DiagramEditor getDiagramEditor() {
		IEditorPart editor = getActiveEditor();
		if (editor == null)
			return null;
		if (editor instanceof MultiPageEditorPart) {
			Object page = ((MultiPageEditorPart) editor).getSelectedPage();
			if (page instanceof DiagramEditor)
				return (DiagramEditor) page;
		}
		return editor instanceof DiagramEditor
				? (DiagramEditor) editor
				: null;
	}
	
	public static Object getBusinessObject(PictogramElement pe) {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? eapi(editor).getBusinessObject(pe) : null;
	}
	
	public static Object getPictogramElement(Object businessObject) {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? eapi(editor).getPictogramElement(businessObject) : null;
	}

	public static Diagram getDiagram() {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? eapi(editor).getDiagram() : null;
	}
	
	public static DiagramBehavior getDiagramBehavior() {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? editor.getDiagramBehavior() : null;
	}
	
	public static IDiagramTypeProvider getDiagramTypeProvider() {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? editor.getDiagramTypeProvider() : null;
	}
	
	public static GraphModel getModel() {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? eapi(editor).getModel() : null;
	}
	
	public static List<Shape> getShapes() {
		return eapi(getDiagram()).getShapes();
	}
	
	public static List<ContainerShape> getContainerShapes() {
		return eapi(getDiagram()).getContainerShapes();
	}
	
	public static boolean testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		Object bo = getBusinessObject(pe);
		return (bo != null) ? cls.isAssignableFrom(bo.getClass()) : false;
	}
	
	public static Treat treat(Object obj) {
		return new Treat(obj);
	}
	
	public static Treat treatBusinessObject(PictogramElement pe) {
		return new Treat(getBusinessObject(pe));
	}
	
	/**
	 * Convenient method to wrap a modification of an EObject in a recording command.
	 * 
	 * <p>Retrieves a TransactionalEditingDomain for the specified object via the
	 * {@linkplain TransactionUtil#getEditingDomain(EObject)}, hence it should be ensured
	 * that it exists.
	 * 
	 * @param obj  The object for which to access the TransactionalEditingDomain.
	 * @return  An Edit object whose application is wrapped into the recording command.
	 */
	public static Edit edit(EObject obj) {
		return (runnable) -> {
			TransactionalEditingDomain domain = TransactionUtil.getEditingDomain(obj);
			domain.getCommandStack().execute(new RecordingCommand(domain) {
				@Override protected void doExecute() {
					try {
						runnable.run();
					} catch(IllegalStateException e) {
						e.printStackTrace();
					}
				}
			});
	    };
	}
	
	@FunctionalInterface
	public static interface Edit {
		public void apply(Runnable runnable);
	}
	
	public static class Treat {
		
		private Object obj;
		
		public Treat(Object obj) {
			this.obj = obj;
		}

		public <T> TreatHandle<T> as(Class<T> cls) {
			try {
				return new TreatHandle<T>(cls.cast(obj));
			} catch(ClassCastException e) {
				throw new RuntimeException(e);
			}
		}
	}
	
	public static class TreatHandle<T> {

		private T obj;
		
		public TreatHandle(T obj) {
			this.obj = obj;
		}

		public void apply(Consumer<T> c) {
			c.accept(obj);
		}

		public <U> U apply(Function<T,U> f) {
			return f.apply(obj);
		}
		
		public boolean test(Predicate<T> predicate) {
			return predicate.test(obj);
		}

		public T get() {
			return obj;
		}
		
		@SuppressWarnings("unchecked")
		public Class<? extends T> clazz() {
			return (Class<? extends T>) obj.getClass();
		}
	}
}
