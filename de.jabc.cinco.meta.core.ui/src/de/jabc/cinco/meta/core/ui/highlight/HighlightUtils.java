package de.jabc.cinco.meta.core.ui.highlight;

import graphmodel.GraphModel;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Predicate;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.transaction.RecordingCommand;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.graphiti.dt.IDiagramTypeProvider;
import org.eclipse.graphiti.features.IFeatureProvider;
import org.eclipse.graphiti.mm.algorithms.GraphicsAlgorithm;
import org.eclipse.graphiti.mm.pictograms.Connection;
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

/**
 * Convenient class that provides static methods for accessing runtime objects
 * in a Graphiti-related context.
 * 
 * <p><i>This ain't no Big-Google-'G' but the Great-Graphiti-'G'
 * 
 * @author Steve Bosselmann
 */
public class HighlightUtils {
	
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
		return (editor != null) ? resp(editor).getBusinessObject(pe) : null;
	}
	
	public static Object getPictogramElement(Object businessObject) {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? resp(editor).getPictogramElement(businessObject) : null;
	}

	public static Diagram getDiagram() {
		DiagramEditor editor = getDiagramEditor();
		return (editor != null) ? resp(editor).getDiagram() : null;
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
		return (editor != null) ? resp(editor).getModel() : null;
	}
	
	public static List<Shape> getShapes() {
		return resp(getDiagram()).getShapes();
	}
	
	public static List<ContainerShape> getContainerShapes() {
		return resp(getDiagram()).getContainerShapes();
	}
	
	public static boolean testBusinessObjectType(PictogramElement pe, Class<?> cls) {
		Object bo = getBusinessObject(pe);
		return (bo != null) ? cls.isAssignableFrom(bo.getClass()) : false;
	}
	
	public static DiagramEAPI resp(Diagram diagram) {
		return new DiagramEAPI(diagram);
	}
	
	public static DiagramEditorEAPI resp(DiagramEditor editor) {
		return new DiagramEditorEAPI(editor);
	}
	
	public static DiagramTypeProviderEAPI resp(IDiagramTypeProvider dtp) {
		return new DiagramTypeProviderEAPI(dtp);
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

	public static void refreshDecorators() {
		refreshDecorators(getShapes());
	}
	
	public static void refreshDecorators(Collection<? extends PictogramElement> pes) {
		pes.stream().forEach(pe -> refreshDecorators(pe));
	}
	
	public static void refreshDecorators(PictogramElement pe) {
		getDiagramBehavior().refreshRenderingDecorators(pe);
	}
	
	public static void triggerUpdate(PictogramElement pe) {
		GraphicsAlgorithm ga = pe.getGraphicsAlgorithm();
		edit(pe).apply(() -> {
			if (pe instanceof Connection) {
				ga.setLineVisible(!ga.getLineVisible());
				ga.setLineVisible(!ga.getLineVisible());
			} else {
				ga.setFilled(!ga.getFilled());
				ga.setFilled(!ga.getFilled());
			}
		});
	}
	
	public static class Treat {
		
		private Object obj;
		
		public Treat(Object obj) {
			this.obj = obj;
		}

		public <T> TreatHandle<T> as(Class<T> cls) throws TreatFail {
			try {
				return new TreatHandle<T>(cls.cast(obj));
			} catch(ClassCastException e) {
				throw new TreatFail(e);
			}
		}
	}
	
	public static class TreatFail extends ClassCastException {

		private static final long serialVersionUID = -7432484104756484616L;
		
		public TreatFail(ClassCastException e) {
			super(e.getMessage());
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
	
	@FunctionalInterface
	public static interface Edit {
		public void apply(Runnable runnable);
	}
	
	public static class DiagramEAPI {

		private Diagram diagram;
		
		public DiagramEAPI(Diagram diagram) {
			this.diagram = diagram;
		}
		
		public List<ContainerShape> getContainerShapes() {
			return getContainerShapes(diagram);
		}
		
		public List<ContainerShape> getContainerShapes(boolean includeParent) {
			return getContainerShapes(diagram, includeParent);
		}
		
		public List<ContainerShape> getContainerShapes(ContainerShape parent) {
			return getContainerShapes(parent, false);
		}
		
		public List<ContainerShape> getContainerShapes(ContainerShape parent, boolean includeParent) {
			ArrayList<ContainerShape> shapes = new ArrayList<ContainerShape>();
			if (includeParent)
				shapes.add(parent);
			collectChildShapes(parent, shapes, ContainerShape.class);
			return shapes;
		}
		
		public List<Shape> getShapes() {
			return getShapes(diagram);
		}
		
		public List<Shape> getShapes(boolean includeParent) {
			return getShapes(diagram, includeParent);
		}
		
		public List<Shape> getShapes(ContainerShape parent) {
			return getShapes(parent, false);
		}
		
		public List<Shape> getShapes(ContainerShape parent, boolean includeParent) {
			ArrayList<Shape> shapes = new ArrayList<Shape>();
			if (includeParent)
				shapes.add(parent);
			collectChildShapes(parent, shapes);
			return shapes;
		}
		
		public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz) {
			return getShapes(clazz, diagram);
		}
		
		public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz, ContainerShape parent) {
			return getShapes(clazz, parent, false);
		}
		
		public <T extends Shape> ArrayList<T> getShapes(Class<T> clazz, ContainerShape parent, boolean includeParent) {
			ArrayList<T> shapes = new ArrayList<T>();
			if (includeParent && clazz.isInstance(parent))
				shapes.add(clazz.cast(parent));
			collectChildShapes(parent, shapes, clazz);
			return shapes;
		}
		
		private static <T extends Shape> void collectChildShapes(ContainerShape container, ArrayList<T> shapes) {
			collectChildShapes(container, shapes, null);
		}
		
		@SuppressWarnings("unchecked")
		private static <T extends Shape> void collectChildShapes(ContainerShape container, ArrayList<T> shapes, Class<T> cls) {
			container.getChildren().stream()
				.filter((cls != null) ? cls::isInstance : x -> true)
				.forEach(child -> {
					shapes.add((T) child);
					if (child instanceof ContainerShape)
						collectChildShapes((ContainerShape) child, shapes, cls);
				});
		}
	}
	
	public static class DiagramEditorEAPI {

		private DiagramEditor editor;
		
		public DiagramEditorEAPI(DiagramEditor editor) {
			this.editor = editor;
		}
		
		public Object getBusinessObject(PictogramElement pe) {
			IFeatureProvider fp = getFeatureProvider();
			return (fp != null) ? fp.getBusinessObjectForPictogramElement(pe) : null;
		}
			
		public Object getPictogramElement(Object businessObject) {
			IFeatureProvider fp = getFeatureProvider();
			return (fp != null) ? fp.getPictogramElementForBusinessObject(businessObject) : null;
		}

		public Diagram getDiagram() {
			IDiagramTypeProvider dtp = editor.getDiagramTypeProvider();
			return (dtp != null) ? dtp.getDiagram() : null;
		}
		
		public IFeatureProvider getFeatureProvider() {
			IDiagramTypeProvider dtp = editor.getDiagramTypeProvider();
			return (dtp != null) ? dtp.getFeatureProvider() : null;
		}
		
		public GraphModel getModel() {
			Object bo = getBusinessObject(getDiagram());
			return (bo != null && bo instanceof GraphModel) ? (GraphModel) bo : null;
		}
		
		public ResourceSet getResourceSet() {
			DiagramBehavior db = editor.getDiagramBehavior();
			return (db != null) ? db.getResourceSet() : null;
		}
	}
	
	public static class DiagramTypeProviderEAPI {

		private IDiagramTypeProvider dtp;
		
		public DiagramTypeProviderEAPI(IDiagramTypeProvider editor) {
			this.dtp = editor;
		}
		
		public Object getBusinessObject(PictogramElement pe) {
			IFeatureProvider fp = dtp.getFeatureProvider();
			return (fp != null) ? fp.getBusinessObjectForPictogramElement(pe) : null;
		}
		
		public GraphModel getModel() {
			Object bo = getBusinessObject(dtp.getDiagram());
			return (bo != null && bo instanceof GraphModel) ? (GraphModel) bo : null;
		}
		
		public ResourceSet getResourceSet() {
			Object db = dtp.getDiagramBehavior();
			return (db != null && db instanceof DiagramBehavior) ? ((DiagramBehavior)db).getResourceSet() : null;
		}
	}
}
