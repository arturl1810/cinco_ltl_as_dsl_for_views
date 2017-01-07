package de.jabc.cinco.meta.core.ui.properties;

import static de.jabc.cinco.meta.core.utils.eapi.Cinco.*;
import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workbench.getActiveEditor;
import static de.jabc.cinco.meta.core.utils.eapi.Cinco.Workspace.getFiles;

import graphmodel.Container;
import graphmodel.GraphModel;
import graphmodel.ModelElement;
import graphmodel.ModelElementContainer;

import java.util.ArrayList;
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
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.databinding.EMFDataBindingContext;
import org.eclipse.emf.databinding.EMFProperties;
import org.eclipse.emf.databinding.IEMFListProperty;
import org.eclipse.emf.databinding.edit.EMFEditObservables;
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
import org.eclipse.jface.databinding.viewers.IViewerObservableValue;
import org.eclipse.jface.databinding.viewers.ObservableListContentProvider;
import org.eclipse.jface.databinding.viewers.ObservableListTreeContentProvider;
import org.eclipse.jface.databinding.viewers.ViewersObservables;
import org.eclipse.jface.viewers.ArrayContentProvider;
import org.eclipse.jface.viewers.CellEditor;
import org.eclipse.jface.viewers.ComboViewer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.ISelectionChangedListener;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.LabelProvider;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TableViewer;
import org.eclipse.jface.viewers.TextCellEditor;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.ScrolledComposite;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Combo;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.DateTime;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.Tree;
import org.eclipse.ui.IPartListener2;
import org.eclipse.ui.ISelectionListener;
import org.eclipse.ui.IViewSite;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.IWorkbenchPartReference;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.part.ViewPart;

import de.jabc.cinco.meta.core.ui.converter.CharStringConverter;
import de.jabc.cinco.meta.core.ui.listener.CincoTableMenuListener;
import de.jabc.cinco.meta.core.ui.listener.CincoTreeMenuListener;
import de.jabc.cinco.meta.core.ui.utils.CincoPropertyUtils;
import de.jabc.cinco.meta.core.ui.validator.TextValidator;
import de.jabc.cinco.meta.plugin.gratext.runtime.editor.MultiPageGratextEditor;

/**
 * @author kopetzki
 *
 */
public class CincoPropertyView extends ViewPart implements ISelectionListener, IPartListener2{

	private static Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap = new HashMap<Class<? extends EObject>, IEMFListProperty>();
	private static Map<Class<? extends EObject>, List<EStructuralFeature>> attributesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
	private static Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
	private static Map<EStructuralFeature, Map<? extends Object, String>> possibleValuesMap = new HashMap<EStructuralFeature, Map<? extends Object, String>>();
	private Map<Object, Object[]> treeExpandState;

	private static Map<EStructuralFeature, List<String>> fileExtensionFilters = new HashMap<EStructuralFeature, List<String>>();
	
	private static Set<EStructuralFeature> multiLineAttributes = new HashSet<EStructuralFeature>();
	private static Set<EStructuralFeature> readOnlyAttributes = new HashSet<EStructuralFeature>();
	private static Set<EStructuralFeature> fileAttributes = new HashSet<EStructuralFeature>();
	private static Set<ISelectionListener> registeredListeners = new HashSet<ISelectionListener>();
	
	private Composite parent;
	private ScrolledComposite simpleViewComposite;
	private Composite treeViewComposite;
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
		treeExpandState = new HashMap<Object, Object[]>();
		
		multiLineAttributes = new HashSet<EStructuralFeature>();
		readOnlyAttributes = new HashSet<EStructuralFeature>();
		
		context = new EMFDataBindingContext();
		
