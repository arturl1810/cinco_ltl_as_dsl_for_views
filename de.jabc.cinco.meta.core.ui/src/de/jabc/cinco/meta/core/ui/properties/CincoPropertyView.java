package de.jabc.cinco.meta.core.ui.properties;

import graphmodel.GraphModel;
import graphmodel.ModelElement;

import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.OptionalInt;
import java.util.Set;
import java.util.stream.Collectors;

import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.observable.value.IObservableValue;
import org.eclipse.core.databinding.property.list.IListProperty;
import org.eclipse.emf.databinding.EMFDataBindingContext;
import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.databinding.edit.EMFEditProperties;
import org.eclipse.emf.databinding.edit.IEMFEditListProperty;
import org.eclipse.emf.databinding.edit.IEMFEditValueProperty;
import org.eclipse.emf.ecore.EAttribute;
import org.eclipse.emf.ecore.EEnum;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.emf.transaction.TransactionalEditingDomain;
import org.eclipse.emf.transaction.util.TransactionUtil;
import org.eclipse.gef.GraphicalEditPart;
import org.eclipse.graphiti.mm.pictograms.PictogramElement;
import org.eclipse.graphiti.services.Graphiti;
import org.eclipse.graphiti.ui.platform.GraphitiConnectionEditPart;
import org.eclipse.graphiti.ui.platform.GraphitiShapeEditPart;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.databinding.swt.ISWTObservableValue;
import org.eclipse.jface.databinding.swt.IWidgetValueProperty;
import org.eclipse.jface.databinding.swt.WidgetProperties;
import org.eclipse.jface.databinding.viewers.ObservableListContentProvider;
import org.eclipse.jface.databinding.viewers.ObservableListTreeContentProvider;
import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.ComboViewer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.DateTime;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IViewSite;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;

import de.jabc.cinco.meta.core.ui.converter.CharStringConverter;
import de.jabc.cinco.meta.core.ui.listener.CincoTableMenuListener;
import de.jabc.cinco.meta.core.ui.listener.CincoTreeMenuListener;
import de.jabc.cinco.meta.core.ui.utils.CincoPropertyUtils;
import de.jabc.cinco.meta.core.ui.validator.TextValidator;

/**
 * @author kopetzki
 *
 */
public class CincoPropertyView extends ViewPart implements ISelectionListener{

	private Map<EObject, Composite> compositesMap;
	
	private static Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap = new HashMap<Class<? extends EObject>, IEMFListProperty>();
	private static Map<Class<? extends EObject>, List<EStructuralFeature>> attributesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
	private static Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
	private Map<Object, Object[]> treeExpandState;

	private static Set<EStructuralFeature> multiLineAttributes = new HashSet<EStructuralFeature>();
	private static Set<EStructuralFeature> readOnlyAttributes = new HashSet<EStructuralFeature>();
	
	private Composite parent;
	private Composite simpleViewComposite;
	private TreeViewer treeViewer;

	private final GridData labelLayoutData = new GridData(SWT.LEFT, SWT.CENTER,
			false, false);
	private final GridData tableLabelLayoutData = new GridData(SWT.LEFT,
			SWT.TOP, false, false);
	private final GridData textLayoutData = new GridData(SWT.FILL, SWT.CENTER,
			true, false);
	private final GridData tableLayoutData = new GridData(SWT.FILL, SWT.FILL,
			true, true);


	private TransactionalEditingDomain domain;
	private EMFDataBindingContext context;
	private Object lastSelectedObject;

	
	public CincoPropertyView() {
		compositesMap = new HashMap<EObject, Composite>();
		treeExpandState = new HashMap<Object, Object[]>();
		
		multiLineAttributes = new HashSet<EStructuralFeature>();
		readOnlyAttributes = new HashSet<EStructuralFeature>();
		
		context = new EMFDataBindingContext();
		
		tableLayoutData.minimumHeight = 50;
	}

	@Override
	public void selectionChanged(IWorkbenchPart part, ISelection selection) {
		if (isStructuredSelection(selection)) {
			Object element = ((IStructuredSelection) selection).getFirstElement();
			PictogramElement pe = null;
			if (element instanceof GraphicalEditPart)
				pe = getPictogramElement(element);
			
			EObject bo = getBusinessObject(pe);
			init_PropertyView(bo, parent);
		}
	}
	
