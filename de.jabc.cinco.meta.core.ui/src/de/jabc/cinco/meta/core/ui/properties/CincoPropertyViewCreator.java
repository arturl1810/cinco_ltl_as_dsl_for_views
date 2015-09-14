package de.jabc.cinco.meta.core.ui.properties;

import graphmodel.GraphModel;
import graphmodel.ModelElement;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.OptionalInt;
import java.util.stream.Collectors;

import org.eclipse.core.databinding.UpdateValueStrategy;
import org.eclipse.core.databinding.conversion.IConverter;
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

import de.jabc.cinco.meta.core.ui.listener.CincoTableMenuListener;
import de.jabc.cinco.meta.core.ui.listener.CincoTreeMenuListener;
import de.jabc.cinco.meta.core.ui.validator.TextValidator;

public class CincoPropertyViewCreator {

	private Map<EObject, Composite> compositesMap;
	
	private Map<Class<? extends EObject>, IEMFListProperty> emfListPropertiesMap;
	private Map<Class<? extends EObject>, List<EStructuralFeature>> attributesMap;
	private Map<Class<? extends EObject>, List<EStructuralFeature>> referencesMap;

	private Composite simpleViewComposite;

	private final GridData labelLayoutData = new GridData(SWT.LEFT, SWT.CENTER,
			false, false);
	private final GridData tableLabelLayoutData = new GridData(SWT.LEFT,
			SWT.TOP, false, false);
	private final GridData textLayoutData = new GridData(SWT.FILL, SWT.CENTER,
			true, false);
	private final GridData tableLayoutData = new GridData(SWT.FILL, SWT.FILL,
			true, true);

	private static CincoPropertyViewCreator instance;

	private TransactionalEditingDomain domain;
	private EMFDataBindingContext context;
	private Object lastSelectedObject;

	private CincoPropertyViewCreator() {
		compositesMap = new HashMap<EObject, Composite>();
		emfListPropertiesMap = new HashMap<Class<? extends EObject>, IEMFListProperty>();
		attributesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();
		referencesMap = new HashMap<Class<? extends EObject>, List<EStructuralFeature>>();

		context = new EMFDataBindingContext();
		
		tableLayoutData.minimumHeight = 50;
	}

	public static CincoPropertyViewCreator getInstance() {
		if (instance == null)
			instance = new CincoPropertyViewCreator();
		return instance;
	}

	public void init_EStructuralFeatures(Class<? extends EObject> clazz,
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

	public void init_ListPorperties(Class<? extends EObject> clazz,	EStructuralFeature... features) {
		if (emfListPropertiesMap.get(clazz) == null) {
			emfListPropertiesMap.put(clazz, EMFProperties.multiList(features));
		}
	}

	public void init_PropertyView(EObject bo, Composite parent) {
		if (bo == null || bo.equals(lastSelectedObject))
			return;
		
		disposeChildren(parent);
		context = new EMFDataBindingContext();
		Composite mainComposite = new Composite(parent, SWT.NONE);
		setTwoColumnGridLayout(mainComposite);
		mainComposite.setLayoutData(new GridData(SWT.NONE));

		createTreePropertyView(bo, mainComposite);
		createSimplePropertyView(bo, mainComposite);

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
				//TODO: Fix the CincoTreeFactory. Removing single valued attributes 
				// 		from the tree ends in AssertionFailedException 
				new CincoTreeFactory(bo, emfListPropertiesMap),
//				new CincoTreeFactoryTest(bo, referencesMap),
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

		List<EStructuralFeature> attributes = attributesMap.get(bo.getClass());
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

	private void createSingleAttributeProperty(EObject bo, Composite comp,
			EAttribute attr) {

		Label label = new Label(comp, SWT.NONE);
		label.setText(attr.getName() + ": ");
		label.setLayoutData(labelLayoutData);

		if (attr.getEAttributeType().getName().equals("EDate")) {
			label.setLayoutData(tableLabelLayoutData);
			Composite dateComposite = new Composite(comp, SWT.NONE);
			dateComposite.setLayout(new GridLayout(2, false));
			dateComposite.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
			
			DateTime date = new DateTime(dateComposite, SWT.CALENDAR);
//			DateTime time = new DateTime(dateComposite, SWT.TIME);
			
			ISWTObservableValue uiPropDate = WidgetProperties.selection().observe(date);
//			ISWTObservableValue uiPropTime = WidgetProperties.selection().observe(time);
			
			IObservableValue boProp = EMFEditProperties.value(domain, attr).observe(bo);
			context.bindValue(uiPropDate, boProp);
//			context.bindValue(uiPropTime, boProp);
			
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
		} else {
			Text text = new Text(comp, SWT.BORDER);
			text.setLayoutData(textLayoutData);
			text.addModifyListener(new TextValidator(attr.getEAttributeType()));
			
			IWidgetValueProperty uiProp = WidgetProperties.text(new int[] {
					SWT.DefaultSelection, SWT.FocusOut });
			IEMFEditValueProperty boPorp = EMFEditProperties.value(domain, attr);
			UpdateValueStrategy updateStrategy = new UpdateValueStrategy();
			
			updateStrategy.setConverter(new IConverter() {
				
				@Override
				public Object getToType() {
					// TODO Auto-generated method stub
					return null;
				}
				
				@Override
				public Object getFromType() {
					// TODO Auto-generated method stub
					return null;
				}
				
				@Override
				public Object convert(Object fromObject) {
					if (fromObject instanceof Character) {
						if ((Character) fromObject == '\0')
							return new String("a");
						return String.valueOf(fromObject);
					}
					if (fromObject instanceof String) {
						if ("0".equals(fromObject))
							return new Character('\0');
						return ((String) fromObject).charAt(0);
					}
					
					return fromObject;
				}
			});
			
			if (attr.getEAttributeType().getName().equals("EChar"))
				context.bindValue(uiProp.observe(text), boPorp.observe(bo),updateStrategy, updateStrategy);
			else context.bindValue(uiProp.observe(text), boPorp.observe(bo));
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
			l.setText("No properties for type: "
					+ bo.getClass().getSimpleName().replace("Impl", ""));
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
			throw new RuntimeException(
					"Could not get/create TransactionalEditingDomain for object: "
							+ bo);
		return domain;
	}

}