		tableLayoutData.minimumHeight = 50;
		
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().addPartListener(this);
	}

	@Override
	public void selectionChanged(IWorkbenchPart part, ISelection selection) {
		if (isStructuredSelection(selection)) {
			Object element = ((IStructuredSelection) selection).getFirstElement();
			PictogramElement pe = null;
			if (element instanceof GraphicalEditPart)
				pe = getPictogramElement(element);
			
			EObject bo = getBusinessObject(pe);
			if (bo != null)
				init_PropertyView(bo);
			else if (part instanceof MultiPageGratextEditor) {
				clearPage();
			}
		}
	}
	
	private void clearPage() {
		disposeChildren(parent);
	}
	
	public static void addSelectionListener(ISelectionListener listener) {
		if (registeredListeners.contains(listener))
			return;
		IWorkbenchWindow activeWorkbenchWindow = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
		if (activeWorkbenchWindow == null)
			return;
		
		IWorkbenchPage activePage = activeWorkbenchWindow.getActivePage();
		if (activePage == null) 
			return;
		
		activePage.addSelectionListener(listener);
		registeredListeners.add(listener);
	}
	
	public static void init_EStructuralFeatures(Class<? extends EObject> clazz,
			EStructuralFeature... features) {
		List<EStructuralFeature> featureList = Arrays.asList(features);
		List<EStructuralFeature> attributeList = featureList.stream()
				.filter(f -> (f instanceof EAttribute) || (f instanceof EReference && !((EReference) f).isContainment()) )
				.collect(Collectors.toList());
		List<EStructuralFeature> referenceList = featureList.stream()
				.filter(f -> f instanceof EReference && ((EReference) f).isContainment())
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
	
	public static void init_FileAttributes(EStructuralFeature... features) {
		for (EStructuralFeature f : features)
			fileAttributes.add(f);
	}
	
	public static void init_FileAttributesExtensionFilters(EStructuralFeature feature, String[] extensions) {
		fileExtensionFilters.put(feature, Arrays.asList(extensions));
	}
	
	public void init_PropertyView(EObject bo) {
		if (bo == null || bo.equals(lastSelectedObject) || referencesMap.get(bo.getClass()) == null)
			return;
		
		if (treeViewer != null && !treeViewer.getTree().isDisposed())
			treeExpandState.put(lastSelectedObject, treeViewer.getExpandedElements());
		
		disposeChildren(parent);
		context = new EMFDataBindingContext();
		setTwoColumnGridLayout(parent);
		
		treeViewComposite = new Composite(parent, SWT.BORDER);
		treeViewComposite.setLayout(new GridLayout(1, false));
		treeViewComposite.setLayoutData(new GridData(SWT.LEFT, SWT.FILL, false, true));
		
		simpleViewComposite = new ScrolledComposite(parent, SWT.BORDER | SWT.V_SCROLL);
		simpleViewComposite.setLayout(new GridLayout(1,false));
		simpleViewComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));

		createTreePropertyView(bo);
		createSimplePropertyView(bo);
		
		treeViewComposite.pack();
		simpleViewComposite.pack();
		treeViewComposite.layout(true);
		simpleViewComposite.layout(true);
		
		parent.layout(true);
		
		lastSelectedObject = bo;
	}

	public static void refreshPossibleValues(EStructuralFeature feature, Map<? extends Object, String> values) {
		possibleValuesMap.put(feature, values);
	}

	public void createTreePropertyView(EObject bo) {
		Tree tree = new Tree(treeViewComposite, SWT.BORDER | SWT.SINGLE);
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
		
		viewer.expandAll();
		
//		Object[] expandedElements = treeExpandState.get(bo);
//		if (expandedElements != null)
//			viewer.setExpandedElements(expandedElements);
		
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
					disposeChildren(simpleViewComposite);
					createSimplePropertyView((EObject) o, simpleViewComposite);
				}
			}
		};
		return listener;
	}

	
	public void createSimplePropertyView(EObject bo, ScrolledComposite parent) {
		Composite comp = new Composite(parent, SWT.NONE);
		comp.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
		setTwoColumnGridLayout(comp);
		
		createUIAndBindings(bo, comp);
		
		parent.setContent(comp);
		parent.setExpandHorizontal(true);
		parent.setExpandVertical(true);
		parent.setAlwaysShowScrollBars(true);
		parent.setMinSize(parent.computeSize(SWT.DEFAULT, SWT.DEFAULT));
		
	}

	private void createUIAndBindings(EObject bo, Composite comp) {
		domain = getOrCreateEditingDomain(bo);

		List<EStructuralFeature> attributes = CincoPropertyUtils.getAllEStructuralFeatures(bo.getClass(), attributesMap);
		setLabelWidthHint(bo, comp, attributes);

		for (EStructuralFeature attr : attributes) {
			if (attr.getUpperBound() == 1) {
				createSingleAttributeProperty(bo, comp,  attr);
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
		Composite dataComp = new Composite(simpleViewComposite, SWT.NONE);
		dataComp.setLayout(new GridLayout(2,false));
		dataComp.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true, 1,1));
		createUIAndBindings(o, dataComp);
		simpleViewComposite.setContent(dataComp);
		simpleViewComposite.setExpandHorizontal(true);
		simpleViewComposite.setExpandVertical(true);
		simpleViewComposite.setAlwaysShowScrollBars(true);
		simpleViewComposite.layout(true, true);
		simpleViewComposite.setMinSize(dataComp.computeSize(SWT.DEFAULT, SWT.DEFAULT));
//		simpleViewComposite.getShell().pack();
	}

	private void createSingleAttributeProperty(EObject bo, Composite comp, EStructuralFeature feature) {
		if (feature instanceof EAttribute)
			createSingleAttributeProperty(bo, comp, (EAttribute) feature);
		if (feature instanceof EReference)
			createSingleAttributeProperty(bo, comp, (EReference) feature);
	}
	
	private void createSingleAttributeProperty(EObject bo, Composite comp, EReference ref) {
		Label label = new Label(comp, SWT.NONE);
		label.setText(ref.getName());
		label.setLayoutData(labelLayoutData);
		
		Class<?> instanceClass = ref.getEReferenceType().getInstanceClass();
		Combo combo = new Combo(comp, SWT.BORDER | SWT.DROP_DOWN | SWT.READ_ONLY);
		combo.setLayoutData(textLayoutData);
		ComboViewer cv = new ComboViewer(combo);
		cv.setContentProvider(new ArrayContentProvider());
		cv.setLabelProvider(getNameLabelProvider());
		
		List<Object> input = new ArrayList<Object>();
		Map<? extends Object, String> possibleValues = possibleValuesMap.get(ref);
		if (possibleValues != null) {
			input.addAll(possibleValues.keySet());
			ModelElement currentValue = (ModelElement) bo.eGet(ref);
			if (currentValue != null && !possibleValues.keySet().contains(currentValue)) {
				input.add(currentValue);
			}
		} else {
			input = getInput(bo, instanceClass);
		}
		cv.setInput(input);
		
		IViewerObservableValue uiProp = ViewersObservables.observeSingleSelection(cv);
		IObservableValue modelObs = EMFEditObservables.observeValue(domain,bo,ref);
		context.bindValue(uiProp, modelObs);
		
		combo.setEnabled(!readOnlyAttributes.contains(ref));
	}
	
	private List<Object> getInput(EObject bo, Class<?> searchFor) {
		List<Object> result = new ArrayList<Object>();
		if (bo instanceof ModelElement) {
			GraphModel gm = ((ModelElement) bo).getRootElement();
			getAllModelElements(gm, result, searchFor);
		}
		return result;
	}

	private void getAllModelElements(ModelElementContainer container, List<Object> result, Class<?> searchFor) {
		result.addAll(container.getModelElements((Class<? extends ModelElement>) searchFor));
		for (Container c : container.getAllContainers()) {
			getAllModelElements(c, result, searchFor);
		}
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
		}  
		
		else if (attr.getEAttributeType() instanceof EEnum || attr.getEAttributeType().getName().equals("EBoolean")) {
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
		} 
		else if (fileAttributes.contains(attr)) {
			Composite fileComposite = new Composite(comp, SWT.NONE);
			fileComposite.setLayout(new GridLayout(2, false));
			fileComposite.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
			
			Text text = new Text(fileComposite, SWT.BORDER);
			text.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
			
			Button browse = new Button(fileComposite, SWT.PUSH | SWT.BORDER);
			browse.setText("Browse...");
			browse.addSelectionListener(initBrowseSelectionListener(fileComposite.getShell(), text, attr));
			
			IWidgetValueProperty uiProp = WidgetProperties.text(new int[] { SWT.DefaultSelection, SWT.FocusOut, SWT.Modify });			
			IObservableValue modelObs = EMFEditProperties.value(domain,attr).observe(bo);

			context.bindValue(uiProp.observe(text),  modelObs);
			text.setEnabled(false);
			browse.setEnabled(true);
		} else if (possibleValuesMap.containsKey(attr)) {
//			Label label = new Label(comp, SWT.NONE);
//			label.setText(ref.getName());
//			label.setLayoutData(labelLayoutData);
			
//			Class<?> instanceClass = ref.getEReferenceType().getInstanceClass();
			Combo combo = new Combo(comp, SWT.BORDER | SWT.DROP_DOWN | SWT.READ_ONLY);
			combo.setLayoutData(textLayoutData);
			ComboViewer cv = new ComboViewer(combo);
			cv.setContentProvider(new ArrayContentProvider());
			cv.setLabelProvider(getSpecialLabelProvider());
			
			List<Object> input = new ArrayList<Object>();
			Map<? extends Object, String> possibleValues = possibleValuesMap.get(attr);
			if (possibleValues != null) {
				input.addAll(possibleValues.keySet());
				Object currentValue = (Object) bo.eGet(attr);
				if (currentValue != null && !possibleValues.keySet().contains(currentValue)) {
					input.add(currentValue);
				}
			} else {
//				input = getInput(bo, instanceClass);
			}
			cv.setInput(input);
			
			IViewerObservableValue uiProp = ViewersObservables.observeSingleSelection(cv);
			IObservableValue modelObs = EMFEditObservables.observeValue(domain,bo,attr);
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
			comp.layout(true, true);
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

		Table table = new Table(comp, SWT.SINGLE | SWT.BORDER | SWT.FULL_SELECTION);
		TableViewer tableViewer = new TableViewer(table);
		table.setLayoutData(tableLayoutData);

		TextCellEditor editor = new TextCellEditor(table);
		tableViewer.setCellEditors(new CellEditor[] {editor});
		
		tableViewer.getTable().setEnabled(true);
		
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
				
				EObject eObject = (EObject) element;
				EObject eContainer = eObject.eContainer();

				for (EReference ref : eContainer.eClass().getEAllReferences()) {
					Object value = eContainer.eGet(ref, true);
					if (isMultiValued(value) && !((List<?>) value).isEmpty())
						value = ((List<?>) value).get(0);
					if (eObject.equals(value)) {
						return ref.getName();
					}
					
				}

				return null;
			}

			private boolean isMultiValued(Object value) {
				return value instanceof List;
			}
		};
	}

	private LabelProvider getNameLabelProvider() {
		return new LabelProvider() {
			@Override
			public String getText(Object element) {
				if (!(element instanceof EObject))
					return super.getText(element);
				EObject eObject = (EObject) element;
				String alternativeLabel = getAlternativeLabel(element);
				if (alternativeLabel != null && !alternativeLabel.isEmpty()) {
					return alternativeLabel;
				}
				EStructuralFeature nameFeature = getNameFeature(eObject);
				if (nameFeature == null)
					return super.getText(element);
				String name = (String) eObject.eGet(nameFeature);
				if (name == null) {
					return "Name attribute has value null..." + super.getText(element);
				}
				if (name.isEmpty()) {
					return "No name set for: " + super.getText(element);
				}
				return name;
			}

			private String getAlternativeLabel(Object element) {
				for (Map<? extends Object, String> map : possibleValuesMap.values()) {
					if (map.containsKey(element))
						return map.get(element);
				}
				return null;
			}

			private EStructuralFeature getNameFeature(EObject element) {
				return element.eClass().getEStructuralFeature("name");
			}
		};
	}
	
	/**
	 * This class is a temporary solution since the {@link #getNameLabelProvider()} could not
	 * retrieve the display names for possibleValues of primitive attributes.
	 * 
	 * FIXME: Provide a nice solution
	 * @return
	 */
	private LabelProvider getSpecialLabelProvider() {
		return new LabelProvider() {
			@Override
			public String getText(Object element) {
				Object eObject = (Object) element;
				String alternativeLabel = getAlternativeLabel(element);
				if (alternativeLabel != null && !alternativeLabel.isEmpty()) {
					return alternativeLabel;
				}
//				EStructuralFeature nameFeature = getNameFeature(eObject);
//				if (nameFeature == null)
//					return super.getText(element);
//				String name = (String) eObject.eGet(nameFeature);
//				if (name == null) {
//					return "Name attribute has value null..." + super.getText(element);
//				}
//				if (name.isEmpty()) {
//					return "No name set for: " + super.getText(element);
//				}
				return "ERROR";
			}

			private String getAlternativeLabel(Object element) {
				for (Map<? extends Object, String> map : possibleValuesMap.values()) {
					if (map.containsKey(element))
						return map.get(element);
				}
				return null;
			}

			private EStructuralFeature getNameFeature(EObject element) {
				return element.eClass().getEStructuralFeature("name");
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
		PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().removePartListener(this);
		registeredListeners.forEach(l -> PlatformUI.getWorkbench().getActiveWorkbenchWindow().getActivePage().removeSelectionListener(l));
		registeredListeners.clear();
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
	
	private SelectionListener initBrowseSelectionListener(Shell s, Text text, EAttribute attr) {
		SelectionListener sl = new SelectionListener() {
			
			@Override
			public void widgetSelected(SelectionEvent e) {
				FileDialog dialog = new FileDialog(s, SWT.OPEN);
				IProject project = eapi(getActiveEditor()).getProject();
				if (project != null) {
					IPath location = project.getLocation();
					System.out.println("Setting browsee location via project: " + location.toString());
					dialog.setFilterPath(location.toString());
				}
				else {
					IPath location = ResourcesPlugin.getWorkspace().getRoot().getLocation();
					System.out.println("Setting browse location via workspace: " + location.toString());
					dialog.setFilterPath(location.toString());
				}
				
				String extensions = "";
				List<String> nonEmpty = fileExtensionFilters.get(attr).stream().filter(str -> !str.isEmpty()).collect(Collectors.toList());
				for (String ext : nonEmpty)
					extensions += "*."+ext+";";
				
				if (!extensions.isEmpty())
					dialog.setFilterExtensions(new String[] {extensions});
				
				String path = dialog.open();
				if (path != null) {
					List<IFile> files = getFiles(f -> f.getLocation().toPortableString().equals(path));
					IFile iFile = (files.isEmpty()) ? null : files.get(0);
					if (iFile != null)
						text.setText(iFile.getProjectRelativePath().toString());
					else text.setText(path);
				}
			}
			
			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
			}
		};
		return sl;
	}

	@Override
	public void partActivated(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partBroughtToTop(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partClosed(IWorkbenchPartReference partRef) {
		IWorkbenchPart activePart = partRef.getPage().getActivePart();
		if (!(activePart instanceof MultiPageGratextEditor))
			clearPage();
	}

	@Override
	public void partDeactivated(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partOpened(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partHidden(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partVisible(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void partInputChanged(IWorkbenchPartReference partRef) {
		// TODO Auto-generated method stub
		
	}
	
}