	public static void init_EStructuralFeatures(Class<? extends EObject> clazz,
			EStructuralFeature... features) {
		List<EStructuralFeature> featureList = Arrays.asList(features);
		List<EStructuralFeature> attributeList = featureList.stream()
				.filter(f -> f instanceof EAttribute)
				.collect(Collectors.toList());
		List<EStructuralFeature> referenceList = featureList.stream()
				.filter(f -> f instanceof EReference)
				.collect(Collectors.toList());

		init_ListPorperties(clazz,
				referenceList.toArray(new EStructuralFeature[] {}));

		if (referencesMap.get(clazz) == null)
			referencesMap.put(clazz, referenceList);

		if (attributesMap.get(clazz) == null)
			attributesMap.put(clazz, attributeList);
	}

	public static void init_ListPorperties(Class<? extends EObject> clazz,	EStructuralFeature... features) {
		if (emfListPropertiesMap.get(clazz) == null) {
			emfListPropertiesMap.put(clazz, EMFProperties.multiList(features));
		}
	}

	public static void init_MultiLineAttributes(EStructuralFeature... features) {
		for (EStructuralFeature f : features)
			multiLineAttributes.add(f);
	}
	
	public static void init_ReadOnlyAttributes(EStructuralFeature... features) {
		for (EStructuralFeature f : features)
			readOnlyAttributes.add(f);
	}
	
	public void init_PropertyView(EObject bo, Composite parent) {
		if (bo == null || bo.equals(lastSelectedObject) || referencesMap.get(bo.getClass()) == null)
			return;
		
		if (treeViewer != null && !treeViewer.getTree().isDisposed())
			treeExpandState.put(lastSelectedObject, treeViewer.getExpandedElements());
		
		disposeChildren(parent);
		context = new EMFDataBindingContext();
		Composite mainComposite = new Composite(parent, SWT.NONE);
		setTwoColumnGridLayout(mainComposite);
		mainComposite.setLayoutData(new GridData(SWT.NONE));

		createTreePropertyView(bo, mainComposite);
		createSimplePropertyView(bo, mainComposite);

		mainComposite.pack();
		parent.layout(true);
		
		compositesMap.put(bo, mainComposite);
		
		lastSelectedObject = bo;
	}


	public void createTreePropertyView(EObject bo, Composite parent) {
		Tree tree = new Tree(parent, SWT.BORDER | SWT.SINGLE);
		GridData data = new GridData(SWT.LEFT, SWT.FILL, false, true);
		data.widthHint = 255;
		tree.setLayoutData(data);
		TreeViewer viewer = new TreeViewer(tree);

		ObservableListTreeContentProvider cp = new ObservableListTreeContentProvider(
				//FIXME: Fix the CincoTreeFactory. Removing single valued attributes 
				// 		from the tree ends in AssertionFailedException 
				new CincoTreeFactory(bo, emfListPropertiesMap),
				new CincoTreeStructureAdvisor(referencesMap));

		viewer.setContentProvider(cp);
		viewer.setLabelProvider(getLabelProvider());

		List<EStructuralFeature> inputList = referencesMap.get(bo.getClass());
		TransactionalEditingDomain dom = getOrCreateEditingDomain(bo);
		IEMFEditListProperty input = EMFEditProperties.multiList(dom,
				inputList.toArray(new EStructuralFeature[] {}));
		viewer.setInput(input.observe(bo));

		ISelectionChangedListener listener = createSelectionListener();
		viewer.addSelectionChangedListener(listener);

		MenuManager menuManager = new MenuManager();
		menuManager.setRemoveAllWhenShown(true);
		menuManager.addMenuListener(new CincoTreeMenuListener(viewer, referencesMap));

		viewer.getControl().setMenu(menuManager.createContextMenu(tree));
		viewer.getTree().setSelection(viewer.getTree().getItem(0));
		
		Object[] expandedElements = treeExpandState.get(bo);
		if (expandedElements != null)
			viewer.setExpandedElements(expandedElements);
		
		this.treeViewer = viewer;
	}


	private ISelectionChangedListener createSelectionListener() {
		ISelectionChangedListener listener = new ISelectionChangedListener() {

			@Override
			public void selectionChanged(SelectionChangedEvent event) {
				ISelection selection = event.getSelection();
				if (!(selection instanceof IStructuredSelection))
					return;

				Object o = ((IStructuredSelection) selection).getFirstElement();
				if (o instanceof EObject) {
					createSimplePropertyView((EObject) o);
					simpleViewComposite.layout(true);
				}
			}
		};
		return listener;
	}

	public void createSimplePropertyView(EObject bo, Composite parent) {

		Composite comp = new Composite(parent, SWT.BORDER);
		comp.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
		setTwoColumnGridLayout(comp);

		createUIAndBindings(bo, comp);

		simpleViewComposite = comp;
	}

	private void createUIAndBindings(EObject bo, Composite comp) {
		domain = getOrCreateEditingDomain(bo);

		List<EStructuralFeature> attributes = CincoPropertyUtils.getAllEStructuralFeatures(bo.getClass(), attributesMap);
		setLabelWidthHint(bo, comp, attributes);

		for (EStructuralFeature attr : attributes) {
			if (attr.getUpperBound() == 1) {
				createSingleAttributeProperty(bo, comp, (EAttribute) attr);
			}
			if (attr.getUpperBound() == -1) {
				createMultiAttributeProperty(bo, comp, (EAttribute) attr);
			}
		}
	}

	protected void createSimplePropertyView(EObject o) {
		if (simpleViewComposite == null)
			throw new RuntimeException(
					"NPE: Composite for the simple property view is null");
		disposeChildren(simpleViewComposite);
		createUIAndBindings(o, simpleViewComposite);
	}

	private void createSingleAttributeProperty(EObject bo, Composite comp, EAttribute attr) {

		Label label = new Label(comp, SWT.NONE);
		label.setText(attr.getName() + ": ");
		label.setLayoutData(labelLayoutData);

		if (attr.getEAttributeType().getName().equals("EDate")) {
			label.setLayoutData(tableLabelLayoutData);
			Composite dateComposite = new Composite(comp, SWT.NONE);
			dateComposite.setLayout(new GridLayout(2, false));
			dateComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
			
			DateTime date = new DateTime(dateComposite, SWT.CALENDAR | SWT.TIME);
//			DateTime time = new DateTime(dateComposite, SWT.TIME);
			
			ISWTObservableValue uiPropDate = WidgetProperties.selection().observe(date);
//			ISWTObservableValue uiPropTime = WidgetProperties.selection().observe(time);
			
			IObservableValue boProp = EMFEditProperties.value(domain, attr).observe(bo);
			context.bindValue(uiPropDate, boProp);
//			context.bindValue(uiPropTime, boProp);
			
			date.setEnabled(!readOnlyAttributes.contains(attr));
		}  else if (attr.getEAttributeType() instanceof EEnum || attr.getEAttributeType().getName().equals("EBoolean")) {
			Combo combo = new Combo(comp, SWT.BORDER | SWT.DROP_DOWN | SWT.READ_ONLY);
			combo.setLayoutData(textLayoutData);
			ComboViewer cv = new ComboViewer(combo);
			
			cv.setContentProvider(new ArrayContentProvider());
			if (attr.getEAttributeType() instanceof EEnum)
				cv.setInput(((EEnum) attr.getEAttributeType()).getELiterals());
			else cv.setInput(new String[] {"true", "false"});
			
			ISWTObservableValue uiProp = WidgetProperties.selection().observe(combo);
			IObservableValue modelObs = EMFEditProperties.value(domain,attr).observe(bo);
			
			context.bindValue(uiProp, modelObs);
			combo.setEnabled(!readOnlyAttributes.contains(attr));
		} else {
			Text text = null;
			
			if (multiLineAttributes.contains(attr)) {
				text = new Text(comp, SWT.BORDER | SWT.MULTI | SWT.V_SCROLL);
				text.setLayoutData(tableLayoutData);
				label.setLayoutData(tableLabelLayoutData);
			} else {
				text = new Text(comp, SWT.BORDER);
				text.setLayoutData(textLayoutData);
			}
			
			text.addModifyListener(new TextValidator(attr.getEAttributeType()));
			
			IWidgetValueProperty uiProp = WidgetProperties.text(new int[] {
					SWT.DefaultSelection, SWT.FocusOut });
			
			IEMFEditValueProperty boPorp = EMFEditProperties.value(domain, attr);
			UpdateValueStrategy updateStrategy = new UpdateValueStrategy();
			
			updateStrategy.setConverter(new CharStringConverter());
			
			if (attr.getEAttributeType().getName().equals("EChar"))
				context.bindValue(uiProp.observe(text), boPorp.observe(bo), updateStrategy, updateStrategy);
			else context.bindValue(uiProp.observe(text), boPorp.observe(bo));
			
			text.setEnabled(!readOnlyAttributes.contains(attr));
		}
		
	}

	private void createMultiAttributeProperty(EObject bo, Composite comp,
			EAttribute attr) {

		Label label = new Label(comp, SWT.NONE);
		label.setText(attr.getName() + ": ");
		label.setLayoutData(tableLabelLayoutData);

		Table table = new Table(comp, SWT.SINGLE | SWT.BORDER);
		TableViewer tableViewer = new TableViewer(table);
		table.setLayoutData(tableLayoutData);

		tableViewer.setContentProvider(new ObservableListContentProvider());
		tableViewer.setLabelProvider(getLabelProvider());

		IListProperty input = EMFEditProperties.list(domain, attr);
		tableViewer.setInput(input.observe(bo));
		
		MenuManager menuManager = new MenuManager();
		menuManager.setRemoveAllWhenShown(true);
		menuManager.addMenuListener(new CincoTableMenuListener(tableViewer, bo, attr));

		tableViewer.getControl().setMenu(menuManager.createContextMenu(table));
		
	}

	private void setLabelWidthHint(EObject bo, Composite comp,
			List<EStructuralFeature> attributes) {

		OptionalInt max = attributes.stream()
				.mapToInt(a -> a.getName().length()).max();
		if (!max.isPresent()) {
			Label l = new Label(comp, SWT.NONE);
			l.setText("No properties available...");
			return;
		}
		labelLayoutData.widthHint = max.getAsInt() * 10;
		labelLayoutData.minimumWidth = max.getAsInt() * 9;
	}

	private void disposeChildren(Composite composite) {
		for (Control c : composite.getChildren()) {
			c.dispose();
		}
	}

	
	private void setTwoColumnGridLayout(Composite composite) {
		composite.setLayout(new GridLayout(2, false));
	}

	public void createAttributeView(Composite comp, EObject bo,
			EAttribute... attributes) {

		for (EAttribute attr : attributes) {
			Label label = new Label(comp, SWT.NONE);
			label.setText(attr.getName());
			label.setLayoutData(labelLayoutData);

			Text text = new Text(comp, SWT.BORDER);
			text.setText("" + bo.eGet(attr));
			text.setLayoutData(textLayoutData);
		}
	}

	private LabelProvider getLabelProvider() {
		return new LabelProvider() {
			@Override
			public String getText(Object element) {
				if (!(element instanceof EObject))
					return super.getText(element);

				if (element instanceof ModelElement || element instanceof GraphModel)
					return element.getClass().getSimpleName()
							.replace("Impl", "");
				
				
				EObject eContainer = ((EObject) element).eContainer();
				for (EReference ref : eContainer.eClass().getEAllReferences()) {
					if (ref.getEType().isInstance(element) && ref != null) {
						return ref.getName();
					}
				}

				return null;
			}
		};
	}

	private TransactionalEditingDomain getOrCreateEditingDomain(EObject bo) {
		domain = TransactionUtil.getEditingDomain(bo);
		if (domain == null)
			TransactionalEditingDomain.Factory.INSTANCE.createEditingDomain(bo
					.eResource().getResourceSet());
		if (domain == null)
			throw new RuntimeException("Could not get/create TransactionalEditingDomain for object: " + bo);
		return domain;
	}

	@Override
	public void createPartControl(Composite parent) {
		this.parent = parent;
	}

	@Override
	public void setFocus() {
		
	}

	@Override
	public void init(IViewSite site) throws PartInitException {
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().addSelectionListener(this);
		super.init(site);
	}
	
	@Override
	public void dispose() {
		super.dispose();
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().removeSelectionListener(this);
	}
	
	public boolean isStructuredSelection(ISelection selection) {
		return selection instanceof IStructuredSelection;
	}
	
	public PictogramElement getPictogramElement(Object element) {
		if (element instanceof GraphitiShapeEditPart) 
			return ((GraphitiShapeEditPart) element).getPictogramElement();
		
		if (element instanceof GraphitiConnectionEditPart)
			return ((GraphitiConnectionEditPart) element).getPictogramElement();
		
		return null;
	}
	
	public EObject getBusinessObject(PictogramElement pe) {
		return Graphiti.getLinkService().getBusinessObjectForLinkedPictogramElement(pe);
	}
	
}
